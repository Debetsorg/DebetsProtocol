// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

interface IDistributionPool {
    function distribute(
        address game,
        address receiver,
        uint256 randomWord
    ) external returns (uint256);
}
