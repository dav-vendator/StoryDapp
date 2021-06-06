require('@nomiclabs/hardhat-waffle')
require('hardhat-docgen')

const {alchemyApiKey, mnemonicPhrase} = require("./.secret.json")
module.exports = {
  networks: {
    hardhat: {
      chainId: 1337
    },
    localhost: {
      url: "http://localhost:8545",
      chainId: 1337
    },
  	rinkeby:{
  		url: `https://eth-rinkeby.alchemyapi.io/v2/${alchemyApiKey}`,
  		accounts: {mnemonic: mnemonicPhrase} 
  	}
  },
  solidity: {
    version: "0.6.12",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200
      }
    }
  },
  paths: {
    sources: "./business_logic/contracts",
    tests: "./test",
    cache: "./business_logic/cache",
    artifacts: "./artifacts"
  },
  docgen:{
    path: "./docs",
    clear: true
  }
};
