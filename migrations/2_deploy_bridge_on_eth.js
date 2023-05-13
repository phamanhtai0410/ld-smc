const console = require("console");
const fs = require("fs");

var LadysTokenETH = artifacts.require("LadysTokenETH");
var MemBridge = artifacts.require("MemBridge");
var BridgePool = artifacts.require("BridgePool");


function wf(name, address) {
    fs.appendFileSync('address.txt', name + "=" + address);
    fs.appendFileSync('address.txt', "\r\n");
}

const deployments = {
    deploy_pool: true,
    deploy_bridge: true,

    is_testnet: true,
    set_chain_ids: true,

    authorize_for_bridge: true,
    transfer_ladays_token_to_pool: true
}

module.exports = async function (deployer, network, accounts) {
    let account = deployer.options?.from || accounts[0];
    console.log("deployer = ", account);
    require('dotenv').config();
    
    

        
    var _ladysTokenETH = await LadysTokenETH.at(process.env.LadysTokenETH);
    

    /**
     *      1. Deploy BridgePool
     */
    if (deployments.deploy_pool) {
        await deployer.deploy(
            BridgePool,
            _ladysTokenETH.address,
            process.env.ownerPool
        );
        var _ladysPool = await BridgePool.deployed();
        wf("BridgePool", _ladysPool.address);
    } else {
        var _ladysPool = await BridgePool.at(process.env.BridgePool);
    }

    /**
     *      2. Deploy MemBridge
     */
    if (deployments.deploy_bridge) {

        _signers = [
            "0x8BC0073828fCFFebaCFBa058e47ec276A15fecfB",
            "0x70fb92cC9389fF80E51868067f0E2f47Cbd6C63F",
            "0x9CAdcdA4752E8929D815945B4F4aBa0B0Cec05cF",
            "0x63B9C930A19638AD4b72dfec64ab1b34b1bdd9E9",
            "0x5421FCeDccA8023393C74a1038c34D23293c6384"
          ];
        
        await deployer.deploy(
            MemBridge,
            _ladysTokenETH.address,
            _signers,
            _ladysPool.address,
            3
        );
        var _ladyBridge = await MemBridge.deployed();
        wf("MemBridge", _ladyBridge.address);
    } else {
        var _ladyBridge = await MemBridge.at(process.env.MemBridge);
    }

    /**
     *      3. Set chainID support
     */
    if (deployments.is_testnet) {
        if (deployments.set_chain_ids) {
            await _ladyBridge.setChainIdEther(5); // 5 is ChainID Goerli
            console.log("set chain id ether success ");
            await _ladyBridge.setChainIdSupport(421613, true); // set support bridge to ARB Tesnet
            console.log("set support chainid ether success");
        }
        
    }
    else  {
        if (deployments.set_chain_ids) {
            // await _ladyBridge.setChainIdEther(1); // 1 is ChainID ETH
            console.log("set chain id ether success");
            // await _ladyBridge.setChainIdSupport(42161, true); // set support bridge to ARB
            console.log("set support chainid ether success");
        }
    }

    /**
     *      4. Authorize for contract MemBridge withdraw token in contract BridgePool with amount max uint256
     */
    if (deployments.authorize_for_bridge) {
        await _ladysPool.authorizeBridge(_ladyBridge.address); // max uint256 = 115792089237316195423570985008687907853269984665640564039457584007913129639935
    }
}