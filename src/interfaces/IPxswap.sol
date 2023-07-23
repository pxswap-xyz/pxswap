// SPDX-License-Identifier: AGPL-3.0
pragma solidity 0.8.19;

interface IPxswap {
    event TradeOpened(
        uint256 indexed tradeId, address[] indexed nfts, address[] indexed requestNfts
    );
    event TradeCanceled(uint256 indexed tradeId);
    event TradeAccepted(uint256 indexed tradeId);
}
