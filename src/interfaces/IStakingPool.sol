// SPDX-License-Identifier: AGPL-3.0
pragma solidity 0.8.19;

interface IStakingPool {
    event Staked(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);
    event RewardClaimed(address indexed user, uint256 amount);
    event EpochUpdated(uint256 indexed epoch, uint256 reward);
}
