// SPDX-License-Identifier: AGPL-3.0
pragma solidity 0.8.19;

interface IPxswap {
    event TradeOpened(
        bytes32 indexed tradeHash, address[] indexed nfts, address[] indexed requestNfts
    );
    event TradeCanceled(bytes32 indexed tradeHash);
    event TradeAccepted(bytes32 indexed tradeHash);
}
