// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
const hre = require("hardhat");

async function main() {
  // Hardhat always runs the compile task when running scripts with its command
  // line interface.
  //
  // If this script is run directly using `node` you may want to call compile
  // manually to make sure everything is compiled
  // await hre.run('compile');

  // We get the contract to deploy
  const RockPaperScissors = await hre.ethers.getContractFactory(
    "RockPaperScissors"
  );
  const rockPaperScissors = await RockPaperScissors.deploy(
    "0xc5df0b6cfb09a97697e51c816ef269f0eb180ebf4183ab2688ea7c5a9a2f9ea8",
    { value: 1000 }
  );

  await rockPaperScissors.deployed();

  console.log("Rock Paper Scissors deployed to:", rockPaperScissors.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
