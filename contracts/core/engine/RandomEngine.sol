// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import "./RandomEngineConfig.sol";
import "./RandomEngineLogic.sol";

/**
 * @title RandomEngine contract
 * @author Debet
 * @notice Implemention of the RandomEngine contract in debet protocol
 */
contract RandomEngine is RandomEngineConfig, RandomEngineLogic {
    /**
     * @dev Constructor.
     * @param _linkToken The address of the vrf link token
     * @param _coordinator The address of the vrf coordinator
     * @param _linkNativeFeed The address of the chainlink feed contract (NativeToken/LINK)
     * @param _linkPremium The amount of link token for vrf request fee
     * @param _keyHash The bytes for maximum gas limit in vrf callback transaction
     */
    constructor(
        address _linkToken,
        address _coordinator,
        address _linkNativeFeed,
        uint128 _linkPremium,
        bytes32 _keyHash
    )
        RandomEngineStorage(
            _linkToken,
            _coordinator,
            _linkNativeFeed,
            _linkPremium,
            _keyHash
        )
    {}

    /**
     * @notice Initialize the RandomEngine contract
     * @dev Create the subscription account in vrf
     * @param _factory The address of the factory contract
     * @param _stakingPool The address of the staking pool contract
     * @param _stakingPool The address of the swap provider contract
     * @param _distributionPool The address of the distribution pool contract
     */
    function initialize(
        address _factory,
        address _stakingPool,
        address _swapProvider,
        address _distributionPool
    ) external initializer {
        __Ownable_init();

        deployTime = uint128(block.timestamp);
        requestBaseFee = 0;
        engineCallbackGas = 40000;
        distributionCallbackGas = 60000;
        extraCallbackGas = 100000;
        thresholdToAddRewards = 1e18;
        intervalTimeToSwap = 4 hours;
        minLinkBalanceToSwap = 2 * 1e18;

        factory = _factory;
        swapProvider = _swapProvider;
        stakingPool = _stakingPool;
        distributionPool = _distributionPool;

        setVRFCoordinator(address(COORDINATOR));
        createNewSubscription();
    }
}
