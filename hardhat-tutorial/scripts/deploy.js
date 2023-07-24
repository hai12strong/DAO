// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// You can also run a script with `npx hardhat run <script>`. If you do that, Hardhat
// will compile your contracts, add the Hardhat Runtime Environment's members to the
// global scope, and execute the script.
const hre = require("hardhat");
const {NFT_CONTRACT, ROUTER_CONTRACT} = require ("../constants");
require("dotenv").config({ path: ".env" });

async function main() {

  //a sleep function
  async function sleep(ms) { 
    return new Promise((resolve) => setTimeout(resolve,ms));
  }

  const nft_CONTRACT = NFT_CONTRACT;
  const router_CONTRACT = ROUTER_CONTRACT;
  const treasuryAmount = hre.ethers.parseEther("0.1");

  const cryptoDao = await hre.ethers.deployContract("CryptoDao", [nft_CONTRACT, router_CONTRACT], {
    value: treasuryAmount,
  });

  await cryptoDao.waitForDeployment();

  console.log("The DAO is deployed to the contract", cryptoDao.target);
  await sleep(30*1000);
  //Verify on etherscan
  await hre.run("verify:verify", {
    address: cryptoDao.target,
    constructorArguments: [nft_CONTRACT, router_CONTRACT],
  });
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
