require("@nomicfoundation/hardhat-toolbox");

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.9",
  networks:{
    mumbai:{
      url:"https://polygon-mumbai.g.alchemy.com/v2/dWQt-JIGP8b87ZRvIbe6NFrk6N7rjX2z",
      accounts:["5cb37d41a2a3a191460d9a501130619446606c2bd0c715933b8af3cc769e1aa6"],
    },
  },
};
