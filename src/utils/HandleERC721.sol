// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

import {IERC721} from "./IERC721.sol";

contract HandleERC721 {
    
    function transferNft(
        address[] memory nft_,
        address from,
        address to,
        uint256 lenNft, 
        uint256[] memory id
        ) internal {
        for (uint256 i; i < lenNft;) {
            IERC721 nft = IERC721(nft_[i]);
            require(nft.balanceOf(from) >= 1);
            nft.safeTransferFrom(from, to, id[i]);
            unchecked {
                ++i;
            }
        }
    }
}
