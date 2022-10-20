// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import "./IDiceConfig.sol";
import "./IDiceLogic.sol";
import "./IDiceStorage.sol";

/**
 * @title IDice interface
 * @author Debet
 * @notice The interface for Dice
 */
interface IDice is IDiceStorage, IDiceConfig, IDiceLogic {

}
