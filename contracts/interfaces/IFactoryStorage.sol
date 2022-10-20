// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

/**
 * @title IFactoryStorage interface
 * @author Debet
 * @notice The interface for FactoryStorage
 */
interface IFactoryStorage {
    /**
     * @notice Get wether the address is a valid caller
     * @param caller The address of the caller
     * @return Wether the caller is valid or not
     */
    function isValidCaller(address caller) external view returns (bool);

    /**
     * @notice Get the ratio of the rawards pool fee in the referral fee
     * @return The ratio of the rawards pool fee in the referral fee
     */
    function protocolInReferralFee() external view returns (uint256);

    /**
     * @notice Get the maximum ratio of pool free amount to payout
     * @return The maximum ratio of pool free amount to payout
     */
    function maxPrizeRate() external view returns (uint256);

    /**
     * @notice Get the address of the rewards pool contract
     * @return The address of the rewards pool contract
     */
    function rewardsPool() external view returns (address);

    /**
     * @notice Get the address of the random engine contract
     * @return The address of the random engine contract
     */
    function randomEngine() external view returns (address);

    /**
     * @notice Get the address of the wrapped native token
     * @return The address of the wrapped native token
     */
    function nativeWrapper() external view returns (address);

    /**
     * @notice Get the token pool address by sepecified token address
     * @return pool The token pool address
     */
    function tokenPools(address token) external view returns (address pool);
}
