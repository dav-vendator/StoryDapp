const chai = require('chai');
const chaiAsPromised = require('chai-as-promised');
const { ethers } = require('hardhat');
chai.use(chaiAsPromised);

const except = chai.expect;
const assert = chai.assert;

let STToken, token, addresses;

describe('STToken', () => {

    before(async function (){
        STToken = await ethers.getContractFactory("STToken");
        addresses = await ethers.getSigners();
        console.log(addresses[0].address);
        token = await STToken.deploy();
    })

    it('Should Give Owner All Coin', async () => {
        let [owner] = addresses;
        let ownerBalance = await token.balanceOf(owner.getAddress());
        except(token.totalSupply()).to.eventually.equal(ownerBalance);
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
        except(token.connect(spender).transfer(userTwo.getAddress(), 10)).to.eventually.rejectedWith("Insufficient Balance") 
    })

    it('Should Emit Allowance Changed', async () => {

    })

    it('Should Emit Locked Changed', async () => {

    })
    
    it('Should Emit Unlocked Changed', async () => {

    })


})