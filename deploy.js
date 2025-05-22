const { ethers } = require("hardhat");

async function main() {
  console.log("🚀 Starting deployment of Todo List DApp...\n");

  // Get the ContractFactory and Signers
  const [deployer] = await ethers.getSigners();
  
  console.log("📝 Deployment Details:");
  console.log("Network:", hre.network.name);
  console.log("Deployer address:", deployer.address);
  
  // Check deployer balance
  const balance = await ethers.provider.getBalance(deployer.address);
  console.log("Deployer balance:", ethers.formatEther(balance), "ETH");
  
  if (balance === 0n) {
    throw new Error("❌ Deployer account has no funds");
  }

  console.log("\n⏳ Deploying Project contract...");

  // Deploy the Project contract
  const Project = await ethers.getContractFactory("Project");
  
  // Estimate gas for deployment
  const deploymentData = Project.interface.encodeDeploy([]);
  const estimatedGas = await ethers.provider.estimateGas({
    data: deploymentData,
  });
  
  console.log("Estimated gas for deployment:", estimatedGas.toString());
  
  // Deploy with some buffer for gas
  const project = await Project.deploy({
    gasLimit: estimatedGas * 120n / 100n, // Add 20% buffer
  });

  // Wait for deployment to be mined
  await project.waitForDeployment();

  const contractAddress = await project.getAddress();
  
  console.log("\n✅ Deployment Successful!");
  console.log("📍 Contract Address:", contractAddress);
  console.log("🔗 Transaction Hash:", project.deploymentTransaction().hash);
  
  // Verify deployment by calling a view function
  try {
    const stats = await project.getPlatformStats();
    console.log("\n🔍 Contract Verification:");
    console.log("Total Tasks:", stats[0].toString());
    console.log("Total Users:", stats[1].toString());
    console.log("✅ Contract is working correctly!");
  } catch (error) {
    console.log("⚠️  Warning: Could not verify contract functionality:", error.message);
  }

  // Save deployment info
  const deploymentInfo = {
    network: hre.network.name,
    contractAddress: contractAddress,
    deployer: deployer.address,
    transactionHash: project.deploymentTransaction().hash,
    blockNumber: project.deploymentTransaction().blockNumber,
    timestamp: new Date().toISOString(),
    gasUsed: estimatedGas.toString(),
  };

  console.log("\n📄 Deployment Summary:");
  console.log(JSON.stringify(deploymentInfo, null, 2));

  // Instructions for interaction
  console.log("\n📋 Next Steps:");
  console.log("1. Save the contract address:", contractAddress);
  console.log("2. Update your frontend with the new contract address");
  console.log("3. Verify the contract on the block explorer (optional)");
  
  if (hre.network.name === "core_testnet2") {
    console.log("4. View on Core Testnet 2 Explorer:");
    console.log(`   https://scan.test2.btcs.network/address/${contractAddress}`);
  }

  console.log("\n🎉 Todo List DApp deployment completed successfully!");
}

// Error handling
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error("\n❌ Deployment failed:");
    console.error(error);
    process.exit(1);
  });
