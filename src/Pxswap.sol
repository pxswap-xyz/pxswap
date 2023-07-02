// SPDX-License-Identifier: AGPL-3.0
pragma solidity 0.8.19;

///            ______________  __ ___________      __   _____  __________
///            \______   \   \/ //   _____/  \    /  \ /  _  \ \______   \
///             |     ___/\    / \_____  \\   \/\/   //  /_\  \ |     ___/
///             |    |    /    \ /        \\        //    |    \|    |
///             |____|   /___/\ \_______  / \__/\  / \____|__  /|____|
///                            \/       \/       \/          \/

/**
 * @title pxswap
 * @author pxswap (https://github.com/pxswap-xyz/pxswap)
 * @author Ali Konuk - @alikonuk1
 * @dev This contract is for P2P trading non-fungible tokens (NFTs)
 * @dev Please reach out to ali@pxswap.xyz regarding to this contract
 */
contract Pxswap {
    uint256 public number;

    function setNumber(uint256 newNumber) public {
        number = newNumber;
    }

    function increment() public {
        number++;
    }
}
