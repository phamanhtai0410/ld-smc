const console = require("console");
const fs = require("fs");

var AnimeToken = artifacts.require("AnimeToken");
var Staking = artifacts.require("Staking");




function wf(name, address) {
    fs.appendFileSync('address.txt', name + "=" + address);
    fs.appendFileSync('address.txt', "\r\n");
}

const deployments = {
    deploy_test_token: false,
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
        await token.transfer(process.env.USER_WALLET, (100 * 10 ** 18).toString()); // Transfer to user wallet for test
    } else {
        var token = await AnimeToken.at(process.env.Token);
    }
    console.log("- Done deploy test token");

    /**
     *      Deploy Staking contract
     */
    if (deployments.deploy_staking) {
        await deployer.deploy(
            Staking,
            token.address,
            process.env.OWNER,
            500
        );
        var staking = await Staking.deployed();
        wf("Staking", staking.address)
    } else {
        var staking = await Staking.at(process.env.Staking);
    }
    console.log("- Done deploy staking");

    /**
     *      Set up a campaign
     */
    if (deployments.set_up_new_campaign) {
        var _campaignId = 1;
        var _startStaking = 1686985449;
        var _endStaking = 1686999848;
        var _startClaiming = 1687003448;
        var _endClaiming = 1687025048;
        var _totalPool = 3;
        await staking.setupCampaign(
            _campaignId, 
            _startStaking,
            _endStaking,
            _startClaiming,
            _endClaiming,
            _totalPool
        );
        console.log("- Done set up new campaign");
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
        console.log("- Done set result for campaign");
    }


    /**
     *      Pause the staking (just for emergency case)
     */
    if (deployments.emergency_pause) {
        await staking.setPausable(false);
        await staking.setActiveCampaign(1);
        console.log("- Done set pausable = false and set active campaign is 1");
    }

    
}