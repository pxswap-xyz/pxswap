// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;

import "forge-std/Script.sol";
import {Pxswap} from "src/Pxswap.sol";

contract DeployPxswap is Script {
    Pxswap pxswap;

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);
        pxswap = new Pxswap();
        vm.stopBroadcast();
    }
}
