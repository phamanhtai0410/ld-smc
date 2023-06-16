const console = require("console");
const fs = require("fs");

var AnimeToken = artifacts.require("AnimeToken");
var Staking = artifacts.require("Staking");




function wf(name, address) {
    fs.appendFileSync('address.txt', name + "=" + address);
    fs.appendFileSync('address.txt', "\r\n");
}

const deployments = {
    stake: true,
    switch_pool: false,
    unstake: false,
    claim: false
}

module.exports = async function (deployer, network, accounts) {
    let account = deployer.options?.from || accounts[0];
    console.log("* Interactor = ", account);
    require('dotenv').config();
    
    var staking = await Staking.at(process.env.Staking);
    var token = await AnimeToken.at(process.env.Token);
    /**
     *      Stake
     */
    if (deployments.stake) {
        var _amount = 10 ** 18;
        var _campaignId = 1;
        var _poolId = 1;
        await token.approve(staking.address, _amount.toString());
        await staking.stake(
            _amount.toString(),
            _campaignId,
            _poolId
        );
        console.log(`* Done stake ${_amount} for campaign ${_campaignId} at pool ${_poolId}`);
    }
 
    /**
     *      Switch pool
     */
    if (deployments.switch_pool) {
        var _campaignId = 1;
        var _fromPoolId = 1;
        var _toPoolId = 1;
        await staking.stake(
            _campaignId,
            _fromPoolId,
            _toPoolId
        );
        console.log(`* Done switch for campaign ${_campaignId} at pool ${_fromPoolId} to pool ${_toPoolId}`);
    }

    /**
     *      Unstake
     */
    if (deployments.unstake) {
        var _campaignId = 1;
        var _poolId = 1;
        await staking.unstake(
            _campaignId,
            _poolId
        );
        console.log(`* Done unstake for campaign ${_campaignId} at pool ${_poolId}`);
    }

    /**
     *      Claim
     */
    if (deployments.unstake) {
        var _campaignId = 1;
        await staking.claimRewardAndStakeAmount(
            _campaignId
        );
        console.log(`* Done claim for campaign ${_campaignId}`);
    }
}