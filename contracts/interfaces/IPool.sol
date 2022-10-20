// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import "./PoolType.sol";

/**
 * @title IPool interface
 * @author Debet
 * @notice The interface for pool contract
 */
interface IPool is PoolType {
    /**
     * @dev Emit on mint function
     * @param banker The address of user who add liquidity
     * @param tokenAmount The amount of underlying token banker added to pool
     * @param shareAmount The amount of share in token pool banker received
     */
    event Mint(
        address indexed banker,
        uint256 tokenAmount,
        uint256 shareAmount
    );

    /**
     * @dev Emit on burn function
     * @param banker The address of user who remove liquidity
     * @param tokenAmount The amount of underlying token banker received
     * @param shareAmount The amount of share in token pool banker burned
     */
    event Burn(
        address indexed banker,
        uint256 tokenAmount,
        uint256 shareAmount
    );

    /**
     * @dev Emit on receiveAndLock function
     * @param player The address of player
     * @param gameId The unique request id in the toke pool
     * @param received The amount od underlying token pool received actually
     * @param locked The amount of underlying token pool locked
     */
    event ReceiveAndLock(
        address indexed player,
        uint256 indexed gameId,
        uint256 received,
        uint256 locked
    );

    /**
     * @dev Emit on releaseAndSend function
     * @param gameId The unique request id in the toke pool
     * @param result The result of the sepecified game (0 for lose, 1 for success, 2 for cancel)
     */
    event ReleaseAndSend(uint256 indexed gameId, GameResult result);

    /**
     * @notice Add liquidity to this pool
     * @dev only the factory contract can call this function
     * @dev Emit the Mint event
     * @param banker The address of the user who added liquidity
     * @return receivedAmount The amount of token actual received by the pool
     * @return share The amount of the pool share that mint to user
     */
    function mint(address banker)
        external
        returns (uint256 receivedAmount, uint256 share);

    /**
     * @notice remove liquidity from this pool
     * @dev only the factory contract can call this function
     * @dev Emit the Burn event
     * @param banker The address of the user who removed liquidity
     * @param share The amount of pool share to burn
     * @param receiver The address of user that receive the return token
     * @return withdrawAmount The amount of token to return
     */
    function burn(
        address banker,
        uint256 share,
        address receiver
    ) external returns (uint256 withdrawAmount);

    /**
     * @notice Receive the bet amount of user and lock the payout amountof pool
     * @dev Only invalid game contract can call this function
     * @dev Emit the ReceiveAndLock event
     * @param player The address of the player
     * @param referrer The address of the referrer who recommends the user to play
     * @param betAmountInfo The information of bet
     * @return gameId The id of the request in this pool
     */
    function receiveAndLock(
        address player,
        address referrer,
        BetAmountInfo memory betAmountInfo
    ) external returns (uint256 gameId);

    /**
     * @notice Release the lock amount of pool and send the prize out if player win
     * @dev Only invalid game contract can call this function
     * @dev Emit the ReleaseAndSend event
     * @param gameId The id of the sepecified request in this pool
     * @param result The result of this game (0 for lose, 1 for success, 2 for cancel)
     * @param receiver The address of user that receive the prize if the game winner is player
     * @return totalPrize The amount of the prize to return
     */
    function releaseAndSend(
        uint256 gameId,
        GameResult result,
        address receiver
    ) external returns (uint256 totalPrize);

    /**
     * @notice Get the address of underlying token
     * @return The address of underlying token
     */
    function token() external view returns (address);

    /**
     * @notice Get the address of factory contract
     * @return The address of actory contract
     */
    function factory() external view returns (address);

    /**
     * @notice Get the curent pool id
     * @dev current pool id is also the amount of all requests
     * @return The curent pool id
     */
    function poolId() external view returns (uint256);

    /**
     * @notice Get the total amount of underlying token in the pool
     * @return The total amount of underlying token in the pool
     */
    function totalAmount() external view returns (uint256);

    /**
     * @notice Get the current rewards in the pool waiting to be added to rewards pool
     * @return The amount of current rewards in the pool
     */
    function totalRewards() external view returns (uint256);

    /**
     * @notice Get the number of times the pool receive rewards
     * @return The number of times the pool receive rewards
     */
    function addRewardsCounts() external view returns (uint256);

    /**
     * @notice Get the information of this pool
     * @return The information of this pool
     */
    function poolInfo() external view returns (PoolInfo memory);

    /**
     * @notice Get the lock information of a sepecified request
     * @param gameId The id of the sepecified request in this pool
     */
    function lockInfo(uint256 gameId) external view returns (LockInfo memory);
}
