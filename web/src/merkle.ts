const { MerkleTree } = require('merkletreejs')
const SHA256 = require('crypto-js/sha256')
const utils = require('ethers')
const keccak256 = require('keccak256')

// 生成有资格的白名单和金额列表
const users = [
    '0x810F290a5D16Dd494783B8cA27CC7689B4d0B692',
    '0x3C2eC149fdEC49b09af68b5e3e6eD03Ff68B57a0',
    '0x7Ef59AD2156447ec27c404Dd3124735d734D0100'
]; 

const leaf = users.map((addr) => utils.solidityPackedKeccak256(["address"],[addr]))
const merkleTree = new MerkleTree(leaf, keccak256, {sortPairs:true})
const root = merkleTree.getHexRoot();
console.log("root", root);
const proof1 = merkleTree.getHexProof(leaf[0]);
console.log("proof1", proof1);
const proof2 = merkleTree.getHexProof(leaf[1]);
console.log("proof2", proof2)
