const { ethers } = require('ethers');

function split_sig() {
    var _sig = "0x4d858c88c75ab38ef15a559dc9648b7d3b9707320f27e9c3f5d8dd77e5c59f8e3099d0d0977301c78076dd05fe2bacfebcd14137807ebb40405c5206bb9ec4dc1b";
    const { v, r , s } = ethers.utils.splitSignature(_sig);
    console.log(`[${v}, "${r}", "${s}", 1688964733]`);
}

split_sig();
// [28, "0x5378fb195fc690e72cac2dd72d736caf71053fcfd46b2a4ab687b13755f96764", "0x654c80b158fc6e0c8cf475a21225c2d554e0fd65bba1eaccfc2499e1b0d1976d", 1669148853]

