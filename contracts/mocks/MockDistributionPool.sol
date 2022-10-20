// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract MockDistributionPool {
    uint256 public constant REWARDS_MULTIPLIER_RANGE = 100;

    address public randomEngine;
    address public rewardsToken;
    uint256 public baseRewardsAmount;

    event Distribute(address game, address receiver, uint256 amount);

    function initialize(
        address _rewardsToken,
        address _randomEngine,
        uint256 _baseRewardsAmount
    ) external {
        require(rewardsToken == address(0), "initialized");
        rewardsToken = _rewardsToken;
        randomEngine = _randomEngine;
        baseRewardsAmount = _baseRewardsAmount;
    }

    function distribute(
        address game,
        address receiver,
        uint256 randomWord
    ) external returns (uint256) {
        uint256 rewardsMultiplier = (randomWord % REWARDS_MULTIPLIER_RANGE) + 1;
        uint256 amount = baseRewardsAmount * rewardsMultiplier;

        uint256 balance = IERC20(rewardsToken).balanceOf(address(this));
        if (balance < amount) {
            amount = balance;
        }

        IERC20(rewardsToken).transfer(receiver, amount);

        emit Distribute(game, receiver, amount);

        return amount;
    }
}
