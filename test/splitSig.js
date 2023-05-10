const { ethers } = require('ethers');

function split_sig() {
    var _sig = "0xfdd65477195c28e03727e3ff8b9865761030e95bca6d69a61f5a14c48577266f5565ad3ae7192fef981fa3827be7830ca9ce283a54e56bb7ecdba407b9e6af3e1b";
    const { v, r , s } = ethers.utils.splitSignature(_sig);
    console.log(`[${v}, "${r}", "${s}"]`);
    // console.log(`[${v}, "${r}", "${s}", 1688964733]`);
}

split_sig();
// [28, "0x5378fb195fc690e72cac2dd72d736caf71053fcfd46b2a4ab687b13755f96764", "0x654c80b158fc6e0c8cf475a21225c2d554e0fd65bba1eaccfc2499e1b0d1976d", 1669148853]

