// SPDX-License-Identifier: AGPL-3.0
pragma solidity 0.8.19;

import {SwapData} from "./SwapData.sol";
import {Ownable} from "./utils/Ownable.sol";
import {IERC20} from "./utils/IERC20.sol";
import {IERC721} from "./utils/IERC721.sol";
import {IERC1155} from "./utils/IERC1155.sol";
import {Counters} from "./utils/Counters.sol";
/* import {HandleERC20} from "./utils/HandleERC20.sol";
import {HandleERC721} from "./utils/HandleERC721.sol";
 */

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
contract Pxswap is SwapData, Ownable {
    using Counters for Counters.Counter;

    /////////////////////////////////////////////
    //                 Events
    /////////////////////////////////////////////

    event swapEvent(
        address indexed maker, uint256 indexed time, swapStatus indexed status, uint256 swapId, address taker
    );

    /////////////////////////////////////////////
    //                 Storage
    /////////////////////////////////////////////

    bool public mutex;
    uint256 public fee = 100; // %1 fee
    uint256 constant secs = 86400;

    PointAddress public pointAddress;
    Counters.Counter private _ids;

    /////////////////////////////////////////////
    //                 Mappings
    /////////////////////////////////////////////

    mapping(uint256 => Swap) swap_;
    mapping(address => bool) ERC20whiteList;
    mapping(address => bool) NFTblackList;
    mapping(uint256 => SwapParties[]) maker;
    mapping(uint256 => SwapParties[]) taker;

    /////////////////////////////////////////////
    //                  Swap
    /////////////////////////////////////////////

    function putSwap(Swap memory swap, SwapParties[] memory maker_, SwapParties[] memory taker_)
        public
        payable
        isEmpty(swap, maker_, taker_)
    {

        (swap.discountMaker, swap.flatFeeMaker) = _isDiscounted();

        require(msg.value >= swap.valueMaker + swap.flatFeeMaker, "More wei needed");

        swap.maker = payable(msg.sender);

        require(swap.maker != swap.taker, "maker=taker");

        swap.swapStart = block.timestamp;
        swap.status = swapStatus.Opened;

        swap_[_ids.current()] = swap;
        _initSwap(_ids.current(), maker_, true);
        _initSwap(_ids.current(), taker_, false);

        emit swapEvent(
            msg.sender, (block.timestamp - (block.timestamp % secs)), swap.status, _ids.current(), swap.taker
        );
        _ids.increment();
    }

    function acceptSwap(uint256 _swapId) public payable noReentrancy {
        Swap memory swap = swap_[_swapId];
        uint256 vaultFee = 0;

        require(swap.status == swapStatus.Opened, "!Open");
        require(swap.taker == msg.sender || swap.taker == address(0), "Wrong counterpart");
        require(swap.maker != swap.taker, "maker=taker");
        require(_swapId < _ids.current(), "id KO");

        swap_[_swapId].taker = payable(msg.sender);
        swap_[_swapId].status = swapStatus.Closed;

        (swap_[_swapId].discountTaker, swap_[_swapId].flatFeeTaker) = _isDiscounted();

        require(msg.value >= swap_[_swapId].valueTaker + swap_[_swapId].flatFeeTaker, "Not enough WEI");


        vaultFee = _execSwap(_swapId, true);

        vaultFee = vaultFee + (_execSwap(_swapId, false));
        require(_transferFees(pointAddress.VAULT, vaultFee), "Fee");
        emit swapEvent(
            swap_[_swapId].taker,
            (block.timestamp - (block.timestamp % secs)),
            swapStatus.Closed,
            _swapId,
            msg.sender
        );
    }

    function cancelSwap(uint256 id) public noReentrancy {
        Swap memory swap = swap_[id];

        require(swap.maker == msg.sender, "!Owner");
        require(swap.status == swapStatus.Opened, "!Open");

        uint256 refund = swap.valueMaker + swap.flatFeeMaker;

        swap_[id].status = swapStatus.Cancelled;

        if (refund > 0) {
            require(_transferFees(msg.sender, refund), "Fee");
        }
        emit swapEvent(msg.sender, (block.timestamp-(block.timestamp%secs)), swapStatus.Cancelled, id, address(0));
    }

    /////////////////////////////////////////////
    //           Internal Swap Calls
    /////////////////////////////////////////////

    function _initSwap(uint256 _id, SwapParties[] memory _nfts, bool _maker) internal {
        uint256 i;
        uint256 j;
        for (i = 0; i < _nfts.length; i++) {
            if (_nfts[i].tokenStandard == tokenStandard.ERC20) {
                require(
                    ERC20whiteList[_nfts[i].token] && _nfts[i].amount.length == 1 && _nfts[i].amount[0] > 0,
                    "ERC20 - Check values"
                );
            } else {
                require(!NFTblackList[_nfts[i].token], "ERC721 - Blacklisted");

                if (_nfts[i].tokenStandard == tokenStandard.ERC721) {
                    require(_nfts[i].tokenId.length == 1, "ERC721 - Missing tokenId");
                }

                if (_nfts[i].tokenStandard == tokenStandard.ERC1155) {
                    require(
                        _nfts[i].tokenId.length > 0 && _nfts[i].amount.length > 0
                            && _nfts[i].tokenId.length == _nfts[i].amount.length,
                        "ERC1155 - Missing tokenId"
                    );
                    j = 0;
                    while (j < _nfts[i].amount.length) {
                        require(_nfts[i].amount[j] > 0, "ERC1155 - Balance must be > 0");
                        j++;
                    }
                }
            }

            if (_maker) {
                maker[_id].push(_nfts[i]);
            } else {
                taker[_id].push(_nfts[i]);
            }
        }
    }

    function _execSwap(uint256 _swapId, bool _maker) internal returns (uint256) {
        Swap memory swap = swap_[_swapId];
        closeSwap memory closeDetail;
        SwapParties[] memory nfts;
        uint256 i;

        if (_maker) {
            nfts = maker[_swapId];
            closeDetail.from = swap.maker;
            closeDetail.to = swap.taker;
            closeDetail.discount = swap.discountMaker;
            closeDetail.nativeDealValue = swap.valueMaker;
            closeDetail.flatFeeValue = swap.flatFeeMaker;
        } else {
            nfts = taker[_swapId];
            closeDetail.from = swap.taker;
            closeDetail.to = swap.maker;
            closeDetail.discount = swap.discountTaker;
            closeDetail.nativeDealValue = swap.valueTaker;
            closeDetail.flatFeeValue = swap.flatFeeTaker;
        }

        closeDetail.dealValue = 0;
        for (i = 0; i < nfts.length; i++) {
            closeDetail.feeValue = 0;
            if (nfts[i].tokenStandard == tokenStandard.ERC20) {
                require(ERC20whiteList[nfts[i].token], "ERC20 - KO");

                closeDetail.dealValue = nfts[i].amount[0];

                if (!closeDetail.discount) {

                    closeDetail.feeValue = calculateFees(closeDetail.dealValue);
                    closeDetail.dealValue = closeDetail.dealValue - closeDetail.feeValue;
                    IERC20(nfts[i].token).transferFrom(closeDetail.from, pointAddress.VAULT, closeDetail.feeValue);
                }
                IERC20(nfts[i].token).transferFrom(closeDetail.from, closeDetail.to, closeDetail.dealValue);
            } else {
                require(!NFTblackList[nfts[i].token], "ERC721 - Blacklisted");
                if (nfts[i].tokenStandard == tokenStandard.ERC721) {
                    IERC721(nfts[i].token).safeTransferFrom(
                        closeDetail.from, closeDetail.to, nfts[i].tokenId[0], nfts[i].data
                    );
                } else if (nfts[i].tokenStandard == tokenStandard.ERC1155) {
                    IERC1155(nfts[i].token).safeBatchTransferFrom(
                        closeDetail.from, closeDetail.to, nfts[i].tokenId, nfts[i].amount, nfts[i].data
                    );
                }
            }

        closeDetail.feeValue = 0;

        if (closeDetail.discount) {
            if (closeDetail.nativeDealValue > 0) {
                closeDetail.fee = closeDetail.fee + closeDetail.nativeDealValue;
            }
        } else {
            closeDetail.feeValue = calculateFees(closeDetail.nativeDealValue);
            closeDetail.nativeDealValue = closeDetail.nativeDealValue - closeDetail.feeValue;
            closeDetail.vaultFee = closeDetail.feeValue + closeDetail.flatFeeValue;

            if (closeDetail.nativeDealValue > 0) {
                closeDetail.fee = closeDetail.fee + closeDetail.nativeDealValue;
            }
        }

        require(_transferFees(closeDetail.to, closeDetail.fee), "Fee");
        return closeDetail.vaultFee;
    }

    function calculateFees(uint256 _amount) internal view returns (uint256) {
        return ((_amount) / (fee));
    }

    function _transferFees(address _to, uint256 _amount) internal returns (bool) {
        bool success = true;
        if (_amount > 0) {
            (success,) = payable(_to).call{value: _amount}("");
        }
        return success;
    }

    /////////////////////////////////////////////
    //                  Admin
    /////////////////////////////////////////////

    /**
     * @dev Allows the contract owner to set the transaction fee.
     * @param fee_ The new transaction fee.
     */
    function setFee(uint256 fee_) external onlyOwner {
        assembly {
            sstore(fee.slot, fee_)
        }
    }

    function setPoints(address pxs_, address partner_, address vault_) public onlyOwner {
        pointAddress.PXS = pxs_;
        pointAddress.PARTNER = partner_;
        pointAddress.VAULT = vault_;
        /*         emit referenceAddressEvent(_engineAddress, _tradeSquad, _partnerSquad, _vault); */
    }

    function setERC20Whitelist(address _dapp, bool _status) public onlyOwner {
        ERC20whiteList[_dapp] = _status;
    }

    function setNFTBlacklist(address _dapp, bool _status) public onlyOwner {
        NFTblackList[_dapp] = _status;
    }

    /////////////////////////////////////////////
    //           Modifiers n Checks
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

    modifier isEmpty(Swap memory swap, SwapParties[] memory maker_, SwapParties[] memory taker_) {
        require(((swap.valueMaker > 0 || maker_.length > 0) && (swap.valueTaker > 0 || taker_.length > 0)), "No assets");
        _;
    }

    function _isDiscounted() internal view returns (bool, uint256) {
        if (
            IERC721(pointAddress.PXS).balanceOf(msg.sender) > 0
                || IERC721(pointAddress.PARTNER).balanceOf(msg.sender) > 0
        ) {
            return (true, 0);
        } else {
            return (false, fee);
        }
    }

    /////////////////////////////////////////////
    //                Getters
    /////////////////////////////////////////////

    function getERC20WhiteList(address token) public view returns (bool) {
        return ERC20whiteList[token];
    }

    function getNFTBlacklist(address token) public view returns (bool) {
        return !NFTblackList[token];
    }

    function getSwap(uint256 id) public view returns (Swap memory) {
        return swap_[id];
    }

    function getSwapPartiesSize(uint256 id, bool isMaker) public view returns (uint256) {
        if (isMaker) {
            return maker[id].length;
        } else {
            return taker[id].length;
        }
    }

    function getSwapParties(uint256 id, bool isMaker, uint256 i) public view returns (SwapParties memory) {
        if (isMaker) {
            return maker[id][i];
        } else {
            return taker[id][i];
        }
    }
}
