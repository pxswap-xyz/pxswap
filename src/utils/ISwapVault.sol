// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

interface ISwapVault {
    function toVault(address[] memory nfts, address from, uint256[] memory ids) external;

    function fromVault(address[] memory nfts, address to, uint256[] memory ids) external;
}
