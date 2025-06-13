// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {Script} from "forge-std/Script.sol";
import {console} from "forge-std/console.sol";
import {Subscription} from "../src/Subscription.sol";


contract DeployScript is Script {
    address constant USDC_SEPOLIA = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
    uint256 constant PRICE = 1_000_000; 

    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        Subscription subscription = new Subscription(USDC_SEPOLIA, PRICE);
        console.log("Subscription deployed to:", address(subscription));

        vm.stopBroadcast();
    }
}
