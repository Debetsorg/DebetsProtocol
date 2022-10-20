// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "../core/engine/RandomEngine.sol";

contract MockRandomEngine is RandomEngine {
    constructor(
        address _linkToken,
        address _coordinator,
        address _linkNativeFeed,
        uint64 _linkPremium,
        bytes32 _keyHash
    )
        RandomEngine(
            _linkToken,
            _coordinator,
            _linkNativeFeed,
            _linkPremium,
            _keyHash
        )
    {}

    function mockFulfillRandomWords(
        uint256 requestId,
        uint256[] memory randomWords
    ) external {
        fulfillRandomWords(requestId, randomWords);
    }

    function setLastSwapTime(uint64 time) external {
        lastSwapTime = time;
    }
}
