const chai = require('chai');
const chaiAsPromised = require('chai-as-promised')
const { ethers } = require('hardhat');
chai.use(chaiAsPromised)
const except = chai.expect;

let storyDao, dao, addresses;

describe("StoryDao_Owner_Only", () => {
    before(async () => {
        storyDao = await ethers.getContractFactory("StoryDao");
        dao = await storyDao.deploy();
        addresses = await ethers.getSigners();
    })

    it("Should Have Creator as Owner", async () => {
        [owner, invalid] = addresses;
        await except(
            dao.owner()
        ).eventually.equal(await owner.getAddress(),
            "Owner should be creator of contract.");
    })

    it("Should Update Owner", async () => {
        [owner, newOwner] = addresses;
        await dao.transferOwnership(newOwner.getAddress())
        except(
            dao.owner()
        ).eventually.equal(await newOwner.getAddress(),
            "Owner should change");
    })

    it("Should Revert Transaction Without Any Owner", async () => {
        [originalOwner, newOwner] = addresses;
        await dao.connect(newOwner).renounceOwnership();
        await except(
            dao.connect(newOwner).changeMaxEntries(25)
        ).to.revertedWith("Ownable: caller is not the owner");
    })
})

describe("StoryDao_Events", () => {
    before(async () => {
        storyDao = await ethers.getContractFactory("StoryDao");
        dao = await storyDao.deploy();
        addresses = await ethers.getSigners();
    })

    it("Should Emit DaofeePercentChanged", async () => {
        await except(
            dao.changeDaofeePercent(10)
        ).to.emit(dao, "DaofeePercentChanged")
        .withArgs(10);
    })

    it("Should Emit WhitelistfeeChanged", async () => {
        await except(
            dao.changeWhitelistfee(10)
        ).to.emit(dao, "WhitelistfeeChanged")
        .withArgs(10);
    })
})