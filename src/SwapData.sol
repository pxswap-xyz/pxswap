// SPDX-License-Identifier: AGPL-3.0
pragma solidity 0.8.19;

contract SwapData {
    /////////////////////////////////////////////
    //                  Enums
    /////////////////////////////////////////////

    enum tokenStandard {
        ERC20,
        ERC721,
        ERC1155
    }

    enum swapStatus {
        Opened,
        Closed,
        Cancelled
    }

    /////////////////////////////////////////////
    //                 Structs
    /////////////////////////////////////////////

    struct Swap {
        address payable maker;
        bool discountMaker;
        uint256 valueMaker;
        uint256 flatFeeMaker;
        address payable taker;
        bool discountTaker;
        uint256 valueTaker;
        uint256 flatFeeTaker;
        uint256 swapStart;
        bool flagFlatFee;
        swapStatus status;
    }

    struct SwapParties {
        tokenStandard tokenStandard; // 0: ERC20, 1: ERC721, 2: ERC1155
        uint256[] amount; // If token is an ERC20 or ERC1155, then check the balance.
        uint256[] tokenId; // If token is an ERC721 or ERC1155, then check the token ID.
        address token;
        bytes data;
    }

    struct closeSwap {
        address from;
        address to;
        bool discount;
        uint256 feeValue;
        uint256 dealValue;
        uint256 vaultFee;
        uint256 fee;
        uint256 nativeDealValue;
        uint256 flatFeeValue;
    }

    struct PointAddress {
        address PXS; // pxswap's limited edition ERC721 address
        address PARTNER; // partner's ERC721 address
        address VAULT; // pxswap's vault address
    }

}
