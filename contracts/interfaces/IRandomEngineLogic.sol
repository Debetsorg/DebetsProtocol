// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

/**
 * @title IRandomEngineLogic interface
 * @author Debet
 * @notice The interface for RandomEngineLogic contract
 */
interface IRandomEngineLogic {
    /**
     * @dev Emit on request function
     * @param caller the address of caller contract
     * @param rewardsReceiver The address receive rewards of random engine and refund gas
     * @param requestId The request id from chainlink vrf service
     */
    event RandomRequest(
        address caller,
        address rewardsReceiver,
        uint256 requestId
    );

    /**
     * @dev Emit on fulfillRandomWords function
     * @param caller the address of caller contract
     * @param rewardsReceiver the address receive rewards of random engine and refund gas
     * @param requestId The request id from chainlink vrf service
     * @param rewards The amount of random engine rewards
     */
    event RandomCallback(
        address caller,
        address rewardsReceiver,
        uint256 requestId,
        uint256 rewards
    );

    /**
     * @dev Emit on setCaller function
     * @param caller the address of caller contract
     * @param enable Whether enable the caller or not
     */
    event SetCaller(address caller, bool enable);

    /**
     * @dev Emit on set TopUpLink function
     * @param linkAmount The amount of link to top up
     */
    event TopUpLink(uint256 linkAmount);

    /**
     * @notice Request the random works
     * @dev Emit the RandomRequest event
     * @dev Only valid caller set by factory can call ths function
     * @param callbackGasLimit The gas required by the callback
     * function of caller contract
     * @param numWords The number of random words that caller required
     * @param rewardsReceiver The address receive rewards of random engine and refund gas
     * @return requestId The request id from chainlink vrf service
     */
    function request(
        uint32 callbackGasLimit,
        uint32 numWords,
        address rewardsReceiver
    ) external payable returns (uint256 requestId);

    /**
     * @notice Top up link token for subcription account of random engine
     * @dev Emit the TopUpLink event
     */
    function topUpLink() external payable;

    /**
     * @notice Set the caller enable or not
     * @dev Emit the SetCaller event
     * @param caller The address of the caller
     * @param enable Whether enable the caller or not
     */
    function setCaller(address caller, bool enable) external;

    /**
     * @notice get the amount of native token required as gas when call the request function
     * @param callbackGasLimit The gas required by the callback
     * function of caller contract
     * @param gasPriceWei Estimated gas price at time of request
     * @return The amount of native token required
     */
    function calculateNativeTokenRequired(
        uint32 callbackGasLimit,
        uint256 gasPriceWei
    ) external view returns (uint256);
}
