async function main() {
    const STToken = await ethers.getContractFactory("STToken");
    console.log("Deploying STToken...");
    const st_token = await STToken.deploy();
    await st_token.deployed();
    console.log("STToken deployed to:", st_token.address);
  }
  
  main().then(() => process.exit(0))
        .catch(error => {
            console.error(error);
            process.exit(1);
        });