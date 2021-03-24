const chai = require('chai');
const chaiAsPromised = require('chai-as-promised');
const { ethers } = require('hardhat');
chai.use(chaiAsPromised);

const except = chai.expect;
const assert = chai.assert;

let STToken, token, addresses;

const extractReason = (error) =>{
    let msg = error.message
    return msg.slice(msg.search("revert")+7, msg.length)
}

describe('STToken_Owner_Only', () => {

    before(async function (){
        STToken = await ethers.getContractFactory("STToken");
        addresses = await ethers.getSigners();
        token = await STToken.deploy();
    })

    it('Should Give Owner All Coin', async () => {
        let [owner] = addresses;
        let ownerBalance = await token.balanceOf(owner.getAddress());
        except(token.totalSupply()).to.eventually.equal(ownerBalance);
    })
})

describe("STToken_Transactions", () =>{
    before(async function (){
        STToken = await ethers.getContractFactory("STToken");
        addresses = await ethers.getSigners();
        token = await STToken.deploy();
    })

    it('Should Transfer', async () => {
        let [owner, receiver] = addresses;
        let initialBalance = await token.balanceOf(receiver.getAddress());
        await token.transfer(receiver.getAddress(), 10);
        let finalBalance = await token.balanceOf(receiver.getAddress());
        assert.equal(finalBalance - initialBalance, 10, "Difference must be of 10Wei");
    })

    it('Should Fail Transfer When Balance is Low', async () =>{
        let [owner, spender, userTwo] = addresses;
        let initialBalance = await token.balanceOf(spender.getAddress())
        if (initialBalance > 0) 
            await token.transferFrom(spender.getAddress(), owner.getAddress(), initialBalance);
        try{
            await token.connect(spender).transfer(userTwo.getAddress(), 10);
        }catch (error){
           except(extractReason(error)).to.equal("Insufficient Balance");
        }
    })

})

describe("STToken_Events", () => {
    before(async function (){
        STToken = await ethers.getContractFactory("STToken");
        addresses = await ethers.getSigners();
        token = await STToken.deploy();
    })

    it('Should Emit Allowance Changed', async () => {
        let [owner, spender] = addresses;
        await except(
            await token.increaseApproval(spender.getAddress(), 10)
         ).to.emit(token, "Approval")
          .withArgs(await owner.getAddress(), await spender.getAddress(), 10);
    })

    it('Should Emit Locked Changed', async () => {
        let [_,user] = addresses;
        await token.transfer(user.getAddress(), 15);
        await except(
            await token.increaseLockedAmount(user.getAddress(), 10)
        ).to.emit(token, "Locked")
        .withArgs(await user.getAddress(), 10);
    })

    it('Should Emit Unlocked Changed', async () => {
        let [_,user] = addresses;
        await except(
            await token.decreaseLockedAmount(user.getAddress(), 5)
        ).to.emit(token, "Locked")
        .withArgs(await user.getAddress(), 5);
    })
})