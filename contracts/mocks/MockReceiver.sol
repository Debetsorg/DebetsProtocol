// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "../interfaces/IFactory.sol";
import "../interfaces/IDice.sol";

contract MockReceiver {
    function burnNative(address factory, uint256 share) external {
        IFactory(factory).burnNative(share);
    }

    function dice_betNativeToken(
        address dice,
        uint256 amount,
        address referrer,
        uint256 number,
        DiceType.Direction direction
    ) external payable {
        IDice(dice).betNativeToken{value: msg.value}(
            amount,
            referrer,
            number,
            direction
        );
    }
}
