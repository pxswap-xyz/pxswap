// SPDX-License-Identifier: AGPL-3.0
pragma solidity 0.8.19;

interface IPxswap {
    event TradeOpened(
        uint256 indexed tradeId, address[] indexed nfts, uint256[] indexed nftIds
    );
    event TradeCanceled(uint256 indexed tradeId);
    event OfferCreated(
        uint256 indexed tradeId, address[] indexed nfts, uint256[] indexed nftIds
    );
    event TradeAccepted(uint256 indexed tradeId);
}