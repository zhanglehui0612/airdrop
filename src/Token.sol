// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.15;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ERC20Permit} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";

/**
 * @title  Token
 * @author nicky.zhang
 * @notice 
 */
contract Token is ERC20Permit("RNT"), Ownable {
    constructor() ERC20("RNT", "RNT") Ownable(msg.sender) {
        _mint(msg.sender, 1000 * 10 ** decimals());
    }
}
