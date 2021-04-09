const chai = require('chai');
const chaiAsPromised = require('chai-as-promised')
const { ethers } = require('hardhat');
chai.use(chaiAsPromised)
const except = chai.expect;
const assert = chai.assert;

let storyDao, dao, addresses, STToken, token, signer;

describe("StoryDao_Owner_Only", () => {
    before(async () => {
        STToken = await ethers.getContractFactory("STToken");
        token = await STToken.deploy();
        storyDao = await ethers.getContractFactory("StoryDao");
        dao = await storyDao.deploy(token.address);
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

describe("WhiteList and Blacklist", () => {
    before(async () => {
        STToken = await ethers.getContractFactory("STToken");
        token = await STToken.deploy();
        storyDao = await ethers.getContractFactory("StoryDao");
        dao = await storyDao.deploy(token.address);
        addresses = await ethers.getSigners();
        signer = await ethers.getSigner()
        await token.transfer(dao.address, 1000000000000);
    })

    it("Should have no whitelisted addresses",  async () => {
        except (
            dao.whitelist.length
        ).to.equal(0,"Whitelist must be 0 length");
    })

    it("Should whitelist if enough ether is received", async () =>{
        let owner = await addresses[0].getAddress();
        let transact = {
            to: dao.address, 
            value: ethers.utils.parseEther("0.01")
        };
        await except(
            signer.sendTransaction(transact)
        ).to.eventually.emit(dao, "Whitelisted")
        .withArgs(owner, true); 
    })

    it("Should transfer amount greater than whitelist fee to tokens", async () => {
        let second = await addresses[1].getAddress();
        let transact = {
            from: second,
            to: dao.address, 
            value: ethers.utils.parseEther("0.02")
        };
        await addresses[1]._signer.sendTransaction(transact)
        let tokenNewBalance = await token.balanceOf(second);
        /*
        1 ether = 10^18 wei
        1 token = 10,000 wei
        0.01 ether = 10^16 wei
        hence total tokens = 10^16/10^4 = 10^12
        */
        except(tokenNewBalance.toString()).to.eql('1000000000000',
            "New balance must be greater than old one!");
    })

    it("Should transfer amount back when dao token balance is low", async () =>{
        let user = await addresses[2].getAddress();
        let transact = {
            from: user,
            to: dao.address, 
            value: ethers.utils.parseEther("1")
        };
        let balance = await ethers.provider.getBalance(user);
        let tokenBalanceBefore = await token.balanceOf(user);
        await addresses[2]._signer.sendTransaction(transact);
        let balanceAfter = await ethers.provider.getBalance(user);
        let tokenBalanceAfter = await token.balanceOf(user);
        let difference = (balance.sub(balanceAfter)).toString()
        assert(
            (tokenBalanceBefore - tokenBalanceAfter) === 0,
            "Token Balance must not change!"
        )
        assert(difference === '10555488000000000',
            "Only whitelisting fee should have deducted!")
    })
})

describe("StoryDao_Events", () => {
    before(async () => {
        STToken = await ethers.getContractFactory("STToken");
        token = await STToken.deploy();
        storyDao = await ethers.getContractFactory("StoryDao");
        dao = await storyDao.deploy(token.address);
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