// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

/**
 * @title ISwapProvider interface
 * @author Debet
 * @notice The interface for swap provider
 */
interface ISwapProvider {
    /**
     * @dev Emit on setSwapRouter and initialize
     * @param router The address of swap router
     */
    event SetSwapRouter(address router);

    /**
     * @dev Emit on setPegSwap and initialize
     * @param pegSwap The address of peg swap
     */
    event SetPegSwap(address pegSwap);

    /**
     * @dev Emit on setLinkToken and initialize
     * @param link The address of vrf link token
     */
    event SetLinkToken(address link);

    /**
     * @dev Emit on setNativeLinkToken and initialize
     * @param nativeLinkToken The address of bridge link token
     */
    event SetNativeLinkToken(address nativeLinkToken);

    /**
     * @dev Emit on setSwapPath and initialize
     * @param path The address array of swap path from native token to link
     */
    event SetSwapPath(address[] path);

    /**
     * @notice Initialize the swap provider
     * @dev From Wrapped native token to native link token will be set as the default swap path
     * @dev Native link token will be approved for peg swap
     * @param _swapRouter The address of the dex router
     * @param _pegSwap The address of the peg swap
     * @param _linkToken The address of the vrf link token
     * @param _nativeLinkToken The address of the nattive link token
     */
    function initialize(
        address _swapRouter,
        address _pegSwap,
        address _linkToken,
        address _nativeLinkToken
    ) external;

    /**
     * @notice Set the address of dex router (UniswapV2 type dex)
     * @dev Emit the SetSwapRouter event
     * @param _swapRouter The address of the dex router
     */
    function setSwapRouter(address _swapRouter) external;

    /**
     * @notice Set the address of peg swap which is used to swap bridge
     * link token to VRF link token
     * @dev Emit the SetPegSwap event
     * @param _pegSwap The address of the peg swap
     */
    function setPegSwap(address _pegSwap) external;

    /**
     * @notice Set the address of link token for VRF
     * @dev Emit the SetLinkToken event
     * @param _linkToken The address of the vrf link token
     */
    function setLinkToken(address _linkToken) external;

    /**
     * @notice Set the address of native link token(link token from bridge)
     * @dev Emit the SetNativeLinkToken event
     * @dev Native link token will be approved for peg swap
     * @param _nativeLinkToken The address of the nattive link token
     */
    function setNativeLinkToken(address _nativeLinkToken) external;

    /**
     * @notice Set the swap path from native token to link
     * @dev Emit the SetSwapPath event
     * @param path The address array of swap path
     */
    function setSwapPath(address[] memory path) external;

    /**
     * @notice Swap native token to native link token and then swap native link token to vrf link token
     * @param amountOutMin The minimum amount of vrf link token to return
     * @param to The address to receive the vrf link token
     * @return amountOfLink The amount of vrf link token to return
     */
    function swapNativeTokenToLink(uint256 amountOutMin, address to)
        external
        payable
        returns (uint256 amountOfLink);

    /**
     * @notice Get the amount of native token that each link token can swap
     * @return The amount of native token
     */
    function getWeiPerUnitLink() external view returns (uint256);

    /**
     * @notice Get current swap path from native token to native link token
     * @return The address array of swap path
     */
    function getSwapPath() external view returns (address[] memory);

    /**
     * @notice Get the address of swap router
     * @return The address of swap router
     */
    function swapRouter() external view returns (address);

    /**
     * @notice Get the address of peg swap
     * @return The address of peg swap
     */
    function pegSwap() external view returns (address);

    /**
     * @notice Get the address of vrf link token
     * @return The address of vrf link token
     */
    function linkToken() external view returns (address);

    /**
     * @notice Get the address of bridge link token
     * @return The address of bridge link token
     */
    function nativeLinkToken() external view returns (address);
}
