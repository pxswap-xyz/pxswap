// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

/* import "lib/solmate/src/tokens/ERC20.sol"; */
import {ERC20} from "lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";

contract MockERC20 is ERC20 {
    constructor(string memory _name, string memory _symbol) ERC20(_name, _symbol) {}

    function mint(address recipient) public {
        _mint(recipient, 100 ether);
    }
}
