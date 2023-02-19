// SPDX-License-Identifier: AGPL-3.0
pragma solidity 0.8.15;

import "lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";

contract ERC20Interactions {
    event TokenSet(address setter, address token);

    address private token;

    function _setTokenContract(address _token) internal {
        emit TokenSet(msg.sender, _token);
        token = _token;
    }

    function getToken() internal view returns (address) {
        return token;
    }

    function _tokenBalance(address owner) internal view returns (uint256) {
        IERC20 _token = IERC20(token);
        uint256 tokenBalance = _token.balanceOf(owner);
        return tokenBalance;
    }

    function _transferTokens(address from, address to, uint256 amount) internal {
        IERC20 _token = IERC20(token);
        _token.transferFrom(from, to, amount);
    }
}
