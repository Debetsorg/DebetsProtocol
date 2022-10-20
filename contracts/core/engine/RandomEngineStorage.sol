// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import "@chainlink/contracts/src/v0.8/interfaces/LinkTokenInterface.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";

/**
 * @title RandomEngineStorage contract
 * @author Debet
 * @notice Storage of the RandomEngine
 */
contract RandomEngineStorage {
    struct Request {
        uint256 requestId;
        address caller;
        address rewardsReceiver;
        uint256 rewards;
        bool callback;
    }

    /// @dev Parameter of VRF, the number of block confirmations before the callback
    uint16 internal immutable REQUEST_CONFIRMATIONS;
    /// @dev Maximum tolerance time for chainlink price updates
    uint32 internal immutable STALENESS_SECONDS;
    /// @dev The maximum gas that needs to be used internally during a VRF callback
    uint32 internal immutable MAX_VERIFICATION_GAS;
    /// @dev The amount of link token for vrf request fee
    uint128 internal immutable LINK_PREMIUM;
    /// @dev The bytes for maximum gas limit in vrf callback transaction
    bytes32 internal immutable KEY_HASH;
    /// @dev The link token that used in vrf
    LinkTokenInterface internal immutable LINKTOKEN;
    /// @dev The vrf coordinator contract
    VRFCoordinatorV2Interface internal immutable COORDINATOR;
    /// @dev The chainlink feed contract (NativeToken/LINK)
    AggregatorV3Interface internal immutable LINK_NATIVE_FEED;

    /// @notice The gas limit in randomEngine request function
    uint32 public engineCallbackGas;
    /// @notice The extra gas added to callBackGasLimit when call chainlink vrf
    uint32 public extraCallbackGas;
    /// @notice The gas limit in distribution rewards function
    uint32 public distributionCallbackGas;
    /// @notice The maximum interval time of swapping native token to link
    uint32 public intervalTimeToSwap;

    /// @notice The timestamp swap native token to link last time
    uint64 public lastSwapTime;
    /// @notice The id of the subscription account in vrf service
    uint64 public subscription_id;

    /// @notice The amount of native token accumulated
    /// that waiting to be added to staking pool
    uint128 public nativeTokenToRewards;
    /// @notice The rewards threshold of adding rewards to rewards pool
    uint128 public thresholdToAddRewards;
    /// @notice The timestamp of this contract deployment
    uint128 public deployTime;
    /// @notice The base fee that player pay each time they bet
    uint128 public requestBaseFee;
    /// @notice The amount of native token accumulated
    /// that waiting to be swaped to link token
    uint128 public nativeTokenToSwap;
    ///@notice The minimum link balance of subscription account
    uint128 public minLinkBalanceToSwap;

    /// @notice The address of swapProvider contract
    address public swapProvider;
    /// @notice The address of stakingPool contract
    address public stakingPool;
    /// @notice The address of distributionPool contract
    address public distributionPool;
    /// @notice The address of factory contract
    address public factory;

    /// @notice The mapping from chainlink request id to information of request
    mapping(uint256 => Request) public requestRecords;

    /// @notice The mapping from caller address to the effectiveness of caller
    mapping(address => bool) public isValidCaller;

    /**
     * @dev Constructor.
     * @param _linkToken The address of the vrf link token
     * @param _coordinator The address of the vrf coordinator
     * @param _linkNativeFeed The address of the chainlink feed contract (NativeToken/LINK)
     * @param _linkPremium The amount of link token for vrf request fee
     * @param _keyHash The bytes for maximum gas limit in vrf callback transaction
     */
    constructor(
        address _linkToken,
        address _coordinator,
        address _linkNativeFeed,
        uint128 _linkPremium,
        bytes32 _keyHash
    ) {
        REQUEST_CONFIRMATIONS = 3;
        STALENESS_SECONDS = 4 hours;
        MAX_VERIFICATION_GAS = 100000;
        LINK_PREMIUM = _linkPremium;
        KEY_HASH = _keyHash;
        LINKTOKEN = LinkTokenInterface(_linkToken);
        COORDINATOR = VRFCoordinatorV2Interface(_coordinator);
        LINK_NATIVE_FEED = AggregatorV3Interface(_linkNativeFeed);
    }
}
