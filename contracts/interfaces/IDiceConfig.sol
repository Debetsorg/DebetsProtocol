// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

/**
 * @title IDiceConfig interface
 * @author Debet
 * @notice The interface for DiceConfig
 */
interface IDiceConfig {
    /**
     * @dev Emit on setCallbackGasLimit function
     * @param newCallbackGasLimit The gas limit in callback function
     */
    event UpdateCallbackGasLimit(uint32 newCallbackGasLimit);

    /**
     * @dev Emit on setCancelPeriod function
     * @param newCancelPeriod The cancel period
     */
    event UpdateCancelPeriod(uint256 newCancelPeriod);

    /**
     * @dev Emit on setReferralFeeRate function
     * @param newReferralFeeRate The ratio of referral fees in bet amount
     */
    event UpdateReferralFeeRate(uint256 newReferralFeeRate);

    /**
     * @dev Emit on setBankerAdvantageFeeRate function
     * @param newBankerAdvantageFeeRate The advantage ratio of the banker in the game
     */
    event UpdateBankerAdvantageFeeRate(uint256 newBankerAdvantageFeeRate);

    /**
     * @notice Set the gas limit in callback function
     * @dev Emit the UpdateCallbackGasLimit event
     * @dev Only owner can call this function
     * @param newCallbackGasLimit The gas limit in callback function
     */
    function setCallbackGasLimit(uint32 newCallbackGasLimit) external;

    /**
     * @notice Set the cancel period
     * @dev Emit the UpdateCancelPeriod event
     * @dev Only owner can call this function
     * @dev Users can cancel their bets if there is no
     * draw after the cancellation time
     * @param newCancelPeriod The cancel period
     */
    function setCancelPeriod(uint256 newCancelPeriod) external;

    /**
     * @notice Set the ratio of referral fees in bet amount
     * @dev Emit the UpdateReferralFeeRate event
     * @dev Only owner can call this function
     * @param newReferralFeeRate The ratio of referral fees in bet amount
     */
    function setReferralFeeRate(uint256 newReferralFeeRate) external;

    /**
     * @notice Set the advantage ratio of the banker in the game
     * @dev Emit the UpdateBankerAdvantageFeeRate event
     * @dev Only owner can call this function
     * @param newBankerAdvantageFeeRate The advantage ratio of the banker in the game
     */
    function setBankerAdvantageFeeRate(uint256 newBankerAdvantageFeeRate)
        external;
}
