// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Staking is Ownable {
    /**
     *      Contract's states
     */
    uint256 public constant DENOMINATOR = 1000;

    // Stake token contract
    IERC20 public token;

    // Penalty Rate
    uint256 public penaltyRate;

    // Pausable flag
    bool public pausable;

    // Active campaign
    uint256 public activeCampaign;

    // Campaign details: campaignId => details
    mapping(uint256 => Campaign) public campaignDetails;

    // Users's details: user_address => campaignId => poolId => stakedAmount
    mapping(address => mapping(uint256 => mapping(uint256 => uint256)))
        public userStakedAmount;

    /**
     *      Using struct
     */

    // Stored the information about each campaign
    struct Campaign {
        uint256 startStaking;
        uint256 endStaking;
        uint256 startClaiming;
        uint256 endClaiming;
        uint256 totalStaked;
        uint256 totalPenalty;
        uint256 totalPool;
        mapping(uint256 => uint256) poolStakedAmount;
        uint256 result;
    }

    /**
     *      Events
     */
    event Stake(uint256 amount, uint256 campaignId, uint256 poolId);
    event SwitchPool(uint256 campaignId, uint256 fromPoolId, uint256 toPoolId);
    event Unstake(uint256 campaignId, uint256 poolId);
    event Claim(uint256 campaignId, address userAddress, uint256 amount);

    constructor(address _tokenAddress, address _owner, uint256 _penaltyRate) {
        token = IERC20(_tokenAddress);
        penaltyRate = _penaltyRate;
        transferOwnership(_owner);
        pausable = false;
    }

    modifier availableToAction(uint256 _campaignId) {
        require(pausable == false, "Not available to action now");
        require(activeCampaign == _campaignId, "Campaign is not active now");
        require(
            campaignDetails[_campaignId].startStaking <= block.timestamp,
            "Campaign's staking does not start yet"
        );
        require(
            campaignDetails[_campaignId].endStaking >= block.timestamp,
            "Campaign's staking already ended"
        );
        _;
    }

    modifier availableToClaim(uint256 _campaignId) {
        require(pausable == false, "Not available to claim now");
        require(
            campaignDetails[_campaignId].startClaiming <= block.timestamp,
            "Campaign's claiming does not start yet"
        );
        require(
            campaignDetails[_campaignId].endClaiming >= block.timestamp,
            "Campaign's claiming already ended"
        );
        _;
    }

    function setPausable(bool _pausable) external onlyOwner {
        pausable = _pausable;
    }

    function setupCampaign(
        uint256 _campaignId,
        uint256 _startStaking,
        uint256 _endStaking,
        uint256 _startClaiming,
        uint256 _endClaiming,
        uint256 _totalPool
    ) external onlyOwner {
        // require(_campaignId > activeCampaign, "Campaign's already run");
        campaignDetails[_campaignId].startStaking = _startStaking;
        campaignDetails[_campaignId].endStaking = _endStaking;
        campaignDetails[_campaignId].startClaiming = _startClaiming;
        campaignDetails[_campaignId].endClaiming = _endClaiming;
        campaignDetails[_campaignId].totalPool = _totalPool;
    }

    function setPenaltyRate(uint256 _penaltyRate) external onlyOwner {
        penaltyRate = _penaltyRate;
    }

    function stake(
        uint256 _amount,
        uint256 _campaignId,
        uint256 _poolId
    ) external availableToAction(_campaignId) {
        require(
            token.balanceOf(msg.sender) >= _amount,
            "User need to hold enough token to stake"
        );
        require(
            campaignDetails[_campaignId].totalPool >= _poolId && _poolId != 0,
            "PoolId is invalid"
        );
        require(
            token.transferFrom(msg.sender, address(this), _amount),
            "Transfer token to stake contract failed"
        );
        userStakedAmount[msg.sender][_campaignId][_poolId] += _amount;
        campaignDetails[_campaignId].totalStaked += _amount;
        campaignDetails[_campaignId].poolStakedAmount[_poolId] += _amount;
        emit Stake(_amount, _campaignId, _poolId);
    }

    function switchPool(
        uint256 _campaignId,
        uint256 _fromPoolId,
        uint256 _toPoolId
    ) external availableToAction(_campaignId) {
        require(
            campaignDetails[_campaignId].totalPool >= _fromPoolId &&
                _fromPoolId != 0,
            "Invalid fromPoolId"
        );
        require(
            campaignDetails[_campaignId].totalPool >= _toPoolId &&
                _toPoolId != 0,
            "Invalid toPoolId"
        );

        uint256 _switchAmount = userStakedAmount[msg.sender][_campaignId][
            _fromPoolId
        ];
        userStakedAmount[msg.sender][_campaignId][_toPoolId] += _switchAmount;
        userStakedAmount[msg.sender][_campaignId][_fromPoolId] = 0;
        campaignDetails[_campaignId].poolStakedAmount[
            _fromPoolId
        ] -= _switchAmount;
        campaignDetails[_campaignId].poolStakedAmount[
            _toPoolId
        ] += _switchAmount;
        emit SwitchPool(_campaignId, _fromPoolId, _toPoolId);
    }

    function unstake(
        uint256 _campaignId,
        uint256 _poolId
    ) external availableToAction(_campaignId) {
        require(
            campaignDetails[_campaignId].totalPool >= _poolId,
            "Invalid Pool Id"
        );

        uint256 _amountToWithdraw = (userStakedAmount[msg.sender][_campaignId][
            _poolId
        ] * penaltyRate) / DENOMINATOR;
        require(_amountToWithdraw > 0, "User has no staked token");
        campaignDetails[_campaignId].totalPenalty += _amountToWithdraw;
        campaignDetails[_campaignId].totalStaked -= userStakedAmount[
            msg.sender
        ][_campaignId][_poolId];
        campaignDetails[_campaignId].poolStakedAmount[
            _poolId
        ] -= userStakedAmount[msg.sender][_campaignId][_poolId];
        userStakedAmount[msg.sender][_campaignId][_poolId] = 0;
        token.transfer(msg.sender, _amountToWithdraw);
        emit Unstake(_campaignId, _poolId);
    }

    function setResultForCampaign(
        uint256 _campaignId,
        uint256 _winningPool
    ) external onlyOwner {
        require(_winningPool != 0, "Invalid Pool");
        campaignDetails[_campaignId].result = _winningPool;
    }

    function setActiveCampaign(uint256 _campaignId) external onlyOwner {
        activeCampaign = _campaignId;
    }

    function claimRewardAndStakeAmount(
        uint256 _campaignId
    ) external availableToClaim(_campaignId) {
        if (campaignDetails[_campaignId].result == 0) {
            uint256 _userStaked = 0;
            for (
                uint256 i = 1;
                i <= campaignDetails[_campaignId].totalPool;
                i++
            ) {
                _userStaked += userStakedAmount[msg.sender][_campaignId][i];
                campaignDetails[_campaignId].poolStakedAmount[
                    i
                ] -= userStakedAmount[msg.sender][_campaignId][i];
                userStakedAmount[msg.sender][_campaignId][i] = 0;
            }
            campaignDetails[_campaignId].totalPenalty += _userStaked * penaltyRate / DENOMINATOR;
            campaignDetails[_campaignId].totalStaked -= _userStaked;
            token.transfer(
                msg.sender,
                (_userStaked * penaltyRate) / DENOMINATOR
            );
        } else {
            uint256 _result = campaignDetails[_campaignId].result;
            uint256 _userStaked = userStakedAmount[msg.sender][_campaignId][
                _result
            ];

            require(_userStaked > 0, "User stake no token in the winning pool");

            uint256 _total = campaignDetails[_campaignId].totalStaked;
            uint256 _totalWinningPool = campaignDetails[_campaignId]
                .poolStakedAmount[_result];
            uint256 _reward = (_userStaked / _totalWinningPool) *
                (_total - _totalWinningPool);

            userStakedAmount[msg.sender][_campaignId][_result] = 0;

            token.transfer(msg.sender, _userStaked + _reward);
            emit Claim(_campaignId, msg.sender, _userStaked + _reward);
        }
    }

    function withdrawPenalty(uint256 _campaignId) external onlyOwner {
        require(
            campaignDetails[_campaignId].totalPenalty > 0,
            "No penalty for this campaign"
        );
        uint256 _availablePenalty = campaignDetails[_campaignId].totalPenalty;
        campaignDetails[_campaignId].totalPenalty = 0;
        token.transfer(msg.sender, _availablePenalty);
    }

    function getUserStakedAmount(
        address _userAddress,
        uint256 _campaignId,
        uint256 _poolId
    ) external view returns (uint256) {
        require(
            campaignDetails[_campaignId].totalPool >= _poolId,
            "Invalid PoolId"
        );
        return userStakedAmount[_userAddress][_campaignId][_poolId];
    }

    function getTotalStakedInPool(
        uint256 _campaignId,
        uint256 _poolId
    ) external view returns (uint256) {
        require(
            campaignDetails[_campaignId].totalPool >= _poolId,
            "Invalid PoolId"
        );
        return campaignDetails[_campaignId].poolStakedAmount[_poolId];
    }

    function getCampaignStakedTime(
        uint256 _campaignId
    ) external view returns (uint256, uint256) {
        return (
            campaignDetails[_campaignId].startStaking,
            campaignDetails[_campaignId].endStaking
        );
    }

    function getWaitingForResultTime(
        uint256 _campaignId
    ) external view returns (uint256, uint256) {
        return (
            campaignDetails[_campaignId].endStaking,
            campaignDetails[_campaignId].startClaiming
        );
    }

    function getClaimingTime(
        uint256 _campaignId
    ) external view returns (uint256, uint256) {
        return (
            campaignDetails[_campaignId].startClaiming,
            campaignDetails[_campaignId].endClaiming
        );
    }

    function getPenaltyRate() external view returns (uint256) {
        return penaltyRate;
    }

    function getWiningResultOfCampaign(
        uint256 _campaignId
    ) external view returns (uint256) {
        return campaignDetails[_campaignId].result;
    }
}
