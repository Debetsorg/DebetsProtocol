// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import "./IFactoryStorage.sol";
import "./IFactoryConfig.sol";
import "./IFactoryLogic.sol";

/**
 * @title IFactory interface
 * @author Debet
 * @notice The interface for Factory
 */
interface IFactory is IFactoryStorage, IFactoryConfig, IFactoryLogic {

}
