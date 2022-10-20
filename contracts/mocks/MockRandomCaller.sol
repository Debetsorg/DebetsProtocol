// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "../interfaces/IRandomCaller.sol";
import "../interfaces/IRandomEngine.sol";

contract MockRandomCaller is IRandomCaller {
    address public randomEngine;
    uint32 public callbackGasLimit;

    uint256 public currentRequestId;

    event Callback(uint256 requestId, uint256[] randomWords, uint256 rewards);

    constructor(address _randomEngine, uint32 _callbackGasLimit) {
        randomEngine = _randomEngine;
        callbackGasLimit = _callbackGasLimit;
    }

    function request() external payable {
        currentRequestId = IRandomEngine(randomEngine).request{
            value: msg.value
        }(callbackGasLimit, 1, msg.sender);
    }

    function callback(
        uint256 requestId,
        uint256[] memory randomWords,
        uint256 rewards
    ) external {
        emit Callback(requestId, randomWords, rewards);
    }

    receive() external payable {}
}
