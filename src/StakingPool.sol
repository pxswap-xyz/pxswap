// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import "lib/openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol";
import "lib/openzeppelin-contracts/contracts/security/ReentrancyGuard.sol";
import "lib/openzeppelin-contracts/contracts/access/Ownable.sol";
import {IStakingPool} from "./interfaces/IStakingPool.sol";

contract StakingPool is IStakingPool, ReentrancyGuard, Ownable {
    using SafeERC20 for IERC20;

    IERC20 public stakingToken;
    uint256 public epochDuration;
    uint256 public currentEpoch;
    uint256 public lastEpochUpdate;

    struct UserInfo {
        uint256 stakedAmount;
        uint256 lastEpochClaimed;
        uint256 shares;
    }

    mapping(address => UserInfo) public userInfo;
    uint256 public totalStaked;
    uint256 public totalShares;

    mapping(uint256 => uint256) public epochRewards;

    constructor(IERC20 _stakingToken, uint256 _epochDuration) {
        stakingToken = _stakingToken;
        epochDuration = _epochDuration;
        lastEpochUpdate = block.timestamp;
    }

    function stake(uint256 _amount) external nonReentrant {
        require(_amount > 0, "Cannot stake 0");
        updateEpoch();

        stakingToken.safeTransferFrom(msg.sender, address(this), _amount);

        UserInfo storage user = userInfo[msg.sender];
        user.stakedAmount += _amount;
        totalStaked += _amount;

        // Calculate new shares
        uint256 newShares = _amount;
        if (totalShares > 0) {
            newShares = (_amount * totalShares) / totalStaked;
        }
        user.shares += newShares;
        totalShares += newShares;

        emit Staked(msg.sender, _amount);
    }

    function withdraw(uint256 _amount) external nonReentrant {
        UserInfo storage user = userInfo[msg.sender];
        require(user.stakedAmount >= _amount, "Insufficient staked amount");
        updateEpoch();
        claimReward();

        user.stakedAmount -= _amount;
        totalStaked -= _amount;

        // Recalculate shares
        uint256 sharesToRemove = (_amount * user.shares) / user.stakedAmount;
        user.shares -= sharesToRemove;
        totalShares -= sharesToRemove;

        stakingToken.safeTransfer(msg.sender, _amount);

        emit Withdrawn(msg.sender, _amount);
    }

    function claimReward() public nonReentrant {
        updateEpoch();
        UserInfo storage user = userInfo[msg.sender];
        uint256 reward = calculateReward(msg.sender);
        require(reward > 0, "No reward to claim");

        user.lastEpochClaimed = currentEpoch;
        (bool success,) = msg.sender.call{value: reward}("");
        require(success, "Reward transfer failed");

        emit RewardClaimed(msg.sender, reward);
    }

    function calculateReward(address _user) public view returns (uint256) {
        UserInfo storage user = userInfo[_user];
        uint256 reward = 0;
        for (uint256 i = user.lastEpochClaimed + 1; i <= currentEpoch; i++) {
            reward += (epochRewards[i] * user.shares) / totalShares;
        }
        return reward;
    }

    function updateEpoch() public {
        uint256 epochsPassed = (block.timestamp - lastEpochUpdate) / epochDuration;
        if (epochsPassed > 0) {
            currentEpoch += epochsPassed;
            lastEpochUpdate = block.timestamp;
        }
    }

    // Function to receive ETH rewards
    receive() external payable {
        updateEpoch();
        epochRewards[currentEpoch] += msg.value;
        emit EpochUpdated(currentEpoch, msg.value);
    }

    // Admin function to update epoch duration
    function setEpochDuration(uint256 _newDuration) external onlyOwner {
        updateEpoch();
        epochDuration = _newDuration;
    }
}
