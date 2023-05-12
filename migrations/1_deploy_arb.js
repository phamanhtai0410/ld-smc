const console = require("console");
const fs = require("fs");

var LadysToken = artifacts.require("LadysToken");
var MemBridge = artifacts.require("MemBridge");
var BridgePool = artifacts.require("BridgePool");


const MINTER_ROLE = "0x9f2df0fed2c77648de5860a4cc508cd0818c85b8b8a1ab4ceeef8d981c8956a6";
const BURNER_ROLE = "0x3c11d16cbaffd01df69ce1c404f6340ee057498f5f00246190ea54220576a848";


function wf(name, address) {
    fs.appendFileSync('address.txt', name + "=" + address);
    fs.appendFileSync('address.txt', "\r\n");
}

const deployments = {
    
    deploy_ladys: true,
    deploy_pool: true,
    deploy_bridge: true,

    is_testnet: true,
    set_chain_ids: true,

    set_mint_for_bridge_contract: true,
    set_burn_for_bridge_contract: true,
}

module.exports = async function (deployer, network, accounts) {
    let account = deployer.options?.from || accounts[0];
    console.log("deployer = ", account);
    require('dotenv').config();
    
    

    /**
     *      1. Deploy LadysToken on ARB
     */
    if (deployments.deploy_ladys) {
        await deployer.deploy(
            LadysToken
        );
        var _ladysToken = await LadysToken.deployed();
        wf("LadysToken", _ladysToken.address);
    } else {
        var _ladysToken = await LadysToken.at(process.env.LadysToken);
    }

    /**
     *      2. Deploy BridgePool
     */
    if (deployments.deploy_pool) {
        await deployer.deploy(
            BridgePool,
            _ladysToken.address,
            process.env.ownerPool
        );
        var _bridgePool = await BridgePool.deployed();
        wf("BridgePool", _bridgePool.address);
    } else {
        var _bridgePool = await BridgePool.at(process.env.BridgePool);
    }

    /**
     *      3. Deploy MemBridge
     */
    if (deployments.deploy_bridge) {
        await deployer.deploy(
            MemBridge,
            _ladysToken.address,
            process.env.SIGNERS,
            _bridgePool.address,
            3
        );
        var _ladyBridge = await MemBridge.deployed();
        wf("MemBridge", _ladyBridge.address);
    } else {
        var _ladyBridge = await MemBridge.at(process.env.MemBridge);
    }

    /**
     *      4. Set chainID support
     */
    if (deployments.is_testnet) {
        if (deployments.set_chain_ids) {
            await _ladyBridge.setChainIdEther(5); // 5 is ChainID Goerli
            console.log("set chain id ether success ");
            await _ladyBridge.setChainIdSupport(5, true); // set support bridge to Ethereum
            console.log("set support chainid ether success");
        }
        
    }
    else  {
        if (deployments.set_chain_ids) {
            await _ladyBridge.setChainIdEther(1); // 1 is ChainID ETH
            console.log("set chain id ether success");
            await _ladyBridge.setChainIdSupport(1, true); // set support bridge to Ethereum
            console.log("set support chainid ether success");
        }
        
    }

    /**
     *      5. grantRole MINTER_ROLE for contract MemBridge
     */
    if (deployments.set_mint_for_bridge_contract) {
        await _ladysToken.grantRole(MINTER_ROLE, _ladyBridge.address);
        console.log("grant role MINTER_ROLE for contract Bridge success");
    }

    /**
     *      6. grantRole BURNER_ROLE for contract MemBridge
     */
    if (deployments.set_burn_for_bridge_contract) {
        await _ladysToken.grantRole(BURNER_ROLE, _ladyBridge.address);
        console.log("grant role BURNER_ROLE for contract Bridge success");
    }
}