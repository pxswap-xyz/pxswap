// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

import {IERC20} from "./IERC20.sol";

contract HandleERC20 {
    
    function transferToken(
        address wantToken, 
        address from,
        address to,
        address protocol,
        uint256 amount, 
        uint256 fee
        ) internal {
            IERC20 token = IERC20(wantToken);

            require(token.balanceOf(from) >= amount + fee , "Not enough balance");

            require(token.transferFrom(from, to, amount), "transfer to to error");
            require(token.transferFrom(from, protocol, fee), "transfer to protocol error");
    }
}
