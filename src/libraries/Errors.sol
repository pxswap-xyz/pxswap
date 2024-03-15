// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

library Errors {
    error NOT_COUNTER_PARTY();
    error INVALID_FEE_SPLIT();
    error LENGTHS_MISMATCH();
    error INVALID_AMOUNT();
    error ONLY_INITIATOR();
    error TRADE_CLOSED();
    error TRADE_EXISTS();
    error NOT_OWNER();
    error PAY_FEE();
}
