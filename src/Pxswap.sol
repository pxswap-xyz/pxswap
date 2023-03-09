// SPDX-License-Identifier: AGPL-3.0
pragma solidity 0.8.19;

import {SwapData} from "./SwapData.sol";
import {Ownable} from "./utils/Ownable.sol";
import {HandleERC20} from "./utils/HandleERC20.sol";
import {HandleERC721} from "./utils/HandleERC721.sol";
import {PxswapERC721Receiver} from "./utils/PxswapERC721Receiver.sol";

//   ______   __  __     ______     __     __     ______     ______
//  /\  == \ /\_\_\_\   /\  ___\   /\ \  _ \ \   /\  __ \   /\  == \
//  \ \  _-/ \/_/\_\/_  \ \___  \  \ \ \/ ".\ \  \ \  __ \  \ \  _-/
//   \ \_\     /\_\/\_\  \/\_____\  \ \__/".~\_\  \ \_\ \_\  \ \_\
//    \/_/     \/_/\/_/   \/_____/   \/_/   \/_/   \/_/\/_/   \/_/

/**
 * @title pxswap
 * @author pxswap (https://github.com/pxswap-xyz/pxswap/blob/main/src/Pxswap.sol)
 * @author Ali Konuk - @alikonuk1
 * @dev This contract is for buying, selling and swapping non-fungible tokens (NFTs)
 * @dev Please reach out to ali@pxswap.xyz if you find any issues
 */
contract Pxswap is SwapData, Ownable, HandleERC20, HandleERC721, PxswapERC721Receiver {
    /////////////////////////////////////////////
    //                 Events
    /////////////////////////////////////////////

    event PutSwap(
        uint256 indexed id,
        address[] nftsGiven,
        uint256[] idsGiven,
        address[] nftsWanted,
        uint256[] idsWanted,
        address tokenWanted,
        uint256 amount,
        uint256 ethAmount
    );
    event CancelSwap(uint256 id);
    event AcceptSwap(uint256 id);
    event OpenLimitBuy(uint256 indexed id, address indexed wantNft, uint256 wantId, uint256 indexed price);
    event CancelBuyOrder(uint256 indexed id);
    event FillBuy(uint256 id, address seller, address buyer, uint256 price, uint256 fee);
    event OpenLimitSell(uint256 indexed id, address indexed giveNft, uint256 giveId, uint256 indexed price);
    event CancelSellOrder(uint256 id);
    event FillSell(uint256 indexed id, address indexed buyer, address seller, uint256 indexed price, uint256 fee);
    event OfferP2P(
        uint256 indexed id,
        address indexed buyer,
        address[] nftsGiven,
        uint256[] idsGiven,
        address[] nftsWanted,
        uint256[] idsWanted,
        address tokenWanted,
        uint256 amount,
        uint256 ethAmount
    );
    event CancelP2P(uint256 indexed id);

    /////////////////////////////////////////////
    //                 Storage
    /////////////////////////////////////////////

    Swap[] public swaps;
    LimitBuy[] public limitBuys;
    LimitSell[] public limitSells;

    address public protocol;
    uint256 public fee = 100; // %1 fee
    bool public mutex;

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
    ) external noReentrancy {
        transferNft(nftsGiven, msg.sender, address(this), nftsGiven.length, idsGiven);

        swaps.push(
            Swap({
                active: true,
                seller: msg.sender,
                buyer: address(0),
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

        emit PutSwap(id, nftsGiven, idsGiven, nftsWanted, idsWanted, tokenWanted, amount, ethAmount);
    }

    function cancelSwap(uint256 id) external noReentrancy {
        Swap storage swap = swaps[id];
        require(msg.sender == swap.seller, "Unauthorized call, cant cancel swap!");
        require(swap.active == true, "Swap is not active!");

        swap.active = false;

        transferNft(swap.giveNft, address(this), msg.sender, swap.giveNft.length, swap.giveId);

        emit CancelSwap(id);
    }

    function acceptSwap(uint256 id, uint256[] memory tokenIds) public payable noReentrancy {
        Swap storage swap = swaps[id];
        require(swap.active == true, "Swap is not active!");
        swap.active = false;

        uint256 lenWantNft = swap.wantNft.length;
        uint256 sethAmount = swap.ethAmount;
        uint256 samount = swap.amount;
        address sseller = swap.seller;
        uint256 lenwantId = swap.wantId.length;
        address swantToken = swap.wantToken;

        if (lenWantNft != 0 && swantToken != address(0) && sethAmount != 0) {
            require(msg.value >= sethAmount, "Not enough Eth");

            if (lenwantId != 0) {
                transferNft(swap.wantNft, msg.sender, sseller, lenWantNft, swap.wantId);
            } else if (lenwantId == 0) {
                transferNft(swap.wantNft, msg.sender, sseller, lenWantNft, tokenIds);
            }

            transferNft(swap.giveNft, address(this), msg.sender, swap.giveNft.length, swap.giveId);

            uint256 protocolTokenFee = samount / fee;
            uint256 finalTokenAmount = samount - protocolTokenFee;

            transferToken(swantToken, msg.sender, sseller, protocol, finalTokenAmount, protocolTokenFee);

            uint256 protocolEthFee = msg.value / fee;
            uint256 finalEthAmount = sethAmount - protocolEthFee;

            (bool sent1,) = address(sseller).call{value: finalEthAmount}("");
            require(sent1, "Call must return true");

            (bool sent2,) = protocol.call{value: protocolEthFee}("");
            require(sent2, "Call must return true");
        } else if (lenWantNft == 0 && swantToken != address(0) && sethAmount != 0) {
            require(msg.value >= sethAmount);

            uint256 protocolTokenFee = samount / fee;
            uint256 finalTokenAmount = samount - protocolTokenFee;

            transferToken(swantToken, msg.sender, sseller, protocol, finalTokenAmount, protocolTokenFee);

            uint256 protocolEthFee = msg.value / fee;
            uint256 finalEthAmount = sethAmount - protocolEthFee;

            (bool sent1,) = address(sseller).call{value: finalEthAmount}("");
            require(sent1, "Call must return true");

            (bool sent2,) = protocol.call{value: protocolEthFee}("");
            require(sent2, "Call must return true");
        } else if (lenWantNft == 0 && swantToken == address(0) && sethAmount != 0) {
            uint256 protocolEthFee = msg.value / fee;

            uint256 finalEthAmount = sethAmount - protocolEthFee;

            (bool sent1,) = address(sseller).call{value: finalEthAmount}("");
            require(sent1, "Call must return true");

            (bool sent2,) = protocol.call{value: protocolEthFee}("");
            require(sent2, "Call must return true");
        } else if (lenWantNft != 0 && swantToken == address(0) && sethAmount != 0) {
            require(msg.value >= sethAmount, "Not enough Eth");

            if (lenwantId != 0) {
                transferNft(swap.giveNft, msg.sender, sseller, lenWantNft, swap.wantId);
            } else if (lenwantId == 0) {
                transferNft(swap.giveNft, msg.sender, sseller, lenWantNft, tokenIds);
            }

            uint256 protocolEthFee = msg.value / fee;

            uint256 finalEthAmount = sethAmount - protocolEthFee;

            (bool sent1,) = address(sseller).call{value: finalEthAmount}("");
            require(sent1, "Call must return true");

            (bool sent2,) = protocol.call{value: protocolEthFee}("");
            require(sent2, "Call must return true");
        }

        emit AcceptSwap(id);
    }

    /////////////////////////////////////////////
    //                 Limit
    /////////////////////////////////////////////

    function openLimitBuy(address wantNft, uint256 wantId) external payable noReentrancy {
        require(wantNft != address(0), "Zero address not allowed!");
        require(msg.value > 100000000000000, "Non-dust amount required!");

        limitBuys.push(LimitBuy({active: true, buyer: msg.sender, wantNft: wantNft, wantId: wantId, price: msg.value}));

        uint256 id = limitBuys.length - 1;

        emit OpenLimitBuy(id, wantNft, wantId, msg.value);
    }

    function cancelBuyOrder(uint256 id) external noReentrancy {
        LimitBuy storage limit = limitBuys[id];
        require(limit.buyer == msg.sender, "Only owner!");
        require(limit.active == true, "Order is not active!");

        limit.active = false;

        (bool sent,) = limit.buyer.call{value: limit.price}("");
        require(sent, "Call must return true");

        emit CancelBuyOrder(id);
    }

    function fillBuyOrder(uint256 id, uint256 tokenId) external noReentrancy {
        LimitBuy storage limit = limitBuys[id];
        require(limit.active == true, "Order is not active!");

        limit.active = false;

        uint256 lwantId = limit.wantId;
        address lbuyer = limit.buyer;

        if (lwantId == 0) {
            sTransferNft(limit.wantNft, msg.sender, lbuyer, tokenId);
        } else if (lwantId != 0) {
            sTransferNft(limit.wantNft, msg.sender, lbuyer, lwantId);
        }

        uint256 protocolFee = limit.price / fee;

        uint256 finalAmount = limit.price - protocolFee;

        (bool sent,) = msg.sender.call{value: finalAmount}("");
        require(sent, "Call must return true");

        (bool sent1,) = address(protocol).call{value: protocolFee}("");
        require(sent1, "Call must return true");

        emit FillBuy(id, msg.sender, lbuyer, finalAmount, protocolFee);
    }

    function openLimitSell(address giveNft, uint256 giveId, uint256 price) external noReentrancy {
        require(giveNft != address(0), "Zero address not allowed!");

        sTransferNft(giveNft, msg.sender, address(this), giveId);

        limitSells.push(LimitSell({active: true, seller: msg.sender, giveNft: giveNft, giveId: giveId, price: price}));

        uint256 id = limitSells.length - 1;

        emit OpenLimitSell(id, giveNft, giveId, price);
    }

    function cancelSellOrder(uint256 id) external noReentrancy {
        LimitSell storage limit = limitSells[id];

        require(limit.seller == msg.sender, "Only owner!");
        require(limit.active == true, "Order is not active!");

        limit.active = false;

        sTransferNft(limit.giveNft, address(this), msg.sender, limit.giveId);

        emit CancelSellOrder(id);
    }

    function fillSellOrder(uint256 id) external payable noReentrancy {
        LimitSell storage limit = limitSells[id];

        uint256 lprice = limit.price;
        bool lactive = limit.active;

        uint256 protocolFee = lprice / fee;

        uint256 finalAmount = lprice - protocolFee;

        require(lactive == true, "Order is not active!");
        require(msg.value == lprice);

        lactive = false;

        sTransferNft(limit.giveNft, address(this), msg.sender, limit.giveId);

        (bool sent,) = limit.seller.call{value: finalAmount}("");
        require(sent, "Call must return true");

        (bool sent1,) = protocol.call{value: protocolFee}("");
        require(sent1, "Call must return true");

        emit FillSell(id, msg.sender, limit.seller, finalAmount, protocolFee);
    }

    /////////////////////////////////////////////
    //                   P2P
    /////////////////////////////////////////////

    function offerP2P(
        address buyer,
        address[] memory nftsGiven,
        uint256[] memory idsGiven,
        address[] memory nftsWanted,
        uint256[] memory idsWanted,
        address tokenWanted,
        uint256 amount,
        uint256 ethAmount
    ) external noReentrancy {
        transferNft(nftsGiven, msg.sender, address(this), nftsGiven.length, idsGiven);

        swaps.push(
            Swap({
                active: true,
                seller: msg.sender,
                buyer: buyer,
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

        emit OfferP2P(id, buyer, nftsGiven, idsGiven, nftsWanted, idsWanted, tokenWanted, amount, ethAmount);
    }

    function cancelP2P(uint256 id) external {
        Swap storage swap = swaps[id];
        require(msg.sender == swap.seller, "Unauthorized call, cant cancel swap!");
        require(swap.active == true, "Swap is not active!");

        swap.active = false;

        address[] storage giveNft = swap.giveNft;

        transferNft(giveNft, address(this), msg.sender, giveNft.length, swap.giveId);

        emit CancelP2P(id);
    }

    function acceptP2P(uint256 id) external payable {
        Swap storage swap = swaps[id];
        require(swap.buyer == msg.sender, "Only buyer!");

        acceptSwap(id, swap.wantId);
    }

    /////////////////////////////////////////////
    //                  Admin
    /////////////////////////////////////////////

    /**
     * @dev Function to set the protocol address.
     * @param protocol_ The address of the protocol.
     */

    function setProtocol(address protocol_) external payable onlyOwner {
        assembly {
            sstore(protocol.slot, protocol_)
        }
    }

    /**
     * @dev Allows the contract owner to set the transaction fee.
     * @param fee_ The new transaction fee.
     */
    function setFee(uint256 fee_) external payable onlyOwner {
        assembly {
            sstore(fee.slot, fee_)
        }
    }

    /////////////////////////////////////////////
    //                Modifiers
    /////////////////////////////////////////////

    modifier noReentrancy() {
        _nonReentrantBefore();
        _;
        _nonReentrantAfter();
    }

    function _nonReentrantBefore() internal {
        require(!mutex, "Mutex is already set, reentrancy detected!");
        mutex = true;
    }

    function _nonReentrantAfter() internal {
        mutex = false;
    }

    /////////////////////////////////////////////
    //                Getter
    /////////////////////////////////////////////

    function getLength() external view returns (uint256) {
        return swaps.length;
    }
}
