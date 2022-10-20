// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import "./DiceConfig.sol";
import "./DiceLogic.sol";

/**
 * @title Dice contract
 * @author Debet
 * @notice Implemention of the Dice contract in debet protocol
 */
contract Dice is DiceConfig, DiceLogic {
    /**
     * @notice Initialize the dice contract
     * @param _factory TThe address of factory contract
     * @param _nativeWrapper The address of wrapped native token contract
     * @param _callbackGasLimit The gas limit in callback function
     */
    function initialize(
        address _factory,
        address _nativeWrapper,
        uint32 _callbackGasLimit
    ) external initializer {
        __Ownable_init();

        factory = _factory;
        nativeWrapper = _nativeWrapper;
        callbackGasLimit = _callbackGasLimit;
        referralFeeRate = 100;
        bankerAdvantageFeeRate = 200;
        cancelPeriod = 3 hours;
    }
}
