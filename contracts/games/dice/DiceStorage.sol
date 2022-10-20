// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

import "../../interfaces/IDiceStorage.sol";

import "../../utils/DebetBase.sol";

/**
 * @title DiceStorage contract
 * @author Debet
 * @notice Storage of the Dice contract
 */
abstract contract DiceStorage is
    IDiceStorage,
    OwnableUpgradeable,
    ReentrancyGuard,
    DebetBase
{
    /// @notice The player must bet less than this value
    uint256 public constant MAX_NUMBER = 100;

    /// @notice The gas limit in callback function
    uint32 public override callbackGasLimit;
    /// @notice The cancel period
    uint256 public override cancelPeriod;
    /// @notice The ratio of referral fees in bet amount
    uint256 public override referralFeeRate;
    /// @notice The advantage ratio of the banker in the game
    uint256 public override bankerAdvantageFeeRate;
    /// @notice The address of factory contract
    address public override factory;
    /// @notice The address of wrapped native token contract
    address public override nativeWrapper;
    /// @notice The mapping from request id to record information of bet
    mapping(uint256 => Game) internal games;
}
