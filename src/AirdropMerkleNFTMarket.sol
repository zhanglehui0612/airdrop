// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.15;

import {IERC721Receiver} from "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {MerkleProof} from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import {Token} from "./Token.sol";
import {OpenNFT} from"./OpenNFT.sol";
import {Test, console} from "forge-std/Test.sol";
import {Address} from "@openzeppelin/contracts/utils/Address.sol";

/**
 * @title Airdop merkle nft market
 * @author nicky.zhang
 * @notice
 */
contract AirdropMerkleNFTMarket is IERC721Receiver,Ownable {
    Token token;

    OpenNFT nft;

    mapping(uint256 => uint256) tokenPrices;

    mapping(uint256 => address) sellers;

    bytes32 public immutable merkleRoot;

    error WhiteListVerifyFailed();

    constructor(address _token, address _nft, bytes32 _merkleRoot) Ownable(msg.sender){
        token = Token(_token);
        nft = OpenNFT(_nft);
        merkleRoot = _merkleRoot;
    }

    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external override returns (bytes4) {
        return this.onERC721Received.selector;
    }



    /*
     * NFT list
     * @param tokenId
     * @param amount
     */
    function list(uint256 tokenId, uint256 amount) external {
        nft.safeTransferFrom(msg.sender, address(this), tokenId);
        // 将该NFT设置价格
        tokenPrices[tokenId] = amount;
        // 更新当前NFT的卖家地址
        sellers[tokenId] = msg.sender;
    }




    /*
     * Buy NFT
     * @param tokenId
     * @param amount
     */
    function buy(uint256 tokenId, uint256 amount) public {
        require(
            nft.ownerOf(tokenId) == address(this),
            "Music NFT have aleady been selled"
        );
        require(
            amount > 0 && amount >= tokenPrices[tokenId],
            "Music NFT cann not be buyed since price is lower"
        );

        // 将按照上架价格的数量的BaseERC20转给原NFT的持有者,前提是需要授权给当前合约
        token.transferFrom(msg.sender, sellers[tokenId], tokenPrices[tokenId]);
        // 将NFT的所有权转给购买者
        nft.safeTransferFrom(address(this), msg.sender, tokenId);
    }




    function multicall(bytes[] calldata datas) external returns (bool) {
        bytes[] memory results = new bytes[](datas.length);
        for (uint256 i = 0; i < datas.length; i++) {
            // 通过Openzeplin的MultiCall调用
            // Address.functionDelegateCall(address(this), datas[i]);

            // 也可以自己调用
            (bool success,)= address(this).delegatecall(datas[i]);
            require(success, "multicall failed");
        }
        return true;
    }



    /*
     * verify the sender signature and approve 
     * @param tokenId 
     * @param amount 
     * @param deadline 
     * @param v 
     * @param r 
     * @param s 
     */
    function permitPrePay(address owner,uint256 tokenId,uint256 amount,uint256 deadline,uint8 v,bytes32 r,bytes32 s) external {
        // sender permit and approve to current contract
        token.permit(owner, address(this), amount, deadline, v, r, s);
    }




    /*
     * claim NFT, whitelist will enjoy 50% discount   
     * @param tokenId 
     * @param proof 
     */
    function claimNFT(uint256 tokenId,bytes32[] calldata proof) external {
        require(
            nft.ownerOf(tokenId) == address(this),
            "Music NFT have aleady been selled"
        );

        uint256 price = tokenPrices[tokenId];
        // Verify msg.sender if is in the whitelist
        if (verifyWhiteList(proof)) {
            price = price / 2;
        }
        token.transferFrom(msg.sender, sellers[tokenId], price);

        // current contract transfer NFT to sender
        nft.safeTransferFrom(address(this), msg.sender, tokenId);
    }



    /*
     * Verify whitelist
     * @param merkleProof 
     */
     function verifyWhiteList(bytes32[] calldata merkleProof) public view returns (bool) {

        bytes32 leaf = keccak256(abi.encodePacked(msg.sender));

        // Merkle tree verify
        bool success = MerkleProof.verify(merkleProof, merkleRoot, leaf);
        if (!success) revert WhiteListVerifyFailed();

        return true;
    }
}
