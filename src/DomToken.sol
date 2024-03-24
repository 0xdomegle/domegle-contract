// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract DomToken is ERC20 {
    constructor(string memory name, string memory symbol, uint256 totalSupply_) ERC20(name, symbol) {
        _mint(msg.sender, totalSupply_);
    }
}
