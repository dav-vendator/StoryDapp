async function main() {
    //STToken
    const STToken = await ethers.getContractFactory("STToken");
    console.log("Deploying STToken...");
    const st_token = await STToken.deploy();
    await st_token.deployed();

    //StoryDao
    const StoryDao = await ethers.getContractFactory("StoryDao");
    console.log("Deploying StoryDao...");
    const st_dao = await StoryDao.deploy(st_token.address);
    await st_dao.deployed();
    //transfer tokens to dao
    await st_token.transfer(st_dao.address, st_token.totalSupply())
    //transfer ownership to dao
    await st_token.transferOwnership(st_dao.address);

    console.log("STToken deployed to:", st_token.address);
    console.log("StoryDao deployed to:", st_dao.address);
    console.log("StoryDao is made sole owner of token.");
}
  
main().then(() => process.exit(0))
        .catch(error => {
            console.error(error);
            process.exit(1);
        });