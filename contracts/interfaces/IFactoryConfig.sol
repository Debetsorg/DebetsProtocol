// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

/**
 * @title IFactoryConfig interface
 * @author Debet
 * @notice The interface for FactoryConfig
 */
interface IFactoryConfig {
    /**
     * @dev Emit on setDefaultCountsToAddRewards function
     * @param defaultCounts The default number of times
     */
    event UpdateDefaultCountsToAddRewards(uint256 defaultCounts);

    /**
     * @dev Emit on setCountsToAddRewards function
     * @param token The specified token address
     * @param counts The number of times
     */
    event UpdateCountsToAddRewards(address token, uint256 counts);

    /**
     * @dev Emit on setProtocolInReferralFee function
     * @param newProtocolInReferralFee The percentage
     */
    event UpdateProtocolInReferralFee(uint256 newProtocolInReferralFee);

    /**
     * @dev Emit on setMaxPrizeRate function
     * @param newMaxPrizeRate The maximun ratio
     */
    event UpdateMaxPrizeRate(uint256 newMaxPrizeRate);

    /**
     * @dev Emit on setRandomEngine function
     * @param newRandomEngine The address of random engine
     */
    event UpdateRandomEngine(address newRandomEngine);

    /**
     * @dev Emit on setRewardsPool function
     * @param newRewardsPool The address of rewards pool
     */
    event UpdateRewardsPool(address newRewardsPool);

    /**
     * @dev Emit on setGame function
     * @param game The address of game contract
     * @param enable Whether to enable or disable
     */
    event SetGame(address game, bool enable);

    /**
     * @notice Set the default number of times the pool receive rewards before
     * adding rewards to rewards pool for all tokens
     * @dev Only owner can call this function
     * @param defaultCounts The default number of times
     */
    function setDefaultCountsToAddRewards(uint256 defaultCounts) external;

    /**
     * @notice Set the number of times the pool receive rewards before adding
     * rewards to rewards pool for specified token
     * @dev Only owner can call this function
     * @param token The specified token address
     * @param counts The number of times
     */
    function setCountsToAddRewards(address token, uint256 counts) external;

    /**
     * @notice Set the ratio of the rawards pool fee in the referral fee
     * @dev Only owner can call this function
     * @param newProtocolInReferralFee The percentage
     */
    function setProtocolInReferralFee(uint256 newProtocolInReferralFee)
        external;

    /**
     * @notice Set the maximum ratio of the total free amount
     * in a token pool that will be paid out at one time
     * @dev Only owner can call this function
     * @param newMaxPrizeRate The maximun ratio
     */
    function setMaxPrizeRate(uint256 newMaxPrizeRate) external;

    /**
     * @notice Set the address of the random engine contract
     * @dev Only owner can call this function
     * @param newRandomEngine The address of random engine
     */
    function setRandomEngine(address newRandomEngine) external;

    /**
     * @notice Set the address of the rewards pool contract
     * @dev Only owner can call this function
     * @param newRewardsPool The address of rewards pool
     */
    function setRewardsPool(address newRewardsPool) external;

    /**
     * @notice Enable or disable a game contract to call token pools
     * @dev Only owner can call this function
     * @param game The address of game contract
     * @param enable Whether to enable or disable
     */
    function setGame(address game, bool enable) external;

    /**
     * @notice Query the number of times the specified token pool
     * receive rewards before adding rewards to rewards pool.
     * @param token the specified token address
     * @return the number of times
     */
    function countsToAddRewards(address token) external view returns (uint256);
}
