/**
 * Use this file to configure your truffle project. It's seeded with some
 * common settings for different networks and features like migrations,
 * compilation and testing. Uncomment the ones you need or modify
 * them to suit your project as necessary.
 *
 * More information about configuration can be found at:
 * 
 * https://trufflesuite.com/docs/truffle/reference/configuration
 *
 * To deploy via Infura you'll need a wallet provider (like @truffle/hdwallet-provider)
 * to sign your transactions before they're sent to a remote public node. Infura accounts
 * are available for free at: infura.io/register.
 *
 * You'll also need a mnemonic - the twelve word phrase the wallet uses to generate
 * public/private key pairs. If you're publishing your code to GitHub make sure you load this
 * phrase from a file you've .gitignored so it doesn't accidentally become public.
 *
 */

const HDWalletProvider = require('@truffle/hdwallet-provider');
const PrivateKeyProvider = require("truffle-privatekey-provider");

const fs = require('fs');
// const mnemonic = fs.readFileSync(".secret").toString().trim();
const privateKey = fs.readFileSync(".private_key").toString().trim();
console.log("Private Key = ", privateKey);

const privateKeyUser1 = fs.readFileSync(".private_key_user_1").toString().trim();
const privateKeyUser2 = fs.readFileSync(".private_key_user_2").toString().trim();
const privateKeyUser3 = fs.readFileSync(".private_key_user_3").toString().trim();




module.exports = {
  /**
   * Networks define how you connect to your ethereum client and let you set the
   * defaults web3 uses to send transactions. If you don't specify one truffle
   * will spin up a development blockchain for you on port 9545 when you
   * run `develop` or `test`. You can ask a truffle command to use a specific
   * network from the command line, e.g
   *
   * $ truffle test --network <network-name>
   */

  networks: {
    ganache: {
      host: '127.0.0.1', // Localhost (default: none)
      port: 8545, // Standard Ethereum port (default: none)
      network_id: '*', // Any network (default: none)
      skipDryRun: true,
      production: true,
      gasPrice: 7656250000,
      timeoutBlocks: 200,
      from: '0x016164edb8247dA3A4543F8f8A697DF8aF795b55',
    },
    ganache2: {
      host: '127.0.0.1', // Localhost (default: none)
      port: 8545, // Standard Ethereum port (default: none)
      network_id: '*', // Any network (default: none)
      skipDryRun: true,
      production: true,
      gasPrice: 7656250000,
      timeoutBlocks: 200,
      from: '0x5C82Ce5F770d0eCCa83DfEC20e6da9a5324f9f5D',
    },
    goerli_testnet: {
      provider: () => new HDWalletProvider(
        privateKey,
        // `https://goerli.infura.io/v3/9aa3d95b3bc440fa88ea12eaa4456161`
        `https://goerli.infura.io/v3/87cd043b3ab54e61b62c73382f9b21a1`
      ),
      network_id: 5,
      gasPrice: 47000000000,
      // skipDryRun: true,
      // production: true,
      // gasPrice: 128,
      // timeoutBlocks: 200,
      confirmations: 2,
    },
    goerli_testnet_user_1: {
      provider: () => new HDWalletProvider(
        privateKeyUser1,
        // `https://goerli.infura.io/v3/9aa3d95b3bc440fa88ea12eaa4456161`
        `https://goerli.infura.io/v3/87cd043b3ab54e61b62c73382f9b21a1`
      ),
      network_id: 5,
      gasPrice: 47000000000,
      // skipDryRun: true,
      // production: true,
      // gasPrice: 128,
      // timeoutBlocks: 200,
      // confirmations: 2,
    },
    goerli_testnet_user_2: {
      provider: () => new HDWalletProvider(
        privateKeyUser2,
        // `https://goerli.infura.io/v3/9aa3d95b3bc440fa88ea12eaa4456161`
        `https://goerli.infura.io/v3/87cd043b3ab54e61b62c73382f9b21a1`
      ),
      network_id: 5,
      gasPrice: 47000000000,
      // skipDryRun: true,
      // production: true,
      // gasPrice: 128,
      // timeoutBlocks: 200,
      // confirmations: 2,
    },
    goerli_testnet_user_3: {
      provider: () => new HDWalletProvider(
        privateKeyUser3,
        // `https://goerli.infura.io/v3/9aa3d95b3bc440fa88ea12eaa4456161`
        `https://goerli.infura.io/v3/87cd043b3ab54e61b62c73382f9b21a1`
      ),
      network_id: 5,
      gasPrice: 47000000000,
      // skipDryRun: true,
      // production: true,
      // gasPrice: 128,
      // timeoutBlocks: 200,
      // confirmations: 2,
    },
    arb_testnet: {
      provider: () => new HDWalletProvider(privateKey, `https://goerli-rollup.arbitrum.io/rpc`),
      network_id: 421613,
      // skipDryRun: true,
      // production: true,
      // gasPrice: 128,
      // timeoutBlocks: 200,
      confirmations: 2,
    },
    bsc_testnet: {
      provider: () => new HDWalletProvider(privateKey, `https://data-seed-prebsc-1-s1.binance.org:8545/`),
      network_id: 97,
      skipDryRun: true,
      production: true,
      gasPrice: 128,
      timeoutBlocks: 200,
      confirmations: 2,
    },
  },

  // Set default mocha options here, use special reporters etc.
  mocha: {
    // timeout: 100000
  },

  plugins: ["truffle-contract-size", "truffle-plugin-verify"],
  api_keys: {
    etherscan: 'F36ABHNTET3AQ8QJXAW9J5K3CXXRINVER2'
  },

  // Configure your compilers
  compilers: {
    solc: {
      version: "0.8.10",      // Fetch exact version from solc-bin (default: truffle's version)
      // docker: true,        // Use "0.5.1" you've installed locally with docker (default: false)
      settings: {          // See the solidity docs for advice about optimization and evmVersion
       optimizer: {
         enabled: true,
         runs: 200
       }
      }
    }
  },

  // Truffle DB is currently disabled by default; to enable it, change enabled:
  // false to enabled: true. The default storage location can also be
  // overridden by specifying the adapter settings, as shown in the commented code below.
  //
  // NOTE: It is not possible to migrate your contracts to truffle DB and you should
  // make a backup of your artifacts to a safe location before enabling this feature.
  //
  // After you backed up your artifacts you can utilize db by running migrate as follows:
  // $ truffle migrate --reset --compile-all
  //
  // db: {
    // enabled: false,
    // host: "127.0.0.1",
    // adapter: {
    //   name: "sqlite",
    //   settings: {
    //     directory: ".db"
    //   }
    // }
  // }
};
