// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import "./DiceType.sol";

/**
 * @title IDiceStorage interface
 * @author Debet
 * @notice The interface for DiceStorage
 */
interface IDiceStorage is DiceType {
    /**
     * @notice Get the gas limit in callback function
     * @return The gas limit in callback function
     */
    function callbackGasLimit() external view returns (uint32);

    /**
     * @notice Get the cancel period
     * @dev Users can cancel their bets if there is no  ddraw after the cancellation time
     * @return The cancel period
     */
    function cancelPeriod() external view returns (uint256);

    /**
     * @notice Get the ratio of referral fees in bet amount
     * @return The ratio of referral fees in bet amount
     */
    function referralFeeRate() external view returns (uint256);

    /**
     * @notice Get the advantage ratio of the banker in the game
     * @return The advantage ratio of the banker in the game
     */
    function bankerAdvantageFeeRate() external view returns (uint256);

    /**
     * @notice Get the address of factory contract
     * @return The address of factory contract
     */
    function factory() external view returns (address);

    /**
     * @notice Get the address of wrapped native token contract
     * @return The address of wrapped native token contract
     */
    function nativeWrapper() external view returns (address);
}
