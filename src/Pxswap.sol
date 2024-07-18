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
 * @dev A decentralized platform for peer-to-peer trading of non-fungible tokens (NFTs).
 * @dev This contract facilitates the creation, cancellation, and acceptance of NFT trades between users.
 * @notice For any inquiries or issues regarding the contract, please contact ali@pxswap.xyz.
 */
contract Pxswap is IPxswap, ERC721Holder, ReentrancyGuard, Ownable {
    using EnumerableSet for EnumerableSet.Bytes32Set;

    EnumerableSet.Bytes32Set private _activeTradeHashes; // Tracks active trades by their hashes
    mapping(bytes32 => DataTypes.Trade) public trades; // Maps trade hash to trade data

    uint256 public fee; // The fee required to accept a trade
    uint256 public pxTokenHolderFeePercentage; // Fee percentage for PX token holders
    address public pxTokenVault; // Address where PX token holder fees are sent

    /**
     * @notice Initializes the contract with a default PX token holder fee percentage.
     */
    constructor() {
        pxTokenHolderFeePercentage = 50; // 50% to PX token holders by default
    }

    /**
     * @notice Opens a new trade with specified NFTs offered and requested, and an optional counterparty.
     * @param offerNfts Array of NFT contract addresses being offered.
     * @param offerNftIds Array of NFT IDs being offered.
     * @param requestNfts Array of NFT contract addresses being requested.
     * @param counterParty Optional address of the counterparty. If zero, any address can accept the trade.
     * @dev Emits a TradeOpened event on successful creation of a new trade.
     */
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
                msg.sender,
                offerNfts,
                offerNftIds,
                requestNfts,
                counterParty
            )
        );

        if (_activeTradeHashes.contains(tradeHash)) {
            revert Errors.TRADE_EXISTS();
        }

        trades[tradeHash] = DataTypes.Trade(
            msg.sender,
            offerNfts,
            offerNftIds,
            requestNfts,
            counterParty
        );

        _activeTradeHashes.add(tradeHash);

        for (uint256 i = 0; i < lNft; ) {
            ERC721(offerNfts[i]).safeTransferFrom(
                msg.sender,
                address(this),
                offerNftIds[i]
            );
            unchecked {
                ++i;
            }
        }

        emit IPxswap.TradeOpened(tradeHash, offerNfts, requestNfts);
    }

    /**
     * @notice Cancels an active trade by the initiator.
     * @param tradeHash The hash of the trade to cancel.
     * @dev Emits a TradeCanceled event on successful cancellation.
     * @dev Only the initiator of the trade can cancel it.
     */
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

        for (uint256 i = 0; i < lOfferedNfts; ) {
            ERC721(trade.offeredNfts[i]).safeTransferFrom(
                address(this),
                initiator,
                trade.offeredNftsIds[i]
            );
            unchecked {
                ++i;
            }
        }

        emit IPxswap.TradeCanceled(tradeHash);
    }

    /**
     * @notice Accepts an active trade by sending the required fee and fulfilling the trade requirements.
     * @param tradeHash The hash of the trade to accept.
     * @param tokenIds Array of token IDs being sent to fulfill the requested NFTs part of the trade.
     * @dev Emits a TradeAccepted event on successful acceptance and completion of a trade.
     */
    function acceptTrade(
        bytes32 tradeHash,
        uint256[] calldata tokenIds
    ) external payable nonReentrant {
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

        for (uint256 i = 0; i < lNft; ) {
            if (
                ERC721(trade.requestNfts[i]).ownerOf(tokenIds[i]) != msg.sender
            ) {
                revert Errors.NOT_OWNER();
            }
            ERC721(trade.requestNfts[i]).safeTransferFrom(
                msg.sender,
                initiator,
                tokenIds[i]
            );
            unchecked {
                ++i;
            }
        }

        uint256 lOfferedNfts = trade.offeredNfts.length;
        for (uint256 i = 0; i < lOfferedNfts; ) {
            ERC721(trade.offeredNfts[i]).safeTransferFrom(
                address(this),
                msg.sender,
                trade.offeredNftsIds[i]
            );
            unchecked {
                ++i;
            }
        }

        uint256 pxTokenHolderFee = (msg.value * pxTokenHolderFeePercentage) /
            100;

        (bool sent, ) = payable(pxTokenVault).call{value: pxTokenHolderFee}("");
        require(sent, "Failed to send Ether");

        emit IPxswap.TradeAccepted(tradeHash);
    }

    /**
     * @notice Retrieves the offer details of a given trade.
     * @param tradeHash The hash of the trade.
     * @return offeredNfts Array of NFT contract addresses offered.
     * @return offeredNftsIds Array of NFT IDs offered.
     * @return requestNfts Array of NFT contract addresses requested.
     * @return counterParty Address of the counterparty, if specified.
     */
    function getOffer(
        bytes32 tradeHash
    )
        external
        view
        returns (address[] memory, uint256[] memory, address[] memory, address)
    {
        if (_activeTradeHashes.contains(tradeHash) == false) {
            revert Errors.TRADE_CLOSED();
        }
        DataTypes.Trade storage trade = trades[tradeHash];
        return (
            trade.offeredNfts,
            trade.offeredNftsIds,
            trade.requestNfts,
            trade.counterParty
        );
    }

    /**
     * @notice Returns an array of active trade hashes.
     * @return Array of active trade hashes.
     */
    function getActiveTrades() external view returns (bytes32[] memory) {
        return _activeTradeHashes.values();
    }

    /**
     * @notice Sets the fee required to accept a trade.
     * @param _fee The new fee amount.
     * @dev Only the contract owner can call this function.
     */
    function setFee(uint256 _fee) external onlyOwner {
        fee = _fee;
    }

    /**
     * @notice Sets the fee percentage that goes to PX token holders.
     * @param _pxTokenHolderFeePercentage The new fee percentage.
     * @dev Only the contract owner can call this function.
     */
    function setFeeSplit(
        uint256 _pxTokenHolderFeePercentage
    ) external onlyOwner {
        if (_pxTokenHolderFeePercentage > 100) {
            revert Errors.INVALID_FEE_SPLIT();
        }
        pxTokenHolderFeePercentage = _pxTokenHolderFeePercentage;
    }

    /**
     * @notice Sets the address where PX token holder fees are sent.
     * @param _pxTokenVault The address of the PX token vault.
     * @dev Only the contract owner can call this function.
     */
    function setPxTokenVault(address _pxTokenVault) external onlyOwner {
        pxTokenVault = _pxTokenVault;
    }

    /**
     * @notice Allows the contract owner to withdraw accumulated fees.
     * @dev Only the contract owner can call this function.
     */
    function withdrawFees() external onlyOwner {
        (bool sent, ) = payable(owner()).call{value: address(this).balance}("");
        require(sent, "Failed to send Ether");
    }
}
