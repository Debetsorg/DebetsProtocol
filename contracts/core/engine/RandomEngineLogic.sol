// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import "../../interfaces/IRandomEngineLogic.sol";
import "../../interfaces/IStakingPool.sol";
import "../../interfaces/IDistributionPool.sol";
import "../../interfaces/ISwapProvider.sol";
import "../../interfaces/IRandomCaller.sol";

import "../../utils/VRFConsumerBaseV2.sol";
import "./RandomEngineStorage.sol";

/**
 * @title RandomEngineLogic contract
 * @author Debet
 * @notice Core logic functions of the RandomEngine
 */
abstract contract RandomEngineLogic is
    IRandomEngineLogic,
    VRFConsumerBaseV2,
    RandomEngineStorage
{
    /**
     * @notice Request the random works
     * @dev Emit the RandomRequest event
     * @dev Only valid caller set by factory can call ths function
     * @param callbackGasLimit The gas required by the callback
     * function of caller contract
     * @param numWords The number of random words that caller required
     * @param rewardsReceiver The address receive rewards of random engine and refund gas
     * @return requestId The request id from chainlink vrf service
     */
    function request(
        uint32 callbackGasLimit,
        uint32 numWords,
        address rewardsReceiver
    ) external payable override returns (uint256 requestId) {
        require(isValidCaller[msg.sender], "invalid caller");

        (uint128 gasRequired, uint32 consumerGasLimit) = calculateGasRequired(
            callbackGasLimit,
            tx.gasprice
        );

        uint128 baseFee = requestBaseFee;
        uint256 nativeTokenRequired = gasRequired + baseFee;
        require(msg.value >= nativeTokenRequired, "insufficient bet fee");

        requestId = requestRandomWords(gasRequired, consumerGasLimit, numWords);

        requestRecords[requestId] = Request(
            requestId,
            msg.sender,
            rewardsReceiver,
            0,
            false
        );

        if (baseFee > 0 && stakingPool != address(0)) {
            addToRewards(baseFee);
        }

        if (msg.value > nativeTokenRequired) {
            uint256 refundValue = msg.value - nativeTokenRequired;
            refundNativeToken(refundValue, rewardsReceiver);
        }

        emit RandomRequest(msg.sender, rewardsReceiver, requestId);
    }

    /**
     * @notice Top up link token for subcription account of random engine
     * @dev Emit the TopUpLink event
     */
    function topUpLink() external payable override {
        uint256 totalAmountToSwap = nativeTokenToSwap + msg.value;
        swapAndTopUp(totalAmountToSwap);
        nativeTokenToSwap = 0;
    }

    /**
     * @notice Set the caller enable or not
     * @dev Emit the SetCaller event
     * @param caller The address of the caller
     * @param enable Whether enable the caller or not
     */
    function setCaller(address caller, bool enable) external override {
        require(msg.sender == factory, "forbidden");
        isValidCaller[caller] = enable;
        emit SetCaller(caller, enable);
    }

    /**
     * @notice get the amount of native token required as gas when call the request function
     * @param callbackGasLimit The gas required by the callback
     * function of caller contract
     * @param gasPriceWei Estimated gas price at time of request
     * @return The amount of native token required
     */
    function calculateNativeTokenRequired(
        uint32 callbackGasLimit,
        uint256 gasPriceWei
    ) external view override returns (uint256) {
        (uint256 gasRequired, ) = calculateGasRequired(
            callbackGasLimit,
            gasPriceWei
        );
        return (gasRequired + requestBaseFee);
    }

    /**
     * @dev callback function called by VRFConsumerBaseV2
     */
    function fulfillRandomWords(uint256 requestId, uint256[] memory randomWords)
        internal
        override
    {
        Request memory requestRecord = requestRecords[requestId];
        require(
            requestRecord.caller != address(0),
            "the record does not exist"
        );

        if (distributionPool != address(0)) {
            requestRecord.rewards = IDistributionPool(distributionPool)
                .distribute(
                    requestRecord.caller,
                    requestRecord.rewardsReceiver,
                    randomWords[0]
                );
        }

        requestRecord.callback = true;
        requestRecords[requestId] = requestRecord;

        IRandomCaller(requestRecord.caller).callback(
            requestId,
            randomWords,
            requestRecord.rewards
        );

        emit RandomCallback(
            requestRecord.caller,
            requestRecord.rewardsReceiver,
            requestId,
            requestRecord.rewards
        );
    }

    function requestRandomWords(
        uint128 gasRequired,
        uint32 callbackGasLimit,
        uint32 numWords
    ) internal returns (uint256 requestId) {
        nativeTokenToSwap += gasRequired;
        if (isTimeToSwap()) {
            swapAndTopUp(nativeTokenToSwap);
            nativeTokenToSwap = 0;
        }

        uint32 totalCallbackGasLimit = callbackGasLimit + extraCallbackGas;
        requestId = COORDINATOR.requestRandomWords(
            KEY_HASH,
            subscription_id,
            REQUEST_CONFIRMATIONS,
            totalCallbackGasLimit,
            numWords
        );
    }

    function isTimeToSwap() internal returns (bool) {
        uint96 subscriptioBalance;
        (subscriptioBalance, , , ) = COORDINATOR.getSubscription(
            subscription_id
        );

        if (subscriptioBalance <= minLinkBalanceToSwap) {
            return true;
        }

        if (block.timestamp - lastSwapTime >= intervalTimeToSwap) {
            lastSwapTime = uint32(block.timestamp);
            return true;
        }

        return false;
    }

    function swapAndTopUp(uint256 amount) internal {
        ISwapProvider(swapProvider).swapNativeTokenToLink{value: amount}(
            0,
            address(this)
        );

        topUpSubscription(LINKTOKEN.balanceOf(address(this)));
    }

    function topUpSubscription(uint256 amount) private {
        LINKTOKEN.transferAndCall(
            address(COORDINATOR),
            amount,
            abi.encode(subscription_id)
        );

        emit TopUpLink(amount);
    }

    function createNewSubscription() internal {
        subscription_id = COORDINATOR.createSubscription();
        COORDINATOR.addConsumer(subscription_id, address(this));
    }

    function addToRewards(uint128 baseFee) internal {
        nativeTokenToRewards += baseFee;
        if (nativeTokenToRewards >= thresholdToAddRewards) {
            IStakingPool(stakingPool).addNativeRewards{
                value: nativeTokenToRewards
            }();
            nativeTokenToRewards = 0;
        }
    }

    function refundNativeToken(uint256 refundValue, address rewardsReceiver)
        internal
    {
        (bool success, ) = payable(rewardsReceiver).call{
            value: refundValue,
            gas: 8000
        }("");
        require(success, "refund native token failed");
    }

    function calculateGasRequired(uint32 callbackGasLimit, uint256 gasPrice)
        internal
        view
        returns (uint128, uint32)
    {
        uint256 weiPerUnitLink = getFeedData();

        uint32 consumerGasLimit;
        if (distributionPool == address(0)) {
            consumerGasLimit = engineCallbackGas + callbackGasLimit;
        } else {
            consumerGasLimit =
                engineCallbackGas +
                distributionCallbackGas +
                callbackGasLimit;
        }
        uint32 totalGasLimit = consumerGasLimit + MAX_VERIFICATION_GAS;

        uint256 gas_required = gasPrice * totalGasLimit;
        uint256 link_premium_to_gas = (LINK_PREMIUM * weiPerUnitLink) / 1e18;
        uint256 total_gas_required = gas_required + link_premium_to_gas;
        assert(total_gas_required < type(uint128).max);

        return (uint128(total_gas_required), consumerGasLimit);
    }

    function getFeedData() private view returns (uint256) {
        uint256 timestamp;
        int256 weiPerUnitLink;

        (, weiPerUnitLink, , timestamp, ) = LINK_NATIVE_FEED.latestRoundData();

        if (STALENESS_SECONDS < block.timestamp - timestamp) {
            uint256 weiPerUnitLinkFromDex = ISwapProvider(swapProvider)
                .getWeiPerUnitLink();
            return weiPerUnitLinkFromDex;
        }

        require(weiPerUnitLink >= 0, "Invalid LINK wei price");
        return uint256(weiPerUnitLink);
    }
}
