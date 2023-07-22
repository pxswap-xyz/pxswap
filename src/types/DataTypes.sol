// SPDX-License-Identifier: AGPL-3.0
pragma solidity 0.8.19;

library DataTypes {
    struct Trade {
        address payable initiator;
        address[] offeredNfts;
        uint256[] offeredNftsIds;
        bool isOpen;
    }

    struct Offer {
        address payable offeror;
        address[] offeredNfts;
        uint256[] offeredNftsIds;
        uint256 ethOffered;
    }
}
