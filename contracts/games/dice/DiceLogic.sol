// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import "../../interfaces/IDiceLogic.sol";
import "../../interfaces/IRandomEngine.sol";
import "../../interfaces/IFactory.sol";
import "../../interfaces/IPool.sol";
import "../../interfaces/external/INativeWrapper.sol";

import "./DiceStorage.sol";

/**
 * @title DiceLogic contract
 * @author Debet
 * @notice Core logic functions of the Dice contract
 */
abstract contract DiceLogic is IDiceLogic, DiceStorage {
    using SafeERC20 for IERC20;

    receive() external payable {}

    /**
     * @notice Player can bet ERC20 token in this function
     * @dev Emit the Bet event
     * @param token The address of the underlying token
     * @param amount The amount od token to bet in the game
     * @param referrer The address of referrer who recommends player to bet
     * @param number The number player bet on
     * @param direction The direction of the bet (0 for UNDER, 1 for OVER)
     * UNDER means the user wins when the lucky number is less than the number the user bet on
     * OVER  means the user wins when the lucky number is greater than the number the user bet on
     */
    function bet(
        address token,
        uint256 amount,
        address referrer,
        uint256 number,
        Direction direction
    ) external payable override nonReentrant {
        address pool = IFactory(factory).tokenPools(token);
        require(pool != address(0), "this token pool is no exists");

        IERC20(token).safeTransferFrom(msg.sender, pool, amount);

        _bet(pool, amount, msg.value, referrer, number, direction, false);
    }

    /**
     * @notice Player can bet native token in this function
     * @dev Emit the Bet event
     * @param amount The amount of native token to bet in the game
     * @param referrer The address of referrer who recommends player to bet
     * @param number The number player bet on
     * @param direction The direction of the bet (0 for UNDER, 1 for OVER)
     * UNDER means the user wins when the lucky number is less than the number the user bet on
     * OVER  means the user wins when the lucky number is greater than the number the user bet on
     */
    function betNativeToken(
        uint256 amount,
        address referrer,
        uint256 number,
        Direction direction
    ) external payable override nonReentrant {
        address pool = IFactory(factory).tokenPools(nativeWrapper);
        require(pool != address(0), "this token pool is no exists");

        require(msg.value >= amount, "insufficient bet amount");
        INativeWrapper(nativeWrapper).deposit{value: amount}();
        IERC20(nativeWrapper).safeTransfer(pool, amount);

        uint256 gasAmount = msg.value - amount;
        _bet(pool, amount, gasAmount, referrer, number, direction, true);
    }

    /**
     * @notice Anyone can cancel a game that has not been drawn within the cancellation period
     * @dev Emit the Cancel event
     * @param requestId The id of the game which is requested to cancel
     */
    function cancel(uint256 requestId) external override nonReentrant {
        Game memory game = games[requestId];

        require(
            game.status == GameStatus.PENDING,
            "game has been canceled or rolled"
        );

        require(
            block.timestamp >= game.betTime + cancelPeriod,
            "it's not time to cancel yet"
        );

        _cancel(requestId, game);
    }

    /**
     * @notice Roll for a game
     * @dev Emit the Roll event
     * @dev Only random engine contract can call this function
     * @param requestId The id of the game which is rolled
     * @param randomWords The random works array (only 1 element in the array)
     * @param rewards The amount of random engine rewards
     */
    function callback(
        uint256 requestId,
        uint256[] memory randomWords,
        uint256 rewards
    ) external override nonReentrant {
        require(
            msg.sender == address(IFactory(factory).randomEngine()),
            "caller is not random engine"
        );
        _callback(requestId, randomWords, rewards);
    }

    /**
     * @notice Get the sepecified game information by requestId
     * @param requestId The id of the game
     * @return gameInfo The game information
     */
    function getGameInfo(uint256 requestId)
        external
        view
        override
        returns (GameInfo memory gameInfo)
    {
        gameInfo.game = games[requestId];
        IPool pool = IPool(gameInfo.game.pool);
        gameInfo.lock = pool.lockInfo(gameInfo.game.gameId);
    }

    /**
     * @notice get the amount of native token required as gas when player bet
     * @param gasPriceWei Estimated gas price at time of request
     * @return Amount of native token required
     */
    function calculateGasRequired(uint256 gasPriceWei)
        external
        view
        override
        returns (uint256)
    {
        IRandomEngine randomEngine = IRandomEngine(
            IFactory(factory).randomEngine()
        );
        return
            randomEngine.calculateNativeTokenRequired(
                uint32(callbackGasLimit),
                gasPriceWei
            );
    }

    function _bet(
        address pool,
        uint256 amount,
        uint256 gasAmount,
        address referrer,
        uint256 number,
        Direction direction,
        bool isNativeToken
    ) internal {
        IRandomEngine randomEngine = IRandomEngine(
            IFactory(factory).randomEngine()
        );

        _verifyBetParams(referrer, amount, number, direction);
        PoolType.BetAmountInfo memory betAmountInfo = _calculateAmount(
            amount,
            number,
            direction
        );

        uint256 gameId = IPool(pool).receiveAndLock(
            msg.sender,
            referrer,
            betAmountInfo
        );

        uint256 requestId = randomEngine.request{value: gasAmount}(
            callbackGasLimit,
            1,
            msg.sender
        );

        Game memory game = Game(
            requestId,
            gameId,
            pool,
            msg.sender,
            block.timestamp,
            number,
            0,
            direction,
            GameResult.LOSE,
            GameStatus.PENDING,
            isNativeToken
        );
        games[requestId] = game;

        emit Bet(msg.sender, requestId);
    }

    function _verifyBetParams(
        address referrer,
        uint256 amount,
        uint256 number,
        Direction direction
    ) internal view {
        require(referrer != msg.sender, "the referrer cannot be yourself");
        require(amount > 0, "need non-zero amount");

        if (direction == Direction.UNDER) {
            // 1-99
            require(number > 0 && number < MAX_NUMBER, "invalid bet number ");
        } else {
            // 0-98
            require(number < MAX_NUMBER - 1, "invalid bet number");
        }
    }

    function _calculateAmount(
        uint256 amount,
        uint256 number,
        Direction direction
    ) internal view returns (PoolType.BetAmountInfo memory betAmountInfo) {
        betAmountInfo.totalBetAmount = amount;
        betAmountInfo.referralFee =
            (amount * referralFeeRate) /
            RATE_DENOMINATOR;
        betAmountInfo.actualBetAmount = amount - betAmountInfo.referralFee;

        uint256 probabilityOfPool;
        uint256 probabilityOfUser;
        uint256 userRate = RATE_DENOMINATOR - bankerAdvantageFeeRate;

        if (direction == Direction.UNDER) {
            probabilityOfPool = MAX_NUMBER - number;
            probabilityOfUser = number;
        } else {
            probabilityOfPool = number + 1;
            probabilityOfUser = MAX_NUMBER - number - 1;
        }

        betAmountInfo.frozenPoolAmount =
            (betAmountInfo.actualBetAmount * probabilityOfPool * userRate) /
            (probabilityOfUser * RATE_DENOMINATOR);
    }

    function _cancel(uint256 requestId, Game memory game) internal {
        game.status = GameStatus.CANCELLED;
        games[requestId] = game;

        if (!game.isNativeToken) {
            IPool(game.pool).releaseAndSend(
                game.gameId,
                PoolType.GameResult.CANCEL,
                game.player
            );
        } else {
            uint256 amount = IPool(game.pool).releaseAndSend(
                game.gameId,
                PoolType.GameResult.CANCEL,
                address(this)
            );
            INativeWrapper(nativeWrapper).withdraw(amount);
            (bool success, ) = payable(game.player).call{
                value: amount,
                gas: 8000
            }("");
            require(success, "transfer native token failed");
        }

        emit Cancel(requestId);
    }

    function _callback(
        uint256 requestId,
        uint256[] memory randomWords,
        uint256 rewards
    ) internal {
        Game memory game = games[requestId];
        require(
            game.status == GameStatus.PENDING,
            "game has been canceled or rolled"
        );

        game.status = GameStatus.ROOLED;
        game.luckyNumber = randomWords[0] % MAX_NUMBER;
        if (game.direction == Direction.UNDER) {
            game.result = game.luckyNumber < game.betNumber
                ? GameResult.WIN
                : GameResult.LOSE;
        } else {
            game.result = game.luckyNumber > game.betNumber
                ? GameResult.WIN
                : GameResult.LOSE;
        }
        games[requestId] = game;

        PoolType.GameResult result = (game.result == GameResult.WIN)
            ? PoolType.GameResult.WIN
            : PoolType.GameResult.LOSE;

        uint256 totalPrize;
        if (!game.isNativeToken) {
            totalPrize = IPool(game.pool).releaseAndSend(
                game.gameId,
                result,
                game.player
            );
        } else {
            totalPrize = IPool(game.pool).releaseAndSend(
                game.gameId,
                result,
                address(this)
            );
            if (totalPrize > 0) {
                INativeWrapper(nativeWrapper).withdraw(totalPrize);
                (bool success, ) = payable(game.player).call{
                    value: totalPrize,
                    gas: 8000
                }("");
                require(success, "transfer native token failed");
            }
        }

        emit Roll(
            requestId,
            game.luckyNumber,
            game.result,
            totalPrize,
            rewards
        );
    }
}
