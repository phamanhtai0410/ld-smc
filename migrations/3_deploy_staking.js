const console = require("console");
const fs = require("fs");

var AnimeToken = artifacts.require("AnimeToken");
var Staking = artifacts.require("Staking");




function wf(name, address) {
    fs.appendFileSync('address.txt', name + "=" + address);
    fs.appendFileSync('address.txt', "\r\n");
}

const deployments = {
    deploy_test_token: true,
    deploy_staking: true,
    set_up_new_campaign: true,
    set_result: false,
    emergency_pause: false
}

module.exports = async function (deployer, network, accounts) {
    let account = deployer.options?.from || accounts[0];
    console.log("deployer = ", account);
    require('dotenv').config();
    
    /**
     *      Deploy test token
     */
    if (deployments.deploy_test_token) {
        await deployer.deploy(AnimeToken);
        var token = await AnimeToken.deployed();
        wf("Token", token.address);
    } else {
        var token = await AnimeToken.at(process.env.Token);
    }

    /**
     *      Deploy Staking contract
     */
    if (deployments.deploy_staking) {
        await deployer.deploy(
            Staking,
            token.address,
            process.env.OWNER
        );
        var staking = await Staking.deployed();
        wf("Staking", staking.address)
    } else {
        var staking = await Staking.at(process.env.Staking);
    }

    /**
     *      Set up a campaign
     */
    if (deployments.set_up_new_campaign) {
        var _campaignId = 1;
        var _startStaking = 1686891600;
        var _endStaking = 1686892200;
        var _startClaiming = 1686892800;
        var _endClaiming = 1686893400;
        var _totalPool = 3;
        await staking.setupCampaign(
            _campaignId, 
            _startStaking,
            _endStaking,
            _startClaiming,
            _endClaiming,
            _totalPool
        );
    }

    
    /**
     *      Set result for campaign
     */
    if (deployments.set_result) {
        var _campaignId = 1;
        var _winningPool = 1;
        await staking.setResultForCampaign(
            _campaignId,
            _winningPool
        );
    }


    /**
     *      Pause the staking (just for emergency case)
     */
    if (deployments.emergency_pause) {
        await staking.setPausable(true);
    }

    
}