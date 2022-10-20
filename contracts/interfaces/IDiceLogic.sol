// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import "./DiceType.sol";

/**
 * @title IDiceLogic interface
 * @author Debet
 * @notice The interface for DiceLogic
 */
interface IDiceLogic is DiceType {
    /**
     * @dev Emit on bet and betNativeToken function
     * @param player The address of the player
     * @param requestId The request id from chainlink vrf service
     */
    event Bet(address indexed player, uint256 requestId);

    /**
     * @dev Emit on callback function
     * @param requestId The id of the game which is rolled
     * @param luckyNumber The luckey number from random engine
     * @param result The result of the game (0 for lose, 1 for win)
     * @param totalPrize The amount of payout from pool (0 id user lose)
     * @param rewards The amount of random engine rewards
     */
    event Roll(
        uint256 indexed requestId,
        uint256 luckyNumber,
        GameResult result,
        uint256 totalPrize,
        uint256 rewards
    );

    /**
     * @dev Emit on cancel function
     * @param requestId The id of the game which is requested to cancel
     */
    event Cancel(uint256 requestId);

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
    ) external payable;

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
    ) external payable;

    /**
     * @notice Anyone can cancel a game that has not been drawn within the cancellation period
     * @dev Emit the Cancel event
     * @param requestId The id of the game which is requested to cancel
     */
    function cancel(uint256 requestId) external;

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
    ) external;

    /**
     * @notice Get the sepecified game information by requestId
     * @param requestId The id of the game
     * @return gameInfo The game information
     */
    function getGameInfo(uint256 requestId)
        external
        view
        returns (GameInfo memory gameInfo);

    /**
     * @notice get the amount of native token required as gas when player bet
     * @param gasPriceWei Estimated gas price at time of request
     * @return Amount of native token required
     */
    function calculateGasRequired(uint256 gasPriceWei)
        external
        view
        returns (uint256);
}
