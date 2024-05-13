// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.15;

import {Test, console} from "forge-std/Test.sol";
import {OpenNFT} from "../src/OpenNFT.sol";
import {Token} from "../src/Token.sol";
import {SignatureUtils} from "./SignatureUtils.sol";
import {AirdropMerkleNFTMarket} from "../src/AirdropMerkleNFTMarket.sol";


contract AirdropMerkleNFTMarketTest is Test {

    Token token;
    OpenNFT nft;
    AirdropMerkleNFTMarket market;
    SignatureUtils signatureUtils;
    address owner;

    // whitelist address
    address buyer1;
    uint256 buyer1PrivateKey = 0x2B456;
    bytes32[] proof1;

    // non-whitelist address
    address buyer2;
    uint256 buyer2PrivateKey = 0x1F2;
    bytes32[] proof2;

    address buyer3;
    uint256 buyer3PrivateKey = 0x1A024E;

    bytes32 merkleRoot;

    function setUp() public {
        merkleRoot = 0xf87436585dda92e60f068d49666b31e910bea9b9e9385921bd0d07160618ed6e;

        owner = makeAddr("owner");

        buyer1 = 0x810F290a5D16Dd494783B8cA27CC7689B4d0B692;
        buyer2 = 0x3C2eC149fdEC49b09af68b5e3e6eD03Ff68B57a0;
        buyer3 = 0x7Ef59AD2156447ec27c404Dd3124735d734D0100;

        vm.startPrank(owner);
        token = new Token();
        token.transfer(buyer1, 1000);
        token.transfer(buyer2, 1000);
        nft = new OpenNFT();
        nft.mint(
            owner,
            "ipfs://QmSaZjmSBZM557jsB6MtE6MMxwZTR7PBCLkJABEUTbRzLH/1.json"
        );
        nft.mint(
            owner,
            "ipfs://QmSaZjmSBZM557jsB6MtE6MMxwZTR7PBCLkJABEUTbRzLH/2.json"
        );
        nft.mint(
            owner,
            "ipfs://QmSaZjmSBZM557jsB6MtE6MMxwZTR7PBCLkJABEUTbRzLH/3.json"
        );

        
        market = new AirdropMerkleNFTMarket(address(token), address(nft), merkleRoot);
        nft.approve(address(market),1);
        market.list(1, 100);
        vm.stopPrank();

        signatureUtils = new SignatureUtils(token.DOMAIN_SEPARATOR());


        proof1 = [
            bytes32(0xf9aa233456a85a21ada85accfef7bbb64dffdbe4be1274ca24fa29e16d9afae3),
            bytes32(0xe17f99af99f218e88adc6bc0fab014988a7513564bc41cf96651d2c0d4f2050e)
        ];

       proof2 = [
            bytes32(0x40f9631106fa572bc65e419106bf1344f48c0abb5436c74bbdcde86605ad6bc9),
            bytes32(0xe17f99af99f218e87adc6bc0fab014988a7513564cc41cf96651d2c0d4f2050e)]
        ;
    }

    function testMultiCall() public {
        vm.startPrank(buyer1);
        // generate the signature
        (uint8 v, bytes32 r, bytes32 s) = sign(buyer1, buyer1PrivateKey, address(market), 100, 1 days);

        // Modified the paramter value, expect failed
        bytes[] memory calls = new bytes[](2);
        calls[0] = abi.encodeWithSelector(AirdropMerkleNFTMarket.permitPrePay.selector,buyer1,address(market),200,1 days,v,r,s);
        // abi encode claimNFT
        calls[1] = abi.encodeWithSelector(AirdropMerkleNFTMarket.claimNFT.selector, 1, proof1);
        
        vm.expectRevert("multicall failed");
        market.multicall(calls);



        // expecct multicall success call
        bytes[] memory calls1 = new bytes[](2);
        calls1[0] = abi.encodeWithSelector(AirdropMerkleNFTMarket.permitPrePay.selector,buyer1,address(market),100,1 days,v,r,s);
        // abi encode claimNFT
        calls1[1] = abi.encodeWithSelector(AirdropMerkleNFTMarket.claimNFT.selector, 1, proof1);
        

        market.multicall(calls1);
        assertTrue(token.balanceOf(buyer1) == 950);
        assertTrue(nft.ownerOf(1) == buyer1);


        // Modified the proof value, the multical expect failed
        bytes[] memory calls2 = new bytes[](2);
        calls2[0] = abi.encodeWithSelector(AirdropMerkleNFTMarket.permitPrePay.selector,buyer1,address(market),100,1 days,v,r,s);
        // abi encode claimNFT
        calls2[1] = abi.encodeWithSelector(AirdropMerkleNFTMarket.claimNFT.selector, 1, proof2);

        vm.expectRevert("multicall failed");
        market.multicall(calls2);
        vm.stopPrank();
    }

    function sign(
        address owner, 
        uint256 ownerPrivateKey,
        address spender, 
        uint256 value, 
        uint256 deadline
    ) internal view returns (uint8 v, bytes32 r, bytes32 s) {
        // Create Permit struct
        SignatureUtils.Permit memory permit = SignatureUtils.Permit({
            owner: owner,
            spender: spender,
            value: value,
            nonce: token.nonces(owner),
            deadline: deadline
        });

        // Computes the hash of the fully encoded EIP-712 message for the domain
        bytes32 digest = signatureUtils.getTypedDataHash(permit);
        return vm.sign(ownerPrivateKey, digest);
    }
}