const console = require("console");
const fs = require("fs");

var LadyToken = artifacts.require("LadyToken");
var LadysBridge = artifacts.require("LadysBridge");
var LadysBridgePool = artifacts.require("LadysBridgePool");


function wf(name, address) {
    fs.appendFileSync('address.txt', name + "=" + address);
    fs.appendFileSync('address.txt', "\r\n");
}

const deployments = {
    is_testnet,
    deploy_ladys: true,
    deploy_pool: true,
    deploy_bridge: true,
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
            LadyToken
        );
        var _ladysToken = await LadyToken.deployed();
        wf("LadysToken", _ladysToken.address);
    } else {
        var _ladysToken = await LadyToken.at(process.env.LadysToken);
    }

    /**
     *      2. Deploy LadysBridgePool
     */
    if (deployments.deploy_pool) {
        await deployer.deploy(
            LadysBridgePool,
            _ladysToken.address,
            process.env.ownerPool
        );
        var _ladyPool = await LadysBridgePool.deployed();
        wf("LadysBridgePool", _ladyPool.address);
    } else {
        var _ladyPool = await LadysBridgePool.at(process.env.LadysBridgePool);
    }

    /**
     *      3. Deploy LadysBridge
     */
    if (deployments.deploy_bridge) {
        await deployer.deploy(
            LadysBridge,
            _ladysToken.address,
            process.env.SIGNER,
            _ladyPool.address
        );
        var _ladyBridge = await LadysBridge.deployed();
        wf("LadysBridge", _ladyBridge.address);
    } else {
        var _ladyBridge = await LadysBridge.at(process.env.LadysBridge);
    }

    if (deployments.is_testnet) {
        await _ladyBridge.setChainIdEther();
        await _ladyBridge.setChainIdSupport()
    }
}