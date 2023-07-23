// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;

import "forge-std/Script.sol";
import {mockNFT} from "test/mock/mockNFT.sol";

contract DeployMockNft is Script {
    mockNFT nft;

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);
        nft = new mockNFT("Mock3", "MOCK3");
        vm.stopBroadcast();
    }
}
