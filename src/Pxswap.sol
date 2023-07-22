// SPDX-License-Identifier: AGPL-3.0
pragma solidity 0.8.19;

///         ______________  __ ___________      __   _____  __________
///         \______   \   \/ //   _____/  \    /  \ /  _  \ \______   \
///          |     ___/\    / \_____  \\   \/\/   //  /_\  \ |     ___/
///          |    |    /    \ /        \\        //    |    \|    |
///          |____|   /___/\ \_______  / \__/\  / \____|__  /|____|
///                         \/       \/       \/          \/

import "lib/openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";
import "lib/openzeppelin-contracts/contracts/token/ERC721/utils/ERC721Holder.sol";
import "lib/openzeppelin-contracts/contracts/security/ReentrancyGuard.sol";
import "lib/openzeppelin-contracts/contracts/utils/Counters.sol";
import {IPxswap} from "./interfaces/IPxswap.sol";
import {DataTypes} from "./types/DataTypes.sol";
import {Errors} from "./libraries/Errors.sol";

/**
 * @title pxswap
 * @author pxswap (https://github.com/pxswap-xyz/pxswap)
 * @author Ali Konuk - @alikonuk1
 * @dev This contract is for P2P trading non-fungible tokens (NFTs)
 * @dev Please reach out to ali@pxswap.xyz regarding to this contract
 */
contract Pxswap is IPxswap, ERC721Holder, ReentrancyGuard {
    using Counters for Counters.Counter;

    Counters.Counter private _tradeId;
    mapping(uint256 => DataTypes.Trade) public trades;
    mapping(uint256 => DataTypes.Offer[]) public tradeOffers;

    function openTrade(address[] memory nfts, uint256[] memory nftIds) public {
        uint256 lNft = nfts.length;
        if (lNft != nftIds.length) {
            revert Errors.LENGTHS_MISMATCH();
        }

        uint256 newTradeId = _tradeId.current();
        trades[newTradeId] = DataTypes.Trade(payable(msg.sender), nfts, nftIds, true);

        for (uint256 i = 0; i < lNft;) {
            ERC721(nfts[i]).safeTransferFrom(msg.sender, address(this), nftIds[i]);
            unchecked {
                ++i;
            }
        }

        emit IPxswap.TradeOpened(newTradeId, nfts, nftIds);
        _tradeId.increment();
    }

    function cancelTrade(uint256 tradeId) public nonReentrant {
        address initiator = trades[tradeId].initiator;
        if (msg.sender != initiator) {
            revert Errors.ONLY_INITIATOR();
        }
        bool isOpen = trades[tradeId].isOpen;
        if (isOpen == false) {
            revert Errors.TRADE_CLOSED();
        }
        isOpen = false;

        uint256 lOfferedNfts = trades[tradeId].offeredNfts.length;
        // Return NFTs to the initiator
        for (uint256 i = 0; i < lOfferedNfts;) {
            ERC721(trades[tradeId].offeredNfts[i]).safeTransferFrom(
                address(this), initiator, trades[tradeId].offeredNftsIds[i]
            );
            unchecked {
                ++i;
            }
        }

        uint256 lOffers = tradeOffers[tradeId].length;
        // Return NFTs to all the offerors
        for (uint256 j = 0; j < lOffers;) {
            uint256 lTradeOffers = tradeOffers[tradeId][j].offeredNfts.length;
            for (uint256 k = 0; k < lTradeOffers;) {
                ERC721(tradeOffers[tradeId][j].offeredNfts[k]).safeTransferFrom(
                    address(this),
                    tradeOffers[tradeId][j].offeror,
                    tradeOffers[tradeId][j].offeredNftsIds[k]
                );
                unchecked {
                    ++k;
                }
            }
            unchecked {
                ++j;
            }
        }

        emit IPxswap.TradeCanceled(tradeId);
    }

    function offerTrade(
        uint256 tradeId,
        address[] memory nfts,
        uint256[] memory nftIds,
        uint256 ethAmount
    ) public payable {
        if (trades[tradeId].isOpen == false) {
            revert Errors.TRADE_CLOSED();
        }
        uint256 lNfts = nfts.length;
        if (lNfts != nftIds.length) {
            revert Errors.LENGTHS_MISMATCH();
        }
        if (ethAmount != msg.value) {
            revert Errors.VALUE_MISMATCH();
        }

        tradeOffers[tradeId].push(
            DataTypes.Offer(payable(msg.sender), nfts, nftIds, ethAmount)
        );

        for (uint256 i = 0; i < lNfts;) {
            ERC721(nfts[i]).safeTransferFrom(msg.sender, address(this), nftIds[i]);
            unchecked {
                ++i;
            }
        }

        emit IPxswap.OfferCreated(tradeId, nfts, nftIds);
    }

    function acceptOffer(uint256 tradeId, uint256 offerId) public nonReentrant {
        address payable initiator = trades[tradeId].initiator;
        if (msg.sender != initiator) {
            revert Errors.ONLY_INITIATOR();
        }
        if (trades[tradeId].isOpen == false) {
            revert Errors.TRADE_CLOSED();
        }

        trades[tradeId].isOpen = false;

        DataTypes.Offer memory offer = tradeOffers[tradeId][offerId];
        (bool sent,) = address(initiator).call{value: offer.ethOffered}("");
        require(sent, "FSE");
        uint256 lOfferedNfts = offer.offeredNfts.length;
        for (uint256 i = 0; i < lOfferedNfts;) {
            ERC721(offer.offeredNfts[i]).safeTransferFrom(
                address(this), initiator, offer.offeredNftsIds[i]
            );
            unchecked {
                ++i;
            }
        }

        uint256 lOfferedNfts2 = trades[tradeId].offeredNfts.length;
        for (uint256 i = 0; i < lOfferedNfts2;) {
            ERC721(trades[tradeId].offeredNfts[i]).safeTransferFrom(
                address(this), offer.offeror, trades[tradeId].offeredNftsIds[i]
            );
            unchecked {
                ++i;
            }
        }

        emit IPxswap.TradeAccepted(tradeId);
    }
}
