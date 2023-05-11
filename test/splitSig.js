const { ethers } = require('ethers');

function split_sig() {
    var _sig = "0x2d77952f686d8cc058c74e670078ac9e11f99a04c91fd8245d8d235db599295125e4e5d23f2fd82c6d4ab9445e715c7f9e5fc09f1987be1303a52252fb7843911b";
    const { v, r , s } = ethers.utils.splitSignature(_sig);
    console.log(`[${v}, "${r}", "${s}", 1688964733]`);
}

split_sig();
// [28, "0x5378fb195fc690e72cac2dd72d736caf71053fcfd46b2a4ab687b13755f96764", "0x654c80b158fc6e0c8cf475a21225c2d554e0fd65bba1eaccfc2499e1b0d1976d", 1669148853]

