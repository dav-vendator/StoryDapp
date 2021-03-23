async function main() {
    //STToken
    const STToken = await ethers.getContractFactory("STToken");
    console.log("Deploying STToken...");
    const st_token = await STToken.deploy();
    await st_token.deployed();

    //StoryDao
    const StoryDao = await ethers.getContractFactory("StoryDao");
    console.log("Deploying StoryDao...");
    const st_dao = await StoryDao.deploy();
    await st_dao.deployed();

    console.log("STToken deployed to:", st_token.address);
    console.log("StoryDao deployed to:", st_dao.address);
  }
  
  main().then(() => process.exit(0))
        .catch(error => {
            console.error(error);
            process.exit(1);
        });