// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {ERC20} from "lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";

contract MockERC20 is ERC20 {
    constructor(string memory _name, string memory _symbol) ERC20(_name, _symbol) {}

    function mint(address recipient) public {
        _mint(recipient, 100 ether);
    }

    function _increaseAllowance(address spender, uint256 addedValue) public {
        increaseAllowance(spender, addedValue);
    }
}
