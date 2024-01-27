// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

library Errors {
    error NOT_COUNTER_PARTY();
    error LENGTHS_MISMATCH();
    error ONLY_INITIATOR();
    error TRADE_CLOSED();
    error NOT_OWNER();
    error PAY_FEE();
}
