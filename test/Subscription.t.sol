//SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {Test, console} from "forge-std/Test.sol";
import {Subscription} from "../src//Subscription.sol";
import {MockUSDC} from "../src//MockUSDC.sol";

contract SubscriptionTest is Test{
    Subscription public sub;
    MockUSDC public usdc;
    address user = address(1);
    address owner;

    function setUp() public{
        owner = address(this); //the test contract deploys the Subscription contract
        usdc = new MockUSDC();
        sub = new Subscription(address(usdc), 1000000); //equivqlent to 1 usdc

        // give user usdc
        usdc.transfer(user, 10000000); // 10 usdc
        vm.prank(user);
        usdc.approve(address (sub), type(uint256).max); // approve the subscription contract to spend user's usdc
    }

    function testSubscribe() public {
        uint256 before = usdc.balanceOf(address(sub));
        vm.prank(user);
        sub.subscribe(); // subscription contract debits 1 usdc from the user 

        uint256 afterBal = usdc.balanceOf(address(sub));
        assertEq(afterBal-before, 1000000); //this will check the subscription contract recieved the 1 usdc

        uint256 expiry = sub.subscriptions(user);
        assertGt(expiry, block.timestamp);
    }

    function testSubscribeTwiceStacksTime() public {
        vm.warp(1000);
        vm.prank(user);
        sub.subscribe(); 

        uint256 firstExpiry = sub.subscriptions(user);
        
        vm.warp(2000);
        vm.prank(user);
        sub.subscribe(); 

        uint256 secondExpiry = sub.subscriptions(user);
        assertEq(secondExpiry, firstExpiry + 30 days); // checks that second subscription adds 30 days to first
    }

    function testSubscribeAfterExpiry() public {
        vm.warp(1000);
        vm.prank(user);
        sub.subscribe(); 

        vm.warp(1000 + 31 days);
        vm.prank(user);
        sub.subscribe();

        uint256 expiry = sub.subscriptions(user);
        assertApproxEqAbs(expiry, block.timestamp + 30 days, 2); // checks that subscription resets after expiry
    }

    function testIsSubscribedTrue() public {
        vm.prank(user);
        sub.subscribe(); // user subscribes

        bool active = sub.isSubscribed(user);
        assertTrue(active);
    }

    function testIsSubscribedFalse() public {
        vm.prank(user);
        sub.subscribe(); // user subscribes

        vm.warp(block.timestamp + 31 days); // warp time past subscription expiry
        bool active = sub.isSubscribed(user);
        assertFalse(active); //we will chek the user is no longer subscribed
    }

    function testWithdrawOnlyByOwner() public {
        vm.prank(user);
        sub.subscribe(); 

        uint256 contractBal = usdc.balanceOf(address(sub));
        uint256 ownerBalBefore = usdc.balanceOf(owner);

        sub.withdraw(); // owner(me) withdraws the usdc from the subcscription contract

        uint256 ownerBalAfter = usdc.balanceOf(owner);
        assertEq(ownerBalAfter - ownerBalBefore, contractBal); //chekcs that owner recieved the usdc frm subscri
    }

    function testWithdrawFailsForNonOwner() public {
        vm.prank(user);
        sub.subscribe();

        vm.expectRevert("Only owner");
        vm.prank(user); //user tries to withdraw
        sub.withdraw(); // it will fail because useris not owner
    }

    function testSubscribeFailsIfNoFunds() public {
        address brokeUser = address(2);
        vm.prank(brokeUser);
        usdc.approve(address(sub), 1_000_000);

        vm.expectRevert(); // Don't check exact error, just that it reverts
        vm.prank(brokeUser);
        sub.subscribe();
    }
}
