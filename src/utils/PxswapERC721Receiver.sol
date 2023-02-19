// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

import "lib/openzeppelin-contracts/contracts/token/ERC721/utils/ERC721Holder.sol";

contract PxswapERC721Receiver is ERC721Holder {
    mapping(uint256 => address) private sentFrom;

    function onERC721Received(address from, address to, uint256 id, bytes memory data)
        public
        override
        returns (bytes4)
    {
        sentFrom[id] = from;
        return bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"));
    }

    function _sentFrom(uint256 id) public view returns (address) {
        return sentFrom[id];
    }
}
