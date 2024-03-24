// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Token is ERC20 {
    bytes public tokenIcon;
    constructor(
        string memory name,
        string memory symbol,
        string memory icon,
        uint256 totalSupply_
    ) ERC20(name, symbol) {
        icon = byte(icon);
        _mint(msg.sender, totalSupply_);
    }
}
