// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import "forge-std/Script.sol";
import "../src/Subscription.sol"; 

contract DeployScript is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        address usdc = 0xd9cEdEB6C7dfb4b02df7E70975af0136F9E8c7df;
        uint256 price = 1e6; // 1 USDC

        vm.startBroadcast(deployerPrivateKey);

        new Subscription(usdc, price);

        vm.stopBroadcast();
    }
}
