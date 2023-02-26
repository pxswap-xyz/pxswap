// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.15;

import "forge-std/Script.sol";
import {Pxswap} from "src/Pxswap.sol";

contract Deploy is Script {
  Pxswap pxswap;

  function run() public {
    // Commented out for now until https://github.com/crytic/slither/pull/1461 is released.
    // vm.startBroadcast();
    pxswap = new Pxswap();
  }
}