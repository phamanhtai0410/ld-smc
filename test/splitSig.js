const { ethers } = require('ethers');

function split_sig() {
    var _sig = "0xa97201cf1deb5fd192ff58a23dba845b374929eab408052fe1a5564f5ae1a6594a9b8ae1535ee4487b3a4486b9fbbed1aa1c1793e028b45074b4b6f07c1f43f01c";
    const { v, r , s } = ethers.utils.splitSignature(_sig);
    console.log(`[${v}, "${r}", "${s}", 1688964733]`);
}

split_sig();
// [28, "0x5378fb195fc690e72cac2dd72d736caf71053fcfd46b2a4ab687b13755f96764", "0x654c80b158fc6e0c8cf475a21225c2d554e0fd65bba1eaccfc2499e1b0d1976d", 1669148853]

