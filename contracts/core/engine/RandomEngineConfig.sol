// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

import "../../interfaces/IRandomEngineConfig.sol";

import "./RandomEngineStorage.sol";

/**
 * @title RandomEngineConfig contract
 * @author Debet
 * @notice Configuration of the RandomEngine
 */
abstract contract RandomEngineConfig is
    IRandomEngineConfig,
    OwnableUpgradeable,
    RandomEngineStorage
{
    /**
     * @notice Set the base fee that player pay each time they bet
     * @dev Emit the SetRequestBaseFee event
     * @param _requestBaseFee The amount of base Fee
     */
    function setRequestBaseFee(uint128 _requestBaseFee)
        external
        override
        onlyOwner
    {
        requestBaseFee = _requestBaseFee;
        emit SetRequestBaseFee(_requestBaseFee);
    }

    /**
     * @notice Set the maximum interval time of swapping native token to link
     * @dev Emit the SetIntervalTimeToSwap event
     * @param _intervalTimeToSwap The interval time
     */
    function setIntervalTimeToSwap(uint32 _intervalTimeToSwap)
        external
        override
        onlyOwner
    {
        intervalTimeToSwap = _intervalTimeToSwap;
        emit SetIntervalTimeToSwap(_intervalTimeToSwap);
    }

    /**
     * @notice Set the callback gas limit in random engine
     * @dev Emit the SetCallbackGas event
     * @dev Including gas in request function and distribute function
     * @param _engineCallbackGas The gas limit in randomEngine request function
     * @param _distributionCallbackGas The gas limit in distribution rewards function
     */
    function setCallbackGas(
        uint32 _engineCallbackGas,
        uint32 _distributionCallbackGas
    ) external override onlyOwner {
        engineCallbackGas = _engineCallbackGas;
        distributionCallbackGas = _distributionCallbackGas;
        emit SetCallbackGas(_engineCallbackGas, _distributionCallbackGas);
    }

    /**
     * @notice Set the extra gas added to callBackGasLimit when call chainlink vrf
     * @dev Emit the SetExtraCallbackGas event
     * @dev The extra gas would not be used in transaction
     * @param _extraCallbackGas The amount of extra gas
     */
    function setExtraCallbackGas(uint32 _extraCallbackGas)
        external
        override
        onlyOwner
    {
        extraCallbackGas = _extraCallbackGas;
        emit SetExtraCallbackGas(_extraCallbackGas);
    }

    /**
     * @notice set the rewards threshold to adding rewards to rewards pool
     * @dev Emit the SetThresholdToAddRewards event
     * @param _thresholdToAddRewards The threshold
     */
    function setThresholdToAddRewards(uint128 _thresholdToAddRewards)
        external
        override
        onlyOwner
    {
        thresholdToAddRewards = _thresholdToAddRewards;
        emit SetThresholdToAddRewards(_thresholdToAddRewards);
    }

    /**
     * @notice Set the minimum link balance of subscription account
     * @dev Emit the SetMinLinkBalanceToSwap event
     * @dev Swap the native token to link if the link balance of
     * subscription account is less than this value
     * @param _minLinkBalanceToSwap The minimum link balance
     */
    function setMinLinkBalanceToSwap(uint128 _minLinkBalanceToSwap)
        external
        override
        onlyOwner
    {
        minLinkBalanceToSwap = _minLinkBalanceToSwap;
        emit SetMinLinkBalanceToSwap(_minLinkBalanceToSwap);
    }

    /**
     * @notice Set the address of swap provider
     * @dev Emit the SetSwapProvider event
     * @param _swapProvider The address of swap provider contract
     */
    function setSwapProvider(address _swapProvider)
        external
        override
        onlyOwner
    {
        swapProvider = _swapProvider;
        emit SetSwapProvider(_swapProvider);
    }

    /**
     * @notice Set the address of staking pool
     * @dev Emit the SetStakingPool event
     * @param _stakingPool The address of staking pool contract
     */
    function setStakingPool(address _stakingPool) external override onlyOwner {
        stakingPool = _stakingPool;
        emit SetStakingPool(_stakingPool);
    }

    /**
     * @notice Set the address of distribution pool
     * @dev Emit the SetDistributionPool event
     * @param _distributionPool The address of distribution pool contract
     */
    function setDistributionPool(address _distributionPool)
        external
        override
        onlyOwner
    {
        distributionPool = _distributionPool;
        emit SetDistributionPool(_distributionPool);
    }

    /**
     * @notice Set the address of factory contract
     * @dev Emit the SetFactory event
     * @param _factory The address of factory contract
     */
    function setFactory(address _factory) external override onlyOwner {
        factory = _factory;
        emit SetFactory(_factory);
    }

    /**
     * @notice Stop the Random engine and cancel subscription of chainlink vrf
     * @dev Emit the StopEngine event
     * @param linkReceiver The address to receive the remain link token in
     * subscription account
     */
    function stopEngine(address linkReceiver) external onlyOwner {
        require(block.timestamp - deployTime <= 60 days, "forbidden");
        cancelSubscription(linkReceiver);
        emit StopEngine(linkReceiver);
    }

    function cancelSubscription(address receivingWallet) private {
        COORDINATOR.cancelSubscription(subscription_id, receivingWallet);
        subscription_id = 0;
    }
}
