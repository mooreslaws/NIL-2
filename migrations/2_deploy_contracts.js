var NIL2 = artifacts.require("./NIL2.sol");

module.exports = function(deployer) {
  deployer.deploy(NIL2, 
  	'_contractName',
  	'_supplierSymbol',
  	'_contractCID',
    '0xa3564D084fabf13e69eca6F2949D3328BF6468Ef',
    '0xa3564D084fabf13e69eca6F2949D3328BF6468Ef'
  );
};
