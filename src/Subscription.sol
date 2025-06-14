// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Subscription {
    address public owner;
    IERC20 public usdc;
    uint256 public price; 

    mapping(address => uint256) public subscriptions;

    event Subscribed(address indexed user, uint256 expiresAt);
    event Withdrawn(uint256 amount);

    constructor(address _usdc, uint256 _price) {
        owner = msg.sender;
        usdc = IERC20(_usdc);
        price = _price;
    }

    function subscribe() external {
        require(usdc.transferFrom(msg.sender, address(this), price), "Payment failed");

        // Add 30 days to current expiry or now
        uint256 currentExpiry = subscriptions[msg.sender];
        uint256 newExpiry = block.timestamp > currentExpiry
            ? block.timestamp + 30 days
            : currentExpiry + 30 days;

        subscriptions[msg.sender] = newExpiry;
        emit Subscribed(msg.sender, newExpiry);
    }

    function isSubscribed(address user) external view returns (bool) {
        return subscriptions[user] > block.timestamp;
    }

    function withdraw() external {
        require(msg.sender == owner, "Only owner");
        uint256 balance = usdc.balanceOf(address(this));
        require(usdc.transfer(owner, balance), "Withdraw failed");
        emit Withdrawn(balance);
    }
}