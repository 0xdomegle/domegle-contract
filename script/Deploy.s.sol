// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {Script, console} from "forge-std/Script.sol";
import {DomToken} from "src/DomToken.sol";
import {Staking} from "src/Staking.sol";

contract Deploy is Script {
    uint256 constant TOKEN_SUPPLY = 1000 ether;
    uint256 constant MINIMUM_STAKE_AMOUNT = 10 ether;
    uint256 constant DEPLOYER = 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80;

    function run() public returns (DomToken, Staking) {
        vm.startBroadcast(DEPLOYER);
        DomToken domToken = new DomToken("DomToken", "DOM", TOKEN_SUPPLY);
        Staking stake = new Staking(address(domToken), MINIMUM_STAKE_AMOUNT);
        vm.stopBroadcast();

        return (domToken, stake);
    }
}
