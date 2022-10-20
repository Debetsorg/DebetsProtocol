// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "../games/dice/Dice.sol";

contract MockDice is Dice {
    function setGameStatue(uint256 requestId, GameStatus status) external {
        games[requestId].status = status;
    }

    function setGameBetTime(uint256 requestId, uint256 betTime) external {
        games[requestId].betTime = betTime;
    }
}
