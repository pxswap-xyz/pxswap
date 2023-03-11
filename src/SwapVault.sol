// SPDX-License-Identifier: AGPL-3.0
pragma solidity 0.8.19;

import {HandleERC721} from "./utils/HandleERC721.sol";
import {PxswapERC721Receiver} from "./utils/PxswapERC721Receiver.sol";

contract SwapVault is HandleERC721, PxswapERC721Receiver {

    address px;

    constructor(address px_){
        px = px_;
    }

    function fromVault(
        address[] memory nfts, 
        address to, 
        uint256[] memory ids
        ) external onlyPx {
        transferNft(nfts, address(this), to, nfts.length, ids);
    }

    /////////////////////////////////////////////
    //                Modifiers
    /////////////////////////////////////////////

    modifier onlyPx() {
        require(msg.sender == px, "Only px!");
        _;
    }
}
