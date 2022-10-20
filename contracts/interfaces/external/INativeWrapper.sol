// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

interface INativeWrapper {
    function deposit() external payable;

    function withdraw(uint256) external;
}
