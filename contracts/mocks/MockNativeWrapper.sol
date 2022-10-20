// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MockNativeWrapper is ERC20 {
    constructor() ERC20("Mock Token Wrapper", "WMT") {}

    receive() external payable {}

    function deposit() external payable {
        uint256 amount = msg.value;
        _mint(msg.sender, amount);
    }

    function withdraw(uint256 amount) external {
        _burn(msg.sender, amount);
        (bool success, ) = payable(msg.sender).call{value: amount, gas: 8000}(
            ""
        );
        require(success, "transfer failed");
    }
}
