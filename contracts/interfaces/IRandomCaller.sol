// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

interface IRandomCaller {
    function callback(
        uint256 requestId,
        uint256[] memory randomWords,
        uint256 rewards
    ) external;
}
