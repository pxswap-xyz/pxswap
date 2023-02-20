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

    struct LimitBuy {
        bool active;
        address buyer;
        address wantNft;
        uint256 wantId;
        uint256 price;
    }

}
