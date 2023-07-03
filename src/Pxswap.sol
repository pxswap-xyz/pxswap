// SPDX-License-Identifier: AGPL-3.0
pragma solidity 0.8.19;

///            ______________  __ ___________      __   _____  __________
///            \______   \   \/ //   _____/  \    /  \ /  _  \ \______   \
///             |     ___/\    / \_____  \\   \/\/   //  /_\  \ |     ___/
///             |    |    /    \ /        \\        //    |    \|    |
///             |____|   /___/\ \_______  / \__/\  / \____|__  /|____|
///                            \/       \/       \/          \/

import "lib/openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";
import "lib/openzeppelin-contracts/contracts/token/ERC721/utils/ERC721Holder.sol";
import "lib/openzeppelin-contracts/contracts/security/ReentrancyGuard.sol";
import "lib/openzeppelin-contracts/contracts/utils/Counters.sol";

/**
 * @title pxswap
 * @author pxswap (https://github.com/pxswap-xyz/pxswap)
 * @author Ali Konuk - @alikonuk1
 * @dev This contract is for P2P trading non-fungible tokens (NFTs)
 * @dev Please reach out to ali@pxswap.xyz regarding to this contract
 */
contract Pxswap is ERC721Holder, ReentrancyGuard {
    using Counters for Counters.Counter;

    struct Trade {
        address payable initiator;
        address[] offeredNftsAddresses;
        uint256[] offeredNftsIds;
        uint256 ethOffered;
        bool isOpen;
    }

    struct Offer {
        address payable offeror;
        address[] offeredNftsAddresses;
        uint256[] offeredNftsIds;
        uint256 ethOffered;
    }

    Counters.Counter private _tradeId;
    mapping(uint256 => Trade) public trades;
    mapping(uint256 => Offer[]) public tradeOffers;

    event TradeOpened(uint256 tradeId, address initiator, uint256[] nftIds);
    event OfferCreated(uint256 tradeId, address offeror, uint256[] nftIds);
    event TradeAccepted(uint256 tradeId, address offeror);

    function openTrade(
        address[] memory nftAddresses,
        uint256[] memory nftIds,
        uint256 ethAmount
    ) public payable {
        require(
            nftAddresses.length == nftIds.length,
            "Addresses and IDs length must match"
        );
        require(ethAmount <= msg.value, "Insufficient ETH offered");

        uint256 newTradeId = _tradeId.current();
        trades[newTradeId] =
            Trade(payable(msg.sender), nftAddresses, nftIds, ethAmount, true);

        for (uint256 i = 0; i < nftAddresses.length; i++) {
            ERC721(nftAddresses[i]).safeTransferFrom(
                msg.sender, address(this), nftIds[i]
            );
        }

        emit TradeOpened(newTradeId, msg.sender, nftIds);
        _tradeId.increment();
    }

    function offerTrade(
        uint256 tradeId,
        address[] memory nftAddresses,
        uint256[] memory nftIds,
        uint256 ethAmount
    ) public payable {
        require(trades[tradeId].isOpen == true, "Trade is not open");
        require(
            nftAddresses.length == nftIds.length,
            "Addresses and IDs length must match"
        );
        require(ethAmount <= msg.value, "Insufficient ETH offered");

        tradeOffers[tradeId].push(
            Offer(payable(msg.sender), nftAddresses, nftIds, ethAmount)
        );

        for (uint256 i = 0; i < nftAddresses.length; i++) {
            ERC721(nftAddresses[i]).safeTransferFrom(
                msg.sender, address(this), nftIds[i]
            );
        }

        emit OfferCreated(tradeId, msg.sender, nftIds);
    }

    function acceptOffer(uint256 tradeId, uint256 offerId)
        public
        nonReentrant
    {
        require(
            msg.sender == trades[tradeId].initiator,
            "Only trade initiator can accept an offer"
        );
        require(trades[tradeId].isOpen == true, "Trade is not open");

        // Transfer ETH and NFTs from the offeror to the initiator
        Offer memory offer = tradeOffers[tradeId][offerId];
        trades[tradeId].initiator.transfer(offer.ethOffered);
        for (uint256 i = 0; i < offer.offeredNftsAddresses.length; i++) {
            ERC721(offer.offeredNftsAddresses[i]).safeTransferFrom(
                address(this),
                trades[tradeId].initiator,
                offer.offeredNftsIds[i]
            );
        }

        // Transfer ETH and NFTs from the initiator to the offeror
        offer.offeror.transfer(trades[tradeId].ethOffered);
        for (
            uint256 i = 0; i < trades[tradeId].offeredNftsAddresses.length; i++
        ) {
            ERC721(trades[tradeId].offeredNftsAddresses[i]).safeTransferFrom(
                address(this), offer.offeror, trades[tradeId].offeredNftsIds[i]
            );
        }

        trades[tradeId].isOpen = false;
        emit TradeAccepted(tradeId, offer.offeror);
    }
}
