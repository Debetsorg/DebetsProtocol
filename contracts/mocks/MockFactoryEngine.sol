// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "../interfaces/IRandomCaller.sol";

contract MockFactoryEngine {
    uint256 private requestId;

    uint256 public gasRequired = 100_000_000;

    function setCaller(address game, bool enable) external {}

    function request(
        uint32 gas,
        uint32 counts,
        address receiver
    ) external payable returns (uint256) {
        gas;
        counts;
        receiver;
        return ++requestId;
    }

    function callback(
        address caller,
        uint256 _requestId,
        uint256[] memory randomWords,
        uint256 rewards
    ) external {
        IRandomCaller(caller).callback(_requestId, randomWords, rewards);
    }

    function calculateNativeTokenRequired(
        uint32 callbackGasLimit,
        uint256 gasPriceWei
    ) external view returns (uint256) {
        callbackGasLimit;
        gasPriceWei;
        return gasRequired;
    }
}
