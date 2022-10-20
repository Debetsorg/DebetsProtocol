// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import "./PoolType.sol";

/**
 * @title IFactoryLogic interface
 * @author Debet
 * @notice The interface for FactoryLogic
 */
interface IFactoryLogic {
    /**
     * @dev Emit on createPool function
     * @param token The address of underlying token
     * @param pool The address of new pool
     */
    event CreatePool(address token, address pool);

    /**
     * @dev Emit on mint and mintNative function
     * @param pool The address of token pool
     * @param banker The address of user who add liquidity
     * @param token The address of underlying token
     * @param amount The amount of underlying token added to pool
     * @param share The amount of share in pool banker received
     */
    event Mint(
        address indexed pool,
        address indexed banker,
        address token,
        uint256 amount,
        uint256 share
    );

    /**
     * @dev Emit on burn and burnNative function
     * @param pool The address of token pool
     * @param banker The address of user who remove liquidity
     * @param token The address of underlying token
     * @param amount The amount of underlying token banker received
     * @param share The amount of share in pool banker burned
     */
    event Burn(
        address indexed pool,
        address indexed banker,
        address token,
        uint256 amount,
        uint256 share
    );

    /**
     * @notice Add liquidity to a specified token pool
     * @param token The specified roken address
     * @param amount Amount of the token
     */
    function mint(address token, uint256 amount) external;

    /**
     * @notice Add liquidity to the wrapped native token pool
     * with native token
     */
    function mintNative() external payable;

    /**
     * @notice remove liquidity from the sepecified token pool
     * @param token The sepecified token address
     * @param share The amount of the token pool share
     */
    function burn(address token, uint256 share) external;

    /**
     * @notice Remove liquidity from the wrapped native token pool
     * and reveive the native token
     * @param share The amount of the token pool share
     */
    function burnNative(uint256 share) external;

    /**
     * @notice create a new token pool
     * @param token The address of the token
     */
    function createPool(address token) external;

    /**
     * @notice query the token pool address by token address
     * @param token The address of the token
     * @return poolInfo The information of the specified token pool
     */
    function getPoolInfo(address token)
        external
        view
        returns (PoolType.PoolInfo memory poolInfo);
}
