// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "@openzeppelin/contracts/access/Ownable.sol";

import "./ILadysToken.sol";


contract LadysBridge is 
    Ownable
{
    // LadysToken contract
    ILadysToken public token;
    // Pool Contract
    address public pool;
    // ChainID of chain Ethereum
    uint256 public chainIdEther = 1;
    // Check ChainID support
    mapping(uint256 => bool) public chainIDSupport;
    // Mapping variable to check the existing of one signature (make sure one sig can only be used just one time)
    mapping(bytes32 => uint8) public isUsedSignatures;

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

    constructor(
        address _tokenAddress, 
        address _signer,
        address _pool
    ) {
        token = ILadysToken(_tokenAddress);
        signer = _signer;
        pool = _pool;
        chainIDSupport[42161] = true; 
    }
    
    /**
     *      Bridge Token
     */
    function bridge(
        uint256 _amount,
        uint256 _toChainID
    ) external {
        require(chainIDSupport[_toChainID], "ChainID current is not supported");
        require(token.balanceOf(msg.sender) > _amount, "User need hold enough Token");
        if (getChainID() == chainIdEther) {
            token.transferFrom(msg.sender, pool, _amount);
        } else {
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
    ) external payable {
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
            token.transferFrom(pool, _to, _amount);
            
        } else {
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
            isUsedSignatures[_hashSignature] == 0,
            "The signature has already been used"
        );
        isUsedSignatures[_hashSignature] = 1;
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
    function setChainIdEther(uint256 _chainIdEther) external onlyOwner {
        chainIdEther = _chainIdEther;
    }

    /**
     *      Allow owner update ChainID's Support
    */
    function setChainIdSupport(uint256 _chainId, bool _flag) external onlyOwner {
        chainIDSupport[_chainId] = _flag;
    }

    /**
     *      Allow owner set new signer
    */
    function setSigner(address _signer) external onlyOwner {
        signer = _signer;
    }

    /**
     *      Allow owner set new token
    */
    function setToken(address _tokenAddress) external onlyOwner {
        token = ILadysToken(_tokenAddress);
    }

    /**
     *      Allow owner withdraw token in contract
     */
    function withdraw(uint256 _amount) external onlyOwner {
        token.transfer(msg.sender, _amount);
    }

    /**
     *      Get balance token in contract
     */
    function balance() external view returns (uint256) {
        return token.balanceOf(address(this));
    }
}