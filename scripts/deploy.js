// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// You can also run a script with `npx hardhat run <script>`. If you do that, Hardhat
// will compile your contracts, add the Hardhat Runtime Environment's members to the
// global scope, and execute the script.
const hre = require("hardhat");

async function main() {
  // 1. Get the contract to deploy
  const giftCard = await ethers.getContractFactory('giftCard');
  console.log('Deploying giftCard...');

  // 2. Instantiating a new giftCard smart contract
  const GIF_CARD = await giftCard.deploy();

  // 3. Waiting for the deployment to resolve
  await GIF_CARD.deployed();

  // 4. Use the contract instance to get the contract address
  console.log('giftCard deployed to:', GIF_CARD.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});










  