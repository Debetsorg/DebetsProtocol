// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract MockStakingPool {
    using SafeERC20 for IERC20;

    event AddNativeRewards(uint256 rewards);
    event AddRewards(address token, uint256 rewards);

    bool public enableStake;

    function addNativeRewards() external payable {
        emit AddNativeRewards(msg.value);
    }

    function addRewards(address token, uint256 rewards) external {
        IERC20(token).safeTransferFrom(msg.sender, address(this), rewards);
        emit AddRewards(token, rewards);
    }
}
