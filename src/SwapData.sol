// SPDX-License-Identifier: AGPL-3.0
pragma solidity 0.8.19;

contract SwapData {
    struct Swap {
        uint256[] giveId;
        uint256[] wantId;
        uint256 amount;
        uint256 ethAmount;
        address seller;
        address buyer;
        address[] giveNft;
        address[] wantNft;
        address wantToken;
        address vault;
        bool active;
    }

    struct LimitBuy {
        bool active;
        address buyer;
        address wantNft;
        uint256 wantId;
        uint256 price;
    }

    struct LimitSell {
        bool active;
        address seller;
        address giveNft;
        uint256 giveId;
        uint256 price;
    }
}
