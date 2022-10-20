// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import "../../interfaces/external/ISwapRouter.sol";
import "../../interfaces/external/IPegSwap.sol";
import "../../interfaces/ISwapProvider.sol";

/**
 * @title SwapProvider contract
 * @author Debet
 * @notice Provider for converting native token to link token
 * @dev Only applicable to UniswapV2 type dex
 */
contract SwapProvider is ISwapProvider, OwnableUpgradeable {
    using SafeERC20 for IERC20;

    uint256 private constant LINK_UNIT = 1e18;

    /// @notice address of swap router
    address public override swapRouter;
    /// @notice address of peg swap
    address public override pegSwap;
    /// @notice address of vrf link token
    address public override linkToken;
    ///@notice address of bridge link token
    address public override nativeLinkToken;

    /// @dev address array of swap path from native token to link
    address[] private swapPath;

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
    ) external override initializer {
        __Ownable_init();

        swapRouter = _swapRouter;
        pegSwap = _pegSwap;
        linkToken = _linkToken;
        nativeLinkToken = _nativeLinkToken;

        swapPath.push(ISwapRouter(swapRouter).WETH());
        swapPath.push(nativeLinkToken);

        IERC20(nativeLinkToken).safeApprove(_pegSwap, type(uint256).max);

        emit SetSwapRouter(_swapRouter);
        emit SetPegSwap(_pegSwap);
        emit SetLinkToken(_linkToken);
        emit SetNativeLinkToken(_nativeLinkToken);
        emit SetSwapPath(swapPath);
    }

    /**
     * @notice Set the address of dex router (UniswapV2 type dex)
     * @dev Emit the SetSwapRouter event
     * @param _swapRouter The address of the dex router
     */
    function setSwapRouter(address _swapRouter) external override onlyOwner {
        swapRouter = _swapRouter;
        emit SetSwapRouter(_swapRouter);
    }

    /**
     * @notice Set the address of peg swap which is used to swap bridge
     * link token to VRF link token
     * @dev Emit the SetPegSwap event
     * @param _pegSwap The address of the peg swap
     */
    function setPegSwap(address _pegSwap) external override onlyOwner {
        pegSwap = _pegSwap;
        emit SetPegSwap(_pegSwap);
    }

    /**
     * @notice Set the address of link token for VRF
     * @dev Emit the SetLinkToken event
     * @param _linkToken The address of the vrf link token
     */
    function setLinkToken(address _linkToken) external override onlyOwner {
        linkToken = _linkToken;
        emit SetLinkToken(_linkToken);
    }

    /**
     * @notice Set the address of native link token(link token from bridge)
     * @dev Emit the SetNativeLinkToken event
     * @dev Native link token will be approved for peg swap
     * @param _nativeLinkToken The address of the nattive link token
     */
    function setNativeLinkToken(address _nativeLinkToken)
        external
        override
        onlyOwner
    {
        nativeLinkToken = _nativeLinkToken;

        IERC20(nativeLinkToken).safeApprove(pegSwap, 0);
        IERC20(nativeLinkToken).safeApprove(pegSwap, type(uint256).max);

        emit SetNativeLinkToken(_nativeLinkToken);
    }

    /**
     * @notice Set the swap path from native token to link
     * @dev Emit the SetSwapPath event
     * @param path The address array of swap path
     */
    function setSwapPath(address[] memory path) external override onlyOwner {
        swapPath = path;
        emit SetSwapPath(path);
    }

    /**
     * @notice Swap native token to native link token and then swap native link token to vrf link token
     * @param amountOutMin The minimum amount of vrf link token to return
     * @param to The address to receive the vrf link token
     * @return amountOfLink The amount of vrf link token to return
     */
    function swapNativeTokenToLink(uint256 amountOutMin, address to)
        external
        payable
        override
        returns (uint256 amountOfLink)
    {
        ISwapRouter swap = ISwapRouter(swapRouter);

        swap.swapExactETHForTokens{value: msg.value}(
            amountOutMin,
            swapPath,
            address(this),
            block.timestamp + 60
        );

        uint256 nativeLinkBalance = IERC20(nativeLinkToken).balanceOf(
            address(this)
        );
        IPegSwap(pegSwap).swap(nativeLinkBalance, nativeLinkToken, linkToken);

        amountOfLink = IERC20(linkToken).balanceOf(address(this));
        IERC20(linkToken).safeTransfer(to, amountOfLink);
    }

    /**
     * @notice Get the amount of native token that each link token can swap
     * @return The amount of native token
     */
    function getWeiPerUnitLink() external view override returns (uint256) {
        ISwapRouter swap = ISwapRouter(swapRouter);

        uint256 length = swapPath.length;
        address[] memory path = new address[](length);
        for (uint256 i = 0; i < length; i++) {
            path[i] = swapPath[length - 1 - i];
        }

        uint256[] memory amounts = swap.getAmountsOut(LINK_UNIT, path);
        return amounts[1];
    }

    /**
     * @notice Get current swap path from native token to native link token
     * @return The address array of swap path
     */
    function getSwapPath() external view override returns (address[] memory) {
        return swapPath;
    }
}
