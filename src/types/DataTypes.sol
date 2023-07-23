// SPDX-License-Identifier: AGPL-3.0
pragma solidity 0.8.19;

library DataTypes {
    struct Trade {
        address initiator;
        address[] offeredNfts;
        uint256[] offeredNftsIds;
        address[] requestNfts;
        bool isOpen;
    }
}
