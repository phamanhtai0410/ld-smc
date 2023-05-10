// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract LadysBridgePool is Ownable {
    // address token
    IERC20 public token;

    event Deposit(uint256 _amount);
    event AdminWithdraw(uint256 _amount);

    constructor(address _tokenAddress, address _owner) {
        token = IERC20(_tokenAddress);
        transferOwnership(_owner);
    }
    
    /**
     *  Authorize for LadysBridge withdraw Token From BridgePool
     **/
    function authorizeBridge(address _ladysBridgeContract, uint256 _amount) external onlyOwner {
        token.approve(_ladysBridgeContract, _amount);
    }

    /**
     *      Allow owner set new token
    */
    function setToken(address _tokenAddress) external onlyOwner {
        token = IERC20(_tokenAddress);
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



