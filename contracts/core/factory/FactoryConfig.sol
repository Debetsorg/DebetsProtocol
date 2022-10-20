// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import "../../interfaces/IFactoryConfig.sol";
import "../../interfaces/IRandomEngine.sol";

import "./FactoryStorage.sol";

/**
 * @title FactoryConfig contract
 * @author Debet
 * @notice Configuration of the factory contract
 */
abstract contract FactoryConfig is IFactoryConfig, FactoryStorage {
    /**
     * @notice Set the default number of times the pool receive rewards before
     * adding rewards to rewards pool for all tokens
     * @dev Only owner can call this function
     * @dev Emit the UpdateDefaultCountsToAddRewards event
     * @param defaultCounts The default number of times
     */
    function setDefaultCountsToAddRewards(uint256 defaultCounts)
        external
        override
        onlyOwner
    {
        defaultCountsToAddRewards = defaultCounts;
        emit UpdateDefaultCountsToAddRewards(defaultCounts);
    }

    /**
     * @notice Set the number of times the pool receive rewards before adding
     * rewards to rewards pool for specified token
     * @dev Only owner can call this function
     * @dev Emit the UpdateCountsToAddRewards event
     * @param token The specified token address
     * @param counts The number of times
     */
    function setCountsToAddRewards(address token, uint256 counts)
        external
        override
        onlyOwner
    {
        countsToAddRewardsMap[token] = counts;
        emit UpdateCountsToAddRewards(token, counts);
    }

    /**
     * @notice Set the ratio of the rawards pool fee in the referral fee
     * @dev Only owner can call this function
     * @dev Emit the UpdateProtocolInReferralFee event
     * @param newProtocolInReferralFee The percentage
     */
    function setProtocolInReferralFee(uint256 newProtocolInReferralFee)
        external
        override
        onlyOwner
    {
        require(newProtocolInReferralFee < RATE_DENOMINATOR, "invalid params");
        protocolInReferralFee = newProtocolInReferralFee;
        emit UpdateProtocolInReferralFee(newProtocolInReferralFee);
    }

    /**
     * @notice Set the maximum ratio of the total free amount
     * in a token pool that will be paid out at one time
     * @dev Only owner can call this function
     * @dev Emit the UpdateMaxPrizeRate event
     * @param newMaxPrizeRate The maximun ratio
     */
    function setMaxPrizeRate(uint256 newMaxPrizeRate)
        external
        override
        onlyOwner
    {
        require(newMaxPrizeRate < RATE_DENOMINATOR, "invalid params");
        maxPrizeRate = newMaxPrizeRate;
        emit UpdateMaxPrizeRate(newMaxPrizeRate);
    }

    /**
     * @notice Set the address of the random engine contract
     * @dev Only owner can call this function
     * @dev Emit the UpdateRandomEngine event
     * @param newRandomEngine The address of random engine
     */
    function setRandomEngine(address newRandomEngine)
        external
        override
        onlyOwner
    {
        randomEngine = newRandomEngine;
        emit UpdateRandomEngine(newRandomEngine);
    }

    /**
     * @notice Set the address of the rewards pool contract
     * @dev Only owner can call this function
     * @dev Emit the UpdateRewardsPool event
     * @param newRewardsPool The address of rewards pool
     */
    function setRewardsPool(address newRewardsPool)
        external
        override
        onlyOwner
    {
        rewardsPool = newRewardsPool;
        emit UpdateRewardsPool(newRewardsPool);
    }

    /**
     * @notice Enable or disable a game contract to call token pools
     * @dev Only owner can call this function
     * @dev Emit the SetGame event
     * @param game The address of game contract
     * @param enable Whether to enable or disable
     */
    function setGame(address game, bool enable) external onlyOwner {
        isValidCaller[game] = enable;
        IRandomEngine(randomEngine).setCaller(game, enable);

        emit SetGame(game, enable);
    }

    /**
     * @notice Query the number of times the specified token pool
     * receive rewards before adding rewards to rewards pool.
     * @param token the specified token address
     * @return the number of times
     */
    function countsToAddRewards(address token)
        external
        view
        override
        returns (uint256)
    {
        uint256 counts = countsToAddRewardsMap[token];
        if (counts == 0) {
            counts = defaultCountsToAddRewards;
        }
        return counts;
    }
}
