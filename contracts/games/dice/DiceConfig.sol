// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import "../../interfaces/IDiceConfig.sol";

import "./DiceStorage.sol";

/**
 * @title DiceConfig contract
 * @author Debet
 * @notice Configuration of the Dice contract
 */
abstract contract DiceConfig is IDiceConfig, DiceStorage {
    /**
     * @notice Set the gas limit in callback function
     * @dev Emit the UpdateCallbackGasLimit event
     * @dev Only owner can call this function
     * @param newCallbackGasLimit The gas limit in callback function
     */
    function setCallbackGasLimit(uint32 newCallbackGasLimit)
        external
        override
        onlyOwner
    {
        callbackGasLimit = newCallbackGasLimit;
        emit UpdateCallbackGasLimit(newCallbackGasLimit);
    }

    /**
     * @notice Set the cancel period
     * @dev Emit the UpdateCancelPeriod event
     * @dev Only owner can call this function
     * @dev Users can cancel their bets if there is no
     * draw after the cancellation time
     * @param newCancelPeriod The cancel period
     */
    function setCancelPeriod(uint256 newCancelPeriod)
        external
        override
        onlyOwner
    {
        cancelPeriod = newCancelPeriod;
        emit UpdateCancelPeriod(newCancelPeriod);
    }

    /**
     * @notice Set the ratio of referral fees in bet amount
     * @dev Emit the UpdateReferralFeeRate event
     * @dev Only owner can call this function
     * @param newReferralFeeRate The ratio of referral fees in bet amount
     */
    function setReferralFeeRate(uint256 newReferralFeeRate)
        external
        override
        onlyOwner
    {
        require(newReferralFeeRate < RATE_DENOMINATOR, "invalid params");
        referralFeeRate = newReferralFeeRate;
        emit UpdateReferralFeeRate(newReferralFeeRate);
    }

    /**
     * @notice Set the advantage ratio of the banker in the game
     * @dev Emit the UpdateBankerAdvantageFeeRate event
     * @dev Only owner can call this function
     * @param newBankerAdvantageFeeRate The advantage ratio of the banker in the game
     */
    function setBankerAdvantageFeeRate(uint256 newBankerAdvantageFeeRate)
        external
        override
        onlyOwner
    {
        require(newBankerAdvantageFeeRate < RATE_DENOMINATOR, "invalid params");
        bankerAdvantageFeeRate = newBankerAdvantageFeeRate;
        emit UpdateBankerAdvantageFeeRate(newBankerAdvantageFeeRate);
    }
}
