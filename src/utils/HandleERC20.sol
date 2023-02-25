// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

import {IERC20} from "./IERC20.sol";

contract HandleERC20 {
    
    function transferToken(
        address wantToken, 
        address to,
        address protocol,
        uint256 amount, 
        uint256 fee
        ) public {
            IERC20 token = IERC20(wantToken);

            require(token.transferFrom(msg.sender, to, amount), "transfer to to error");
            require(token.transferFrom(msg.sender, protocol, fee), "transfer to protocol error");
    }
}
