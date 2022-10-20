// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

import "../../interfaces/IPool.sol";
import "../../interfaces/IFactory.sol";
import "../../interfaces/IStakingPool.sol";

import "../../utils/DebetBase.sol";

/**
 * @title Pool contract
 * @author Debet
 * @notice Template used to create the token pool in factory contract
 */
contract Pool is IPool, ReentrancyGuard, ERC20, DebetBase {
    using SafeERC20 for IERC20;

    /// @notice The underlying token address
    address public immutable override token;
    /// @notice The factory contract address
    address public immutable override factory;

    /// @notice Counter for the number of requests
    uint256 public override poolId;
    /// @notice Total amount of token in the pool
    uint256 public override totalAmount;
    /// @notice Amount of the current rewards in the pool
    uint256 public override totalRewards;
    /// @notice Number of times the pool receive rewards
    uint256 public override addRewardsCounts;

    PoolInfo internal _poolInfo;
    mapping(uint256 => LockInfo) internal _lockInfo;

    /**
     * @dev Only factory contract can call functions marked by this modifier.
     **/
    modifier onlyFactory() {
        require(msg.sender == factory, "forbidden");
        _;
    }

    /**
     * @dev Only valid caller in factory can call functions marked by this modifier.
     **/
    modifier onlyValidCaller() {
        require(IFactory(factory).isValidCaller(msg.sender), "invalid caller");
        _;
    }

    /**
     * @dev Constructor.
     * @param _token The address of the underlying token
     */
    constructor(address _token)
        ERC20(
            string.concat("Debet ", IERC20Metadata(_token).name(), " Pool"),
            string.concat("DBP-", IERC20Metadata(_token).symbol())
        )
    {
        factory = msg.sender;
        token = _token;
    }

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
        override
        onlyFactory
        nonReentrant
        returns (uint256 receivedAmount, uint256 share)
    {
        PoolInfo memory tempPoolInfo = _poolInfo;
        receivedAmount = _receive();
        require(receivedAmount > 0, "need none-zero amount");

        uint256 totalPoolAmount = tempPoolInfo.freeAmount +
            tempPoolInfo.frozenAmount;
        if (totalPoolAmount == 0) {
            share = receivedAmount;
        } else {
            share = (receivedAmount * totalSupply()) / totalPoolAmount;
        }

        tempPoolInfo.freeAmount += receivedAmount;
        _poolInfo = tempPoolInfo;

        _mint(banker, share);

        emit Mint(banker, receivedAmount, share);
    }

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
    )
        external
        override
        onlyFactory
        nonReentrant
        returns (uint256 withdrawAmount)
    {
        require(share > 0, "need non-zero share amount");

        uint256 totalShare = totalSupply();
        _burn(banker, share);

        PoolInfo memory tempPoolInfo = _poolInfo;
        uint256 totalPoolAmount = tempPoolInfo.freeAmount +
            tempPoolInfo.frozenAmount;

        withdrawAmount = (totalPoolAmount * share) / totalShare;
        require(
            withdrawAmount <= tempPoolInfo.freeAmount,
            "insufficient free amount to withdraw"
        );

        tempPoolInfo.freeAmount -= withdrawAmount;
        _poolInfo = tempPoolInfo;

        _sendout(receiver, withdrawAmount);

        emit Burn(banker, withdrawAmount, share);
    }

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
    ) external override onlyValidCaller nonReentrant returns (uint256 gameId) {
        uint256 actualReceiveAmount = _receive();
        require(actualReceiveAmount > 0, "need none-zero receive amount");

        if (actualReceiveAmount < betAmountInfo.totalBetAmount) {
            betAmountInfo.actualBetAmount =
                (betAmountInfo.actualBetAmount * actualReceiveAmount) /
                betAmountInfo.totalBetAmount;
            betAmountInfo.referralFee =
                actualReceiveAmount -
                betAmountInfo.actualBetAmount;
            betAmountInfo.frozenPoolAmount =
                (betAmountInfo.frozenPoolAmount * actualReceiveAmount) /
                betAmountInfo.totalBetAmount;
        }

        gameId = ++poolId;
        _lockInfo[gameId] = LockInfo(
            gameId,
            player,
            referrer,
            betAmountInfo.actualBetAmount,
            betAmountInfo.referralFee,
            0,
            betAmountInfo.frozenPoolAmount,
            false,
            GameResult.LOSE
        );

        _lock(betAmountInfo.frozenPoolAmount);

        emit ReceiveAndLock(
            player,
            gameId,
            actualReceiveAmount,
            betAmountInfo.frozenPoolAmount
        );
    }

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
    )
        external
        override
        onlyValidCaller
        nonReentrant
        returns (uint256 totalPrize)
    {
        require(gameId > 0 && gameId <= poolId, "invalid game id");

        LockInfo memory tempLockinfo = _lockInfo[gameId];
        require(!tempLockinfo.handled, "the game has been handled already");

        PoolInfo memory tempPoolInfo = _poolInfo;

        tempPoolInfo.frozenAmount -= tempLockinfo.frozenPoolAmount;

        uint256 rewardsFee;
        uint256 referralFee;
        if (result == GameResult.LOSE) {
            tempPoolInfo.freeAmount =
                tempPoolInfo.freeAmount +
                tempLockinfo.frozenPoolAmount +
                tempLockinfo.betAmount;
            (referralFee, rewardsFee) = _sendReferralFee(
                tempLockinfo.referrer,
                tempLockinfo.referralFee
            );
        } else if (result == GameResult.WIN) {
            totalPrize = tempLockinfo.betAmount + tempLockinfo.frozenPoolAmount;
            _sendout(receiver, totalPrize);
            (referralFee, rewardsFee) = _sendReferralFee(
                tempLockinfo.referrer,
                tempLockinfo.referralFee
            );
        } else {
            tempPoolInfo.freeAmount =
                tempPoolInfo.freeAmount +
                tempLockinfo.frozenPoolAmount;
            totalPrize = tempLockinfo.betAmount + tempLockinfo.referralFee;
            _sendout(receiver, totalPrize);
        }

        _poolInfo = tempPoolInfo;

        if (rewardsFee > 0) {
            tempLockinfo.rewardsFee = rewardsFee;
            tempLockinfo.referralFee -= rewardsFee;
        }
        tempLockinfo.handled = true;
        tempLockinfo.result = result;
        _lockInfo[gameId] = tempLockinfo;

        emit ReleaseAndSend(gameId, result);
    }

    /**
     * @notice Get the information of this pool
     * @return The information of this pool
     */
    function poolInfo() external view override returns (PoolInfo memory) {
        return _poolInfo;
    }

    /**
     * @notice Get the lock information of a sepecified request
     * @param gameId The id of the sepecified request in this pool
     */
    function lockInfo(uint256 gameId)
        external
        view
        override
        returns (LockInfo memory)
    {
        return _lockInfo[gameId];
    }

    // ============================= helper functions =============================== //

    function _lock(uint256 amount) internal onlyValidCaller {
        PoolInfo memory tempPoolInfo = _poolInfo;

        uint256 maxPrize = (tempPoolInfo.freeAmount *
            IFactory(factory).maxPrizeRate()) / RATE_DENOMINATOR;
        require(amount <= maxPrize, "the prize amount exceeds the limit");

        tempPoolInfo.freeAmount -= amount;
        tempPoolInfo.frozenAmount += amount;
        _poolInfo = tempPoolInfo;
    }

    function _sendReferralFee(address referrer, uint256 referralFee)
        internal
        returns (uint256, uint256)
    {
        uint256 rewardsFee = referralFee;

        if (referrer != address(0)) {
            rewardsFee =
                (referralFee * IFactory(factory).protocolInReferralFee()) /
                RATE_DENOMINATOR;

            referralFee -= rewardsFee;
            _sendout(referrer, referralFee);
        }

        if (rewardsFee > 0) {
            totalRewards += rewardsFee;
            addRewardsCounts += 1;
            if (
                IFactory(factory).rewardsPool() != address(0) &&
                addRewardsCounts >= IFactory(factory).countsToAddRewards(token)
            ) {
                _sendToRewardsPool();
                addRewardsCounts = 0;
            }
        }

        return (referralFee, rewardsFee);
    }

    function _sendToRewardsPool() internal {
        address rewardsPool = IFactory(factory).rewardsPool();
        uint256 currentRewards = totalRewards;

        if (
            IERC20(token).allowance(address(this), rewardsPool) < currentRewards
        ) {
            IERC20(token).safeApprove(rewardsPool, 0);
            IERC20(token).safeApprove(rewardsPool, type(uint256).max);
        }

        IStakingPool(IFactory(factory).rewardsPool()).addRewards(
            token,
            currentRewards
        );

        totalRewards = 0;
    }

    function _receive() internal returns (uint256 received) {
        uint256 balance = IERC20(token).balanceOf(address(this));
        received = balance - totalAmount;
        totalAmount = balance;
    }

    function _sendout(address to, uint256 amount) internal {
        IERC20(token).safeTransfer(to, amount);
        totalAmount -= amount;
    }
}
