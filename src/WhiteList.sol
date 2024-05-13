// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.15;

import {MerkleProof} from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import {Test, console} from "forge-std/Test.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {Test, console} from "forge-std/Test.sol";
/**
 * @title  verify whitelist 
 * @author nicky.zhang
 * @notice 
 */
contract WhiteList  {

    // bytes32 public immutable merkleRoot;

    // mapping(address => bool) whitelist;

    // error WhiteListVerifyFailed();

    // constructor(bytes32 _merkleRoot) Ownable(msg.sender){
    //     merkleRoot = _merkleRoot;
    // }


    // /*
    //  * Verify whitelist
    //  * @param merkleProof 
    //  */
    // function verifyWhiteList(bytes32[] calldata merkleProof) public returns (bool) {
    //     if (whitelist[msg.sender]) {
    //         return true;
    //     }

    //     bytes32 leaf = keccak256(abi.encodePacked(msg.sender));

    //     bool success = MerkleProof.verify(merkleProof, merkleRoot, leaf);
    //     if (!success) revert WhiteListVerifyFailed();

    //     whitelist[msg.sender] = true;
    //     return true;
    // }
}