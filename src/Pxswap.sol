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
import "lib/openzeppelin-contracts/contracts/utils/structs/EnumerableSet.sol";
import "lib/openzeppelin-contracts/contracts/access/Ownable.sol";
import {ReentrancyGuard} from "./abstract/ReentrancyGuard.sol";
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
contract Pxswap is IPxswap, ERC721Holder, ReentrancyGuard, Ownable {
    using EnumerableSet for EnumerableSet.Bytes32Set;

    EnumerableSet.Bytes32Set private _activeTradeHashes;
    mapping(bytes32 => DataTypes.Trade) public trades;

    uint256 public fee;

    function openTrade(
        address[] calldata offerNfts,
        uint256[] calldata offerNftIds,
        address[] calldata requestNfts,
        address counterParty
    ) external {
        uint256 lNft = offerNfts.length;
        if (lNft != offerNftIds.length) {
            revert Errors.LENGTHS_MISMATCH();
        }

        bytes32 tradeHash = keccak256(
            abi.encodePacked(
                msg.sender, offerNfts, offerNftIds, requestNfts, counterParty
            )
        );

        if (_activeTradeHashes.contains(tradeHash)) {
            revert Errors.TRADE_EXISTS();
        }

        trades[tradeHash] =
            DataTypes.Trade(msg.sender, offerNfts, offerNftIds, requestNfts, counterParty);

        _activeTradeHashes.add(tradeHash);

        for (uint256 i = 0; i < lNft;) {
            ERC721(offerNfts[i]).safeTransferFrom(
                msg.sender, address(this), offerNftIds[i]
            );
            unchecked {
                ++i;
            }
        }

        emit IPxswap.TradeOpened(tradeHash, offerNfts, requestNfts);
    }

    function cancelTrade(bytes32 tradeHash) external nonReentrant {
        if (_activeTradeHashes.contains(tradeHash) == false) {
            revert Errors.TRADE_CLOSED();
        }

        DataTypes.Trade storage trade = trades[tradeHash];

        address initiator = trade.initiator;

        if (msg.sender != initiator) {
            revert Errors.ONLY_INITIATOR();
        }

        _activeTradeHashes.remove(tradeHash);

        uint256 lOfferedNfts = trade.offeredNfts.length;

        for (uint256 i = 0; i < lOfferedNfts;) {
            ERC721(trade.offeredNfts[i]).safeTransferFrom(
                address(this), initiator, trade.offeredNftsIds[i]
            );
            unchecked {
                ++i;
            }
        }

        emit IPxswap.TradeCanceled(tradeHash);
    }

    function acceptTrade(bytes32 tradeHash, uint256[] calldata tokenIds)
        external
        payable
        nonReentrant
    {
        if (_activeTradeHashes.contains(tradeHash) == false) {
            revert Errors.TRADE_CLOSED();
        }
        if (msg.value != fee) {
            revert Errors.PAY_FEE();
        }
        DataTypes.Trade storage trade = trades[tradeHash];

        if (trade.counterParty != address(0)) {
            if (trade.counterParty != msg.sender) {
                revert Errors.NOT_COUNTER_PARTY();
            }
        }

        _activeTradeHashes.remove(tradeHash);

        uint256 lNft = trade.requestNfts.length;
        if (lNft != tokenIds.length) {
            revert Errors.LENGTHS_MISMATCH();
        }

        address initiator = trade.initiator;

        for (uint256 i = 0; i < lNft;) {
            if (ERC721(trade.requestNfts[i]).ownerOf(tokenIds[i]) != msg.sender) {
                revert Errors.NOT_OWNER();
            }
            ERC721(trade.requestNfts[i]).safeTransferFrom(
                msg.sender, initiator, tokenIds[i]
            );
            unchecked {
                ++i;
            }
        }

        uint256 lOfferedNfts = trade.offeredNfts.length;
        for (uint256 i = 0; i < lOfferedNfts;) {
            ERC721(trade.offeredNfts[i]).safeTransferFrom(
                address(this), msg.sender, trade.offeredNftsIds[i]
            );
            unchecked {
                ++i;
            }
        }

        emit IPxswap.TradeAccepted(tradeHash);
    }

    function getOffer(bytes32 tradeHash)
        external
        view
        returns (address[] memory, uint256[] memory, address[] memory, address)
    {
        if (_activeTradeHashes.contains(tradeHash) == false) {
            revert Errors.TRADE_CLOSED();
        }
        DataTypes.Trade storage trade = trades[tradeHash];
        return (
            trade.offeredNfts, trade.offeredNftsIds, trade.requestNfts, trade.counterParty
        );
    }

    function getActiveTrades() external view returns (bytes32[] memory) {
        return _activeTradeHashes.values();
    }

    function setFee(uint256 _fee) external onlyOwner {
        fee = _fee;
    }

    function withdrawFees() external onlyOwner {
        (bool sent,) = payable(owner()).call{value: address(this).balance}("");
        require(sent, "Failed to send Ether");
    }
}
