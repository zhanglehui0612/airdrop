// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.15;


import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

/**
 * @title  NFT
 * @author nicky.zhang
 * @notice 
 */
contract OpenNFT is ERC721URIStorage {
        uint256 counter;
        constructor() ERC721("OpenNFT", "ONFT") {}

        function mint(address sender, string memory tokenURI) public returns (uint256) {
            counter++;
            uint256 newItemId = counter;
            _mint(sender, newItemId);
            _setTokenURI(newItemId, tokenURI);
            return newItemId;
        }
    }
