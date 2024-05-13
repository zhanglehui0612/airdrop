var MerkleTree = require('merkletreejs').MerkleTree;
var SHA256 = require('crypto-js/sha256');
var utils = require('ethers');
var keccak256 = require('keccak256');
// 生成有资格的白名单和金额列表
var users = [
    '0x810F290a5D16Dd494783B8cA27CC7689B4d0B692',
    '0x3C2eC149fdEC49b09af68b5e3e6eD03Ff68B57a0',
    '0x7Ef59AD2156447ec27c404Dd3124735d734D0100'
];
var leaf = users.map(function (addr) { return utils.solidityPackedKeccak256(["address"], [addr]); });
var merkleTree = new MerkleTree(leaf, keccak256, { sortPairs: true });
var root = merkleTree.getHexRoot();
console.log("root", root);
var proof1 = merkleTree.getHexProof(leaf[0]);
console.log("proof1", proof1);
var proof2 = merkleTree.getHexProof(leaf[1]);
console.log("proof2", proof2);
