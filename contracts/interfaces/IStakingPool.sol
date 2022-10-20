// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

interface IStakingPool {
    function addRewards(address token, uint256 rewards) external;

    function addNativeRewards() external payable;
}
