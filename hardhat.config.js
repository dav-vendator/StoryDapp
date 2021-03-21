require('@nomiclabs/hardhat-ethers')
const {alchemyApiKey, mnemonicPhrase} = require("./.secret.json")
module.exports = {
  networks: {
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
    tests: "./business_logic/test",
    cache: "./business_logic/cache",
    artifacts: "./business_logic/artifacts"
  }
};
