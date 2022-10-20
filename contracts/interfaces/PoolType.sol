// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

interface PoolType {
    enum GameResult {
        LOSE,
        WIN,
        CANCEL
    }

    struct PoolInfo {
        uint256 freeAmount;
        uint256 frozenAmount;
    }

    struct BetAmountInfo {
        uint256 totalBetAmount;
        uint256 actualBetAmount;
        uint256 referralFee;
        uint256 frozenPoolAmount;
    }

    struct LockInfo {
        uint256 id;
        address player;
        address referrer;
        uint256 betAmount;
        uint256 referralFee;
        uint256 rewardsFee;
        uint256 frozenPoolAmount;
        bool handled;
        GameResult result;
    }
}
