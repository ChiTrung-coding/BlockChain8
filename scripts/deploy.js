const hre = require("hardhat");

async function main() {
  const Crowdfunding = await hre.ethers.getContractFactory("Crowdfunding");
  const crowdfunding = await Crowdfunding.deploy();

  await crowdfunding.deployed();

  console.log("trien khai hop dong:", crowdfunding.address);
}


main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
