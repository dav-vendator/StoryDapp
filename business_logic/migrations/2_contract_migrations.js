const STToken = artifacts.require("STToken");

module.exports = function (deployer) {
    deployer.deploy(STToken);
};
