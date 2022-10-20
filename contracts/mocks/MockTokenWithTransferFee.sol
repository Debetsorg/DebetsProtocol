// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MockTokenWithTransferFee is ERC20 {
    constructor() ERC20("Mock Token With Transfer Fee", "MTWTF") {}

    uint256 public constant transferFeeRate = 50;
    uint256 public constant transferFeeDenominator = 100;

    bool private deducted;

    function mint(address account, uint256 amount) external {
        _mint(account, amount);
    }

    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal override {
        if (from != address(0)) {
            if (!deducted) {
                deducted = true;
                uint256 fee = (amount * transferFeeRate) /
                    transferFeeDenominator;
                _transfer(to, address(this), fee);
            } else {
                deducted = false;
            }
        }
    }
}
