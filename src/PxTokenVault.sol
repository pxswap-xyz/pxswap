// SPDX-License-Identifier: AGPL-3.0
pragma solidity 0.8.19;

import "lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import "lib/openzeppelin-contracts/contracts/access/Ownable.sol";
import {ReentrancyGuard} from "./abstract/ReentrancyGuard.sol";
import {Errors} from "./libraries/Errors.sol";

contract PxTokenVault is Ownable, ReentrancyGuard {
    IERC20 public pxToken;
    mapping(address => uint256) public stakedBalances;
    mapping(address => uint256) public claimableRewards;
    uint256 public totalStaked;

    uint256 public EPOCH_LENGTH;


    constructor(address _pxTokenAddress) {
        pxToken = IERC20(_pxTokenAddress);
    }

    function stake(uint256 _amount) external nonReentrant {
        if(_amount == 0) {
            revert Errors.INVALID_AMOUNT();
        }
        pxToken.transferFrom(msg.sender, address(this), _amount);
        stakedBalances[msg.sender] += _amount;
        totalStaked += _amount;
    }

    function unstake(uint256 _amount) external nonReentrant {
        if(stakedBalances[msg.sender] < _amount) {
            revert Errors.INVALID_AMOUNT();
        }
        stakedBalances[msg.sender] -= _amount;
        totalStaked -= _amount;
        pxToken.transfer(msg.sender, _amount);
    }

    receive() external payable {}
}
