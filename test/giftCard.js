const { expect } = require("chai");
const { ethers } = require("hardhat");

//require("@nomiclabs/hardhat-waffle");

describe("giftCard", function () {
     let contract;
     let owner;
     this.beforeEach(async function(){
     const giftCard=await hre.ethers.getContractFactory("giftCard");
     const giftCardDeployed=await giftCard.deploy();

     contract =await giftCardDeployed.deployed();
     [owner]=await ethers.getSigners();

    })

    it("should return 1", async function(){
        // const giftCard=await hre.ethers.getContractFactory("giftCard");
        // const giftCardDeployed=await giftCard.deploy();

        // contract =await giftCardDeployed.deployed();

        // const balanceOfToken= await contract.contractBalance('0x2170ed0880ac9a755fd29b2688956bd959f933f8');
        // expect(balanceOfToken).to.equal(1);

        // const newMoney= await contract.contractBalance("0x2170ed0880ac9a755fd29b2688956bd959f933f8");
        //  expect(newMoney).to.equal(1);
         const newMoney= await contract.createCard();
         expect(newMoney).to.equal(1);
    })
  
});