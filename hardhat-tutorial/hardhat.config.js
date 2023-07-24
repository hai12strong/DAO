require("@nomicfoundation/hardhat-toolbox");
require("dotenv").config({ path: ".env" });

const AlCHEMY_HTTP_URL = "https://eth-goerli.g.alchemy.com/v2/8qWUzeAvo7VLQY2YuaOaAK3UfkSBNnAt";

const PRIVATE_KEY = process.env.PRIVATE_KEY;
const ETHERSCAN_KEY = process.env.ETHERSCAN_KEY;
module.exports = {
  solidity: "0.8.19",
  networks: {
    goerli: {
      url: AlCHEMY_HTTP_URL,
      accounts: [PRIVATE_KEY],
    },
  },
  etherscan: {
    apiKey: ETHERSCAN_KEY,
  }
};