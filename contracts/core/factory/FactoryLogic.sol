// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import "../../interfaces/IFactoryLogic.sol";
import "../../interfaces/external/INativeWrapper.sol";

import "./FactoryStorage.sol";
import "../pool/Pool.sol";

/**
 * @title FactoryLogic contract
 * @author Debet
 * @notice Core logic functions of the factory contract
 */
abstract contract FactoryLogic is IFactoryLogic, FactoryStorage {
    using SafeERC20 for IERC20;

    receive() external payable {}

    /**
     * @notice Add liquidity to a specified token pool
     * @dev Emit the Mint event
     * @param token The specified roken address
     * @param amount Amount of the token
     */
    function mint(address token, uint256 amount) external nonReentrant {
        address pool = tokenPools[token];
        if (pool == address(0)) {
            pool = _createPool(token);
        }

        IERC20(token).safeTransferFrom(msg.sender, pool, amount);

        (uint256 actualAmount, uint256 share) = IPool(pool).mint(msg.sender);

        emit Mint(pool, msg.sender, token, actualAmount, share);
    }

    /**
     * @notice Add liquidity to the wrapped native token pool
     * with native token
     * @dev Emit the Mint event
     */
    function mintNative() external payable nonReentrant {
        address pool = tokenPools[nativeWrapper];
        if (pool == address(0)) {
            pool = _createPool(nativeWrapper);
        }

        uint256 amount = msg.value;
        INativeWrapper(nativeWrapper).deposit{value: amount}();
        IERC20(nativeWrapper).safeTransfer(pool, amount);

        (uint256 actualAmount, uint256 share) = IPool(pool).mint(msg.sender);

        emit Mint(pool, msg.sender, nativeWrapper, actualAmount, share);
    }

    /**
     * @notice remove liquidity from the sepecified token pool
     * @dev Emit the Burn event
     * @param token The sepecified token address
     * @param share The amount of the token pool share
     */
    function burn(address token, uint256 share) external nonReentrant {
        address pool = tokenPools[token];
        require(pool != address(0), "this pool is not exists");

        uint256 amount = IPool(pool).burn(msg.sender, share, msg.sender);

        emit Burn(pool, msg.sender, token, amount, share);
    }

    /**
     * @notice Remove liquidity from the wrapped native token pool
     * and reveive the native token
     * @dev Emit the Burn event
     * @param share The amount of the token pool share
     */
    function burnNative(uint256 share) external nonReentrant {
        address pool = tokenPools[nativeWrapper];
        require(pool != address(0), "this pool is not exists");

        uint256 amount = IPool(pool).burn(msg.sender, share, address(this));
        INativeWrapper(nativeWrapper).withdraw(amount);
        (bool success, ) = payable(msg.sender).call{value: amount, gas: 8000}(
            ""
        );
        require(success, "transfer native token failed");

        emit Burn(pool, msg.sender, nativeWrapper, amount, share);
    }

    /**
     * @notice create a new token pool
     * @dev Emit the CreatePool event
     * @param token The address of the token
     */
    function createPool(address token) external override nonReentrant {
        _createPool(token);
    }

    /**
     * @notice query the token pool address by token address
     * @param token The address of the token
     * @return poolInfo The information of the specified token pool
     */
    function getPoolInfo(address token)
        external
        view
        returns (PoolType.PoolInfo memory poolInfo)
    {
        address pool = tokenPools[token];
        if (pool != address(0)) {
            poolInfo = IPool(pool).poolInfo();
        }
    }

    function _createPool(address token) internal returns (address pool) {
        pool = tokenPools[token];
        require(pool == address(0), "this pool has been created already");

        bytes32 salt = keccak256(abi.encodePacked(token));
        pool = address(new Pool{salt: salt}(token));

        tokenPools[token] = pool;

        emit CreatePool(token, pool);
    }
}
