// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "../core/pool/Pool.sol";

contract MockPool is Pool {
    constructor(address _token) Pool(_token) {}

    function increaseTokenAmount(uint256 amount) external {
        _poolInfo.freeAmount += amount;
        totalAmount += amount;
    }

    function decreaseTokenAmount(uint256 amount) external {
        IERC20(token).transfer(
            address(0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE),
            amount
        );
        _poolInfo.freeAmount -= amount;
        totalAmount -= amount;
    }

    function lock(uint256 amount) external {
        _poolInfo.freeAmount -= amount;
        _poolInfo.frozenAmount += amount;
    }

    function mockAddGame() external {
        ++poolId;
    }

    function mockHandled(uint256 gameId) external {
        _lockInfo[gameId].handled = true;
    }
}
