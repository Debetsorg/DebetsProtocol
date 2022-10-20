// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

import "../../interfaces/IFactoryStorage.sol";

import "../../utils/DebetBase.sol";

/**
 * @title FactoryStorage contract
 * @author Debet
 * @notice Storage of the factory contract
 */
abstract contract FactoryStorage is
    IFactoryStorage,
    OwnableUpgradeable,
    ReentrancyGuard,
    DebetBase
{
    uint256 internal defaultCountsToAddRewards;

    /// @notice The maximum ratio of pool free amount to payout
    uint256 public override maxPrizeRate;
    ///@notice The ratio of the rawards pool fee in the referral fee
    uint256 public override protocolInReferralFee;
    /// @notice The address of the random engine contract
    address public override randomEngine;
    /// @notice The address of the rewards pool contract
    address public override rewardsPool;
    /// @notice The address of the wrapped native token contract
    address public nativeWrapper;

    /// @notice The mapping from token address to token pool address
    mapping(address => address) public override tokenPools;
    /// @notice The mapping from game address to whether avaliable or not
    mapping(address => bool) public override isValidCaller;
    mapping(address => uint256) internal countsToAddRewardsMap;
}
