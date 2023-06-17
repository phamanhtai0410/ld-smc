// File: @openzeppelin/contracts/token/ERC20/IERC20.sol

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
}

// File: @openzeppelin/contracts/utils/Context.sol


// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

// File: @openzeppelin/contracts/access/Ownable.sol


// OpenZeppelin Contracts (last updated v4.9.0) (access/Ownable.sol)

pragma solidity ^0.8.0;

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby disabling any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// File: contracts/Staking.sol


pragma solidity ^0.8.2;


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
            campaignDetails[_campaignId].totalPenalty += _userStaked / 2;
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
