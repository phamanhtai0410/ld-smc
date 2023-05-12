// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "@openzeppelin/contracts/access/AccessControl.sol";

import "./IToken.sol";


contract MemBridge is 
    AccessControl
{
    // Token contract
    IToken public token;
    // Pool Contract
    address public pool;
    // ChainID of chain Ethereum
    uint256 public chainIdEther = 1;
    // Bridge & Claim is disable on chain Ethereum
    bool public pauseETH;
    // Bridge & Claim is disable on chain token Wrap
    bool public pauseWrap;
    // Check ChainID support
    mapping(uint256 => bool) public chainIDSupport;
    // Mapping variable to check the existing of one signature (make sure one sig can only be used just one time)
    mapping(string => uint8) public isUsedSignatures;

    // Signer for claim with signature 
    address private signer;

    // Proof Signature
    struct Proof {
        uint8 v;
        bytes32 r;
        bytes32 s;
        uint256 deadline;
    }

    // Events
    event Bridge(uint256 amount, uint256 toChainID, address wallet);
    event Claim(uint256 amount, address walletReceive, string callbackData);

    bytes32 public constant PAUSE_ROLE = keccak256("PAUSE_ROLE");

    constructor(
        address _tokenAddress, 
        address _signer,
        address _pool
    ) {
        token = IToken(_tokenAddress);
        signer = _signer;
        pool = _pool;
        chainIDSupport[42161] = true; 

        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _setupRole(PAUSE_ROLE, msg.sender);
    }
    
    /**
     *      Modifier check msg.sender must is wallet address
     */
    modifier notContract() {
        require(!_isContract(msg.sender), "Contract not allowed");
        require(msg.sender == tx.origin, "Proxy contract not allowed");
        _;
    }

    /**
     *      Bridge Token
     */
    function bridge(
        uint256 _amount,
        uint256 _toChainID
    ) external notContract {
        require(chainIDSupport[_toChainID], "ChainID current is not supported");
        require(token.balanceOf(msg.sender) >= _amount, "User need hold enough Token");
        if (getChainID() == chainIdEther) {
            require(!pauseETH, "Claim is disable");
            token.transferFrom(msg.sender, pool, _amount);
        } else {
            require(!pauseWrap, "Claim is disable");
            token.burn(msg.sender, _amount);
        }
        emit Bridge(_amount, _toChainID, msg.sender);
    }

    /**
     *      Claim token then bridge
     */
    function claim(
        string memory _txHash,
        uint256 _amount,
        Proof memory _proof
    ) external notContract {
        address _to = msg.sender;
        require(
            verifySignature(
                signer,
                _txHash,
                _amount,
                _proof
            ),
            "Invalid Signature"
        );
        if (getChainID() == chainIdEther) {
            require(!pauseETH, "Claim is disable");
            token.transferFrom(pool, _to, _amount);
            
        } else {
            require(!pauseWrap, "Claim is disable");
            token.mint(_to, _amount);
        }
        emit Claim(_amount, _to, _txHash);
    }

    /**
     *      Verify Signature
     */
    function verifySignature(
        address _signer,
        string memory _txHash,
        uint256 _amount,
        Proof memory _proof
    ) private returns (bool) {
        bytes32 _hashSignature = keccak256(
            abi.encode(
                getChainID(),
                tx.origin,
                address(this),
                _txHash,
                _amount,
                _proof.deadline
            )
        );
        require(
            isUsedSignatures[_txHash] == 0,
            "The signature has already been used"
        );
        isUsedSignatures[_txHash] = 1;
        address signatory = ecrecover(_hashSignature, _proof.v, _proof.r, _proof.s);
        return signatory == _signer && _proof.deadline >= block.timestamp;
    }

    /**
     *      Get ChainID current
     */
    function getChainID() private view returns (uint256) {
        uint256 id;
        assembly {
            id := chainid()
        }
        return id;
    }

    /**
     *      Allow owner set new chainID Ether
    */

    function setPauseETH(bool _flag) external onlyRole(PAUSE_ROLE) {
        pauseETH = _flag;
    }

    function setPauseWrap(bool _flag) external onlyRole(PAUSE_ROLE) {
        pauseWrap = _flag;
    }

    function setChainIdEther(uint256 _chainIdEther) external onlyRole(DEFAULT_ADMIN_ROLE) {
        chainIdEther = _chainIdEther;
    }

    /**
     *      Allow owner update ChainID's Support
    */
    function setChainIdSupport(uint256 _chainId, bool _flag) external onlyRole(DEFAULT_ADMIN_ROLE) {
        chainIDSupport[_chainId] = _flag;
    }

    /**
     *      Allow owner set new signer
    */
    function setSigner(address _signer) external onlyRole(DEFAULT_ADMIN_ROLE) {
        signer = _signer;
    }

    /**
     *      Allow owner set new token
    */
    function setToken(address _tokenAddress) external onlyRole(DEFAULT_ADMIN_ROLE) {
        token = IToken(_tokenAddress);
    }

    /**
     *      Get balance token in contract
     */
    function balance() external view returns (uint256) {
        return token.balanceOf(address(this));
    }

    /**
     * @notice Checks if address is a contract
     */
    function _isContract(address addr) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(addr)
        }
        return size > 0;
    }
}