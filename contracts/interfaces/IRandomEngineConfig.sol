// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

/**
 * @title IRandomEngineConfig contract
 * @author Debet
 * @notice The interface for RandomEngineConfig contract
 */
interface IRandomEngineConfig {
    /**
     * @dev Emit on setRequestBaseFee function
     * @param requestBaseFee The amount of base Fee
     */
    event SetRequestBaseFee(uint128 requestBaseFee);

    /**
     * @dev Emit on setIntervalTimeToSwap function
     * @param intervalTimeToSwap The interval time
     */
    event SetIntervalTimeToSwap(uint32 intervalTimeToSwap);

    /**
     * @dev Emit on setCallbackGas function
     * @param engineCallbackGas The gas limit in randomEngine request function
     * @param distributionCallbackGas The gas limit in distribution rewards function
     */
    event SetCallbackGas(
        uint32 engineCallbackGas,
        uint32 distributionCallbackGas
    );

    /**
     * @dev Emit on setExtraCallbackGas function
     * @param extraCallbackGas The amount of extra gas
     */
    event SetExtraCallbackGas(uint32 extraCallbackGas);

    /**
     * @dev Emit on setMinLinkBalanceToSwap function
     * @param minLinkBalanceToSwap The minimum link balance of subscription account
     */
    event SetMinLinkBalanceToSwap(uint128 minLinkBalanceToSwap);

    /**
     * @dev Emit on setThresholdToAddRewards function
     * @param thresholdToAddRewards The rewards threshold to adding rewards to rewards pool
     */
    event SetThresholdToAddRewards(uint128 thresholdToAddRewards);

    /**
     * @dev Emit on setSwapProvider function
     * @param swapProvider The address of swap provider contract
     */
    event SetSwapProvider(address swapProvider);

    /**
     * @dev Emit on setStakingPool function
     * @param stakingPool The address of staking pool contract
     */
    event SetStakingPool(address stakingPool);

    /**
     * @dev Emit on setDistributionPool function
     * @param distributionPool The address of distribution pool contract
     */
    event SetDistributionPool(address distributionPool);

    /**
     * @dev Emit on setFactory function
     * @param factory The address of factory contract
     */
    event SetFactory(address factory);

    /**
     * @dev Emit on stopEngine function
     * @param linkReceiver The address to receive the remain link token in
     * subscription account
     */
    event StopEngine(address linkReceiver);

    /**
     * @notice Set the base fee that player pay each time they bet
     * @dev Emit the SetRequestBaseFee event
     * @param _requestBaseFee The amount of base Fee
     */
    function setRequestBaseFee(uint128 _requestBaseFee) external;

    /**
     * @notice Set the maximum interval time of swapping native token to link
     * @dev Emit the SetIntervalTimeToSwap event
     * @param _intervalTimeToSwap The interval time
     */
    function setIntervalTimeToSwap(uint32 _intervalTimeToSwap) external;

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
    ) external;

    /**
     * @notice Set the extra gas added to callBackGasLimit when call chainlink vrf
     * @dev Emit the SetExtraCallbackGas event
     * @dev The extra gas would not be used in transaction
     * @param _extraCallbackGas The amount of extra gas
     */
    function setExtraCallbackGas(uint32 _extraCallbackGas) external;

    /**
     * @notice set the rewards threshold to adding rewards to rewards pool
     * @dev Emit the SetThresholdToAddRewards event
     * @param _thresholdToAddRewards The threshold
     */
    function setThresholdToAddRewards(uint128 _thresholdToAddRewards) external;

    /**
     * @notice Set the minimum link balance of subscription account
     * @dev Emit the SetMinLinkBalanceToSwap event
     * @dev Swap the native token to link if the link balance of
     * subscription account is less than this value
     * @param _minLinkBalanceToSwap The minimum link balance
     */
    function setMinLinkBalanceToSwap(uint128 _minLinkBalanceToSwap) external;

    /**
     * @notice Set the address of swap provider
     * @dev Emit the SetSwapProvider event
     * @param _swapProvider The address of swap provider contract
     */
    function setSwapProvider(address _swapProvider) external;

    /**
     * @notice Set the address of staking pool
     * @dev Emit the SetStakingPool event
     * @param _stakingPool The address of staking pool contract
     */
    function setStakingPool(address _stakingPool) external;

    /**
     * @notice Set the address of distribution pool
     * @dev Emit the SetDistributionPool event
     * @param _distributionPool The address of distribution pool contract
     */
    function setDistributionPool(address _distributionPool) external;

    /**
     * @notice Set the address of factory contract
     * @dev Emit the SetFactory event
     * @param _factory The address of factory contract
     */
    function setFactory(address _factory) external;

    /**
     * @notice Stop the Random engine and cancel subscription of chainlink vrf
     * @dev Emit the StopEngine event
     * @param linkReceiver The address to receive the remain link token in
     * subscription account
     */
    function stopEngine(address linkReceiver) external;
}
