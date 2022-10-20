// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import "./PoolType.sol";

interface DiceType {
    enum Direction {
        UNDER,
        OVER
    }

    enum GameStatus {
        PENDING,
        ROOLED,
        CANCELLED
    }

    enum GameResult {
        LOSE,
        WIN
    }

    struct Game {
        uint256 requestId;
        uint256 gameId;
        address pool;
        address player;
        uint256 betTime;
        uint256 betNumber;
        uint256 luckyNumber;
        Direction direction;
        GameResult result;
        GameStatus status;
        bool isNativeToken;
    }

    struct GameInfo {
        Game game;
        PoolType.LockInfo lock;
    }
}
