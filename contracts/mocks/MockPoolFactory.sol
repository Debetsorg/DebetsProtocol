// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "./MockPool.sol";

contract MockPoolFactory {
    address public pool;
    address public rewardsPool;
    uint256 public maxPrizeRate = 100;
    uint256 public protocolInReferralFee = 0;
    uint256 private defaltCountsToAddRewards = 100;
    mapping(address => bool) public isValidCaller;

    function setCaller(address caller, bool enable) external {
        isValidCaller[caller] = enable;
    }

    function setRewardsPool(address _rewardsPool) external {
        rewardsPool = _rewardsPool;
    }

    function createPool(address token) external {
        bytes32 salt = keccak256(abi.encodePacked(token));
        pool = address(new MockPool{salt: salt}(token));
    }

    function mint(
        address token,
        uint256 amount,
        address receiver
    ) external {
        IERC20(token).transfer(pool, amount);
        IPool(pool).mint(receiver);
    }

    function burn(
        address banker,
        uint256 share,
        address receiver
    ) external {
        IPool(pool).burn(banker, share, receiver);
    }

    function countsToAddRewards(address token) external view returns (uint256) {
        token;
        return defaltCountsToAddRewards;
    }

    function setCountsToAddRewards(uint256 counts) external {
        defaltCountsToAddRewards = counts;
    }

    function setProtocolInReferralFee(uint256 fee) external {
        protocolInReferralFee = fee;
    }
}
