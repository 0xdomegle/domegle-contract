// SPDX-License-Identifier: MIT

pragma solidity 0.8.24;

import {DomToken} from "./DomToken.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract Staking is Ownable {
    //////////////////
    ///// ERRORS /////
    //////////////////
    error Staking__InsufficientStakeAmount();
    error Staking__InsufficientTokenBalance();
    error Staking__UserNotStaked();
    error Staking__UserSuspended();
    error Staking__TransferFailed();
    error Staking__ZeroAmount();
    error Staking__WithdrawAmountCannotBeGreaterThanStaked();
    error Staking__StakeAmountCannotBeLessThanMinimumAfterWithdrawal();

    ///////////////////////
    /// STATE VARIABLES ///
    ///////////////////////
    uint256 private s_minimumStakeAmount;
    DomToken private s_domToken;

    mapping(address user => uint256 stakeAmount) private s_userToStakeAmount;
    mapping(address user => bool isSuspended) private s_suspendedUsers;

    //////////////////
    ///// EVENTS /////
    //////////////////
    event TokensStaked(address indexed user, uint256 amount);
    event TokensUnstaked(address indexed user, uint256 amount);

    ///////////////////
    //// MODIFIERS ////
    ///////////////////
    modifier minimumStake(uint256 _amountToStake) {
        if (_amountToStake < s_minimumStakeAmount) {
            revert Staking__InsufficientStakeAmount();
        }
        _;
    }

    modifier userNotSuspended() {
        if (s_suspendedUsers[msg.sender] == true) {
            revert Staking__UserSuspended();
        }
        _;
    }

    modifier moreThanZero(uint256 _amount) {
        if (_amount <= 0) {
            revert Staking__ZeroAmount();
        }
        _;
    }

    ///////////////////
    //// FUNCTIONS ////
    ///////////////////
    constructor(address _domTokenAddress, uint256 _minimumStakeAmount) Ownable(msg.sender) {
        s_domToken = DomToken(_domTokenAddress);
        s_minimumStakeAmount = _minimumStakeAmount;
    }

    function stakeToken(uint256 _amountToStake) external userNotSuspended minimumStake(_amountToStake) {
        // check user has enough token balance to stake
        if (s_domToken.balanceOf(msg.sender) < _amountToStake) {
            revert Staking__InsufficientTokenBalance();
        }

        // store user details
        s_userToStakeAmount[msg.sender] += _amountToStake;
        emit TokensStaked(msg.sender, _amountToStake);

        // perform token transfer
        bool success = s_domToken.transferFrom(msg.sender, address(this), _amountToStake);
        if (!success) {
            revert Staking__TransferFailed();
        }
    }

    function withdrawStakeAmount(uint256 _amountToWithdraw) external userNotSuspended moreThanZero(_amountToWithdraw) {
        // check withdrawal amount is less than or equal to staked amount
        if (_amountToWithdraw > s_userToStakeAmount[msg.sender]) {
            revert Staking__WithdrawAmountCannotBeGreaterThanStaked();
        }
        // check if after withdrawal the staked amount is still more than minimumStakeAmount
        if (s_userToStakeAmount[msg.sender] - _amountToWithdraw < s_minimumStakeAmount) {
            revert Staking__StakeAmountCannotBeLessThanMinimumAfterWithdrawal();
        }

        // update user details
        s_userToStakeAmount[msg.sender] -= _amountToWithdraw;
        emit TokensUnstaked(msg.sender, _amountToWithdraw);

        // return staked tokens
        bool success = s_domToken.transfer(msg.sender, _amountToWithdraw);
        if (!success) {
            revert Staking__TransferFailed();
        }
    }

    function setMinimumStakeAmount(uint256 amount) external onlyOwner {
        s_minimumStakeAmount = amount;
    }

    function suspendUser(address _userToSuspend) external onlyOwner {
        s_suspendedUsers[_userToSuspend] = true;
    }

    ///////////////////////////////
    /// View and Pure Functions ///
    ///////////////////////////////
    function getUserStakedAmount(address _user) external view returns (uint256) {
        return s_userToStakeAmount[_user];
    }

    function isSuspendedUser(address _user) external view returns (bool) {
        return s_suspendedUsers[_user];
    }

    function getMinimumStakeAmount() external view returns (uint256) {
        return s_minimumStakeAmount;
    }
}
