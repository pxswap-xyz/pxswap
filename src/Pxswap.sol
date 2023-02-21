// SPDX-License-Identifier: AGPL-3.0
pragma solidity 0.8.15;

import {SwapData} from "./SwapData.sol";
import {Ownable} from "./utils/Ownable.sol";
import {IERC20} from "./utils//IERC20.sol";
import {IERC721} from "lib/openzeppelin-contracts/contracts/token/ERC721/IERC721.sol";
import {PxswapERC721Receiver} from "./utils/PxswapERC721Receiver.sol";

/**
 * @title pxswap
 * @author pxswap (https://github.com/pxswap-xyz/pxswap/blob/main/src/Pxswap.sol)
 * @dev This contract is for buying, selling and swapping non-fungible tokens (NFTs)
 */
contract Pxswap is SwapData, Ownable, PxswapERC721Receiver {

    /////////////////////////////////////////////
    //                 Events
    /////////////////////////////////////////////

    event PutSwap(
        uint256 id, 
        address[] nftsGiven, 
        uint256[] idsGiven, 
        address[] nftsWanted, 
        uint256[] idsWanted,
        address tokenWanted,
        uint256 amount,
        uint256 ethAmount);
    event CancelSwap(uint256 id);
    event AcceptSwap(uint256 id);
    event OpenLimitBuy(uint256 id, address wantNft, uint256 wantId, uint256 price);
    event OpenLimitSell(uint256 id, address giveNft, uint256 giveId, uint256 price);

    /////////////////////////////////////////////
    //                 Storage
    /////////////////////////////////////////////

    address public protocol;
    uint256 public fee = 100; // %1
    bool public mutex;

    /////////////////////////////////////////////
    //                 Structs
    /////////////////////////////////////////////

    Swap[] public swaps;
    LimitBuy[] public limitBuys;
    LimitSell[] public limitSells;

    /////////////////////////////////////////////
    //                Modifiers
    /////////////////////////////////////////////

    modifier noReentrancy() {
        require(!mutex, "Mutex is already set, reentrancy detected!");
        mutex = true;
        _;
        mutex = false;
    }

    /////////////////////////////////////////////
    //                  Swap
    /////////////////////////////////////////////

    function putSwap(
        address[] memory nftsGiven,
        uint256[] memory idsGiven,
        address[] memory nftsWanted,
        uint256[] memory idsWanted,
        address tokenWanted,
        uint256 amount,
        uint256 ethAmount
    ) public noReentrancy {
        for (uint256 i; i < nftsGiven.length; i++) {
            IERC721 nft = IERC721(nftsGiven[i]);
            require(nft.balanceOf(msg.sender) >= 1);
            nft.safeTransferFrom(msg.sender, address(this), idsGiven[i]);
        }

        swaps.push(
            Swap({
                active: true,
                seller: msg.sender,
                giveNft: nftsGiven,
                giveId: idsGiven,
                wantNft: nftsWanted,
                wantId: idsWanted,
                wantToken: tokenWanted,
                amount: amount,
                ethAmount: ethAmount
            })
        );

        uint256 id = swaps.length - 1;

        emit PutSwap(
            id, 
            nftsGiven, 
            idsGiven, 
            nftsWanted, 
            idsWanted, 
            tokenWanted, 
            amount, 
            ethAmount);
    }

    function cancelSwap(uint256 id) public noReentrancy {
        Swap storage swap = swaps[id];
        require(msg.sender == swap.seller, "Unauthorized call, cant cancel swap!");
        require(swap.active == true, "Swap is not active!");

        swap.active = false;

        for (uint256 i; i < swap.giveNft.length; i++) {
            IERC721 nft = IERC721(swap.giveNft[i]);
            require(nft.balanceOf(address(this)) >= 1);
            nft.safeTransferFrom(address(this), msg.sender, swap.giveId[i]);
        }

        emit CancelSwap(id);
    }

    function acceptSwap(uint256 id, uint256[] memory tokenIds) public payable noReentrancy {
        Swap storage swap = swaps[id];
        require(swap.active == true, "Swap is not active!");
        swap.active = false;

        if (swap.wantNft.length > 0 && swap.wantToken != address(0) && swap.ethAmount > 0) {
            require(msg.value >= swap.ethAmount, "Not enough Eth");

            if (swap.wantId.length > 0) {
                for (uint256 i; i < swap.wantNft.length; i++) {
                    IERC721 nft = IERC721(swap.giveNft[i]);
                    require(nft.balanceOf(msg.sender) >= 1);
                    nft.safeTransferFrom(msg.sender, swap.seller, swap.wantId[i]);
                }
            } else if (swap.wantId.length == 0) {
                for (uint256 i; i < swap.wantNft.length; i++) {
                    IERC721 nft = IERC721(swap.giveNft[i]);
                    require(nft.balanceOf(msg.sender) >= 1);
                    nft.safeTransferFrom(msg.sender, swap.seller, tokenIds[i]);
                }
            }

            IERC20 token = IERC20(swap.wantToken);

            require(token.balanceOf(msg.sender) >= swap.amount);

            uint256 protocolTokenFee = swap.amount / fee;

            uint256 finalTokenAmount = swap.amount - protocolTokenFee;

            token.transferFrom(msg.sender, swap.seller, finalTokenAmount);
            token.transferFrom(msg.sender, protocol, protocolTokenFee);

            uint256 protocolEthFee = msg.value / fee;

            uint256 finalEthAmount = swap.ethAmount - protocolEthFee;

            (bool sent1,) = address(swap.seller).call{value: finalEthAmount}("");
            require(sent1, "Call must return true");

            (bool sent2,) = protocol.call{value: protocolEthFee}("");
            require(sent2, "Call must return true");
        } else if (
            swap.wantNft.length == 0 && swap.wantToken != address(0) && swap.ethAmount > 0
        ) {
            require(msg.value >= swap.ethAmount);

            IERC20 token = IERC20(swap.wantToken);
            require(token.balanceOf(msg.sender) >= swap.amount);

            uint256 decimals = token.decimals();

            uint256 protocolTokenFee = swap.amount / fee;

            uint256 finalTokenAmount = swap.amount - protocolTokenFee;

            token.transferFrom(msg.sender, swap.seller, swap.amount);
            token.transferFrom(msg.sender, protocol, protocolTokenFee);

            uint256 protocolEthFee = msg.value / fee;

            uint256 finalEthAmount = swap.ethAmount - protocolEthFee;

            (bool sent1,) = address(swap.seller).call{value: finalEthAmount}("");
            require(sent1, "Call must return true");

            (bool sent2,) = protocol.call{value: protocolEthFee}("");
            require(sent2, "Call must return true");
        } else if (
            swap.wantNft.length == 0 && swap.wantToken == address(0) && swap.ethAmount > 0
        ) {
            uint256 protocolEthFee = msg.value / fee;

            uint256 finalEthAmount = swap.ethAmount - protocolEthFee;

            (bool sent1,) = address(swap.seller).call{value: finalEthAmount}("");
            require(sent1, "Call must return true");

            (bool sent2,) = protocol.call{value: protocolEthFee}("");
            require(sent2, "Call must return true");
        } else if (
            swap.wantNft.length > 0 && swap.wantToken == address(0) && swap.ethAmount > 0
        ) {
            require(msg.value >= swap.ethAmount, "Not enough Eth");

            if (swap.wantId.length > 0) {
                for (uint256 i; i < swap.wantNft.length; i++) {
                    IERC721 nft = IERC721(swap.giveNft[i]);
                    require(nft.balanceOf(msg.sender) >= 1);
                    nft.safeTransferFrom(msg.sender, swap.seller, swap.wantId[i]);
                }
            } else if (swap.wantId.length == 0) {
                for (uint256 i; i < swap.wantNft.length; i++) {
                    IERC721 nft = IERC721(swap.giveNft[i]);
                    require(nft.balanceOf(msg.sender) >= 1);
                    nft.safeTransferFrom(msg.sender, swap.seller, tokenIds[i]);
                }
            }

            uint256 protocolEthFee = msg.value / fee;

            uint256 finalEthAmount = swap.ethAmount - protocolEthFee;

            (bool sent1,) = address(swap.seller).call{value: finalEthAmount}("");
            require(sent1, "Call must return true");

            (bool sent2,) = protocol.call{value: protocolEthFee}("");
            require(sent2, "Call must return true");
        }

        emit AcceptSwap(id);
    }

    /////////////////////////////////////////////
    //                 Limit
    /////////////////////////////////////////////

    function openLimitBuy(address wantNft, uint256 wantId) public payable noReentrancy {
        require(wantNft != address(0), "Zero address not allowed!");
        require(msg.value > 100000000000000, "Non-dust amount required!");

        uint256 protocolEthFee = msg.value / fee;

        uint256 price = msg.value - protocolEthFee;

/*         (bool sent,) = address(protocol).call{value: protocolEthFee}("");
        require(sent, "Call must return true"); */

        limitBuys.push(
            LimitBuy({
                active: true,
                buyer: msg.sender,
                wantNft: wantNft,
                wantId: wantId,
                price: price,
                fee: protocolEthFee
            })
        );

        uint256 id = limitBuys.length - 1;

        emit OpenLimitBuy(
            id, 
            wantNft, 
            wantId, 
            price);
    }

    function cancelBuyOrder(uint256 id) public noReentrancy {
        LimitBuy storage limit = limitBuys[id];
        require(limit.buyer == msg.sender, "Only owner!");
        require(limit.active == true, "Order is not active!");

        limit.active = false;

        uint256 amount = limit.price + limit.fee;

        (bool sent,) = limit.buyer.call{value: amount}("");
        require(sent, "Call must return true");

        emit CancelSwap(id);

    }

    function fillBuyOrder(uint256 id, uint256 tokenId) public noReentrancy {
        LimitBuy storage limit = limitBuys[id];
        require(limit.active == true, "Order is not active!");

        limit.active = false;

        IERC721 nft = IERC721(limit.wantNft);
        require(nft.balanceOf(msg.sender) >= 1);
        if (limit.wantId == 0) {
            nft.safeTransferFrom(msg.sender, address(this), tokenId);
        } else if (limit.wantId != 0) {
            nft.safeTransferFrom(msg.sender, address(this), limit.wantId);
        }

        (bool sent,) = msg.sender.call{value: limit.price}("");
        require(sent, "Call must return true");

        (bool sent1,) = address(protocol).call{value: limit.fee}("");
        require(sent1, "Call must return true");

        emit CancelSwap(id);

    }

    function openLimitSell(address giveNft, uint256 giveId, uint256 price) public noReentrancy {
        require(giveNft != address(0), "Zero address not allowed!");

        IERC721 nft = IERC721(giveNft);
        require(nft.balanceOf(msg.sender) >= 1);

        nft.safeTransferFrom(msg.sender, address(this), giveId);

        uint256 protocolEthFee = price / fee;

        uint256 amount = price - protocolEthFee;

        limitSells.push(
            LimitSell({
                active: true,
                seller: msg.sender,
                giveNft: giveNft,
                giveId: giveId,
                price: amount,
                fee: protocolEthFee
            })
        );

        uint256 id = limitSells.length - 1;

        emit OpenLimitSell(
            id, 
            giveNft, 
            giveId, 
            price);
    }

    /////////////////////////////////////////////
    //                  Admin
    /////////////////////////////////////////////

    /**
     * @dev Function to set the protocol address.
     * @param protocol_ The address of the protocol.
     */

    function setProtocol(address protocol_) public onlyOwner {
        protocol = protocol_;
    }

    /**
     * @dev Allows the contract owner to set the transaction fee.
     * @param fee_ The new transaction fee.
     */
    function setFee(uint256 fee_) public onlyOwner {
        fee = fee_;
    }
}
