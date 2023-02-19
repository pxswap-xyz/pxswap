// SPDX-License-Identifier: AGPL-3.0
pragma solidity 0.8.15;

contract SwapData {
    struct Swap {
        bool active;
        address seller;
        address[] giveNft;
        uint256[] giveId;
        address[] wantNft;
        uint256[] wantId;
        address wantToken;
        uint256 amount;
        uint256 ethAmount;
    }

    struct Buy {
        bool active;
        bool spesificId;
        address buyer;
        address nft;
        uint256 tokenId;
        uint256 amount;
    }

    struct Sell {
        bool active;
        address seller;
        address nft;
        uint256 tokenId;
        uint256 amount;
    }

    struct SwapOrder {
        bool active;
        bool isNft;
        /*         bool spesificId; */
        address seller;
        address[] wantNft;
        address[] giveNft;
        address wantToken;
        uint256 amount;
        uint256[] giveId;
    }

    struct OfferNft {
        bool active;
        address buyer;
        address[] nfts;
        uint256[] nftId;
        uint256 swapId;
    }

    struct OfferToken {
        bool active;
        address buyer;
        address paymentToken;
        uint256 amount;
        uint256 swapId;
    }
    /*         uint256 wantId; */

    /*     struct Basket {
    } */
}
