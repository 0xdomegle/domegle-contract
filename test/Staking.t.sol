// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {Test} from "forge-std/Test.sol";
import {console} from "forge-std/console.sol";
import {Deploy} from "script/Deploy.s.sol";
import {DomToken} from "src/DomToken.sol";
import {Staking} from "src/Staking.sol";

contract StakingTest is Test {
    DomToken domToken;
    Staking stake;
    address user = makeAddr("USER");
    address owner;
    uint256 amountToStake = 20 ether;

    function setUp() public {
        Deploy deployer = new Deploy();
        (domToken, stake) = deployer.run();
        owner = stake.owner();
        vm.prank(owner);
        domToken.transfer(user, 50 ether);
    }

    /////////////////
    ///// stake /////
    /////////////////
    function testUserCanStakeTokens() public {
        vm.startPrank(user);
        domToken.approve(address(stake), amountToStake);
        stake.stake(amountToStake);
        vm.stopPrank();

        uint256 stakedAmount = stake.getUserStakedAmount(user);
        assertEq(stakedAmount, amountToStake);
    }

    function testRevertsIfAmountLessThanMinimum() public {
        vm.startPrank(user);
        domToken.approve(address(stake), 10 ether);
        vm.expectRevert(Staking.Staking__InsufficientStakeAmount.selector);
        stake.stake(1 ether);
        vm.stopPrank();
    }

    function testRevertsIfAmountExceedsUserBalance() public {
        vm.startPrank(user);
        domToken.approve(address(stake), 60 ether);
        vm.expectRevert(abi.encodeWithSelector(Staking.Staking__InsufficientTokenBalance.selector, 50 ether));
        stake.stake(60 ether);
        vm.stopPrank();
    }

    ////////////////////
    ///// withdraw /////
    ////////////////////
    modifier userStaked() {
        vm.startPrank(user);
        domToken.approve(address(stake), amountToStake);
        stake.stake(amountToStake);
        vm.stopPrank();
        _;
    }

    function testUserCanWithdrawTokensFully() public userStaked {
        uint256 amountToWithdraw = stake.getUserStakedAmount(user);
        vm.prank(user);
        stake.withdraw(amountToWithdraw);

        uint256 balanceAfterWithdraw = stake.getUserStakedAmount(user);
        assertEq(balanceAfterWithdraw, 0);
    }

    function testUserCanWithdrawTokensPartially() public userStaked {
        uint256 amountToWithdraw = stake.getUserStakedAmount(user) - stake.getMinimumStakeAmount();
        vm.prank(user);
        stake.withdraw(amountToWithdraw);

        uint256 balanceAfterWithdraw = stake.getUserStakedAmount(user);
        assertGe(balanceAfterWithdraw, stake.getMinimumStakeAmount());
    }
}
