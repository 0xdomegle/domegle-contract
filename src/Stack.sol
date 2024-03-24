// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "./Token.sol";

contract Stack {
    struct User{
        uint256 balance;
        bool isStacked;
        bool isSuspended;
    }

    uint256 public minimumStakeAmount;
    Token public domeToken;

    mapping (address => User) public stackedUser;

    address public owner;

    event TokensStaked(address indexed user, uint256 amount);
    event TokensUnstaked(address indexed user, uint256 amount);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor(address _domTokenAddress, uint _minimumStakeAmount) {
        domeToken = _domTokenAddress;
        minimumStakeAmount = _minimumStakeAmount;
        owner = msg.sender;
    }

    modifier minimumStake{
        require(msg.value >= minimumStakeAmount, "insufficient stake amount");
        _;
    }

    modifier userStacked{
        require(stackedUser[msg.sender].isStacked, "user is not stacked");
        _;
    }

    modifier userNotSuspended{
        require(stackedUser[msg.sender].isSuspended == false, "user is suspended");
        _;
    }

    modifier onlyOwner{
        require(msg.sender == owner, "only owner can call this function");
        _;
    }

    function stackToken() public minimumStake() payable{
        bool success = domeToken.transfer(address(this), msg.value);
        require(success);
        User memory user = User(msg.value, true);
        stackedUser[msg.sender] = user;
        emit TokensStaked(msg.sender, msg.value);
    }

    function withdrawStackAmount() public userStacked() userNotSuspended() payable{
        uint256 amount = stackedUser[msg.sender].balance;
        delete stackedUser[msg.sender];
        bool success = domeToken.transfer(msg.sender, amount);
        require(success);
        emit TokensUnstaked(msg.sender, amount);
    }

    function checkStack() public view returns (User memory){
        return stackedUser[msg.sender];
    }

    function setMinimumStakeAmount(uint256 amount) public onlyOwner() {
        minimumStakeAmount = amount;
    }

    function renounceOwnership() public onlyOwner() {
        owner = address(0);
        emit OwnershipTransferred(owner, address(0));
    }

    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
        emit OwnershipTransferred(owner, newOwner);
    }


}
