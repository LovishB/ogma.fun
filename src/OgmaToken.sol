// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

/**
An ERC20 token implementation for Ogma Launchpad.
Tokens are minted with max supply (1 million tokens, 18 decimals) at deployment.
*/
contract OgmaToken is ERC20, Ownable {
    string public s_tokenURI;
    string public s_tokenDescription;
    uint256 public constant MAX_SUPPLY = 1000000 * 10 ** 18;

    // Custom errors
    error EmptyString();

    /**
    * @dev Constructor that mints the entire supply to the owner
    * @param _tokenName Name of the token
    * @param _tokenSymbol Symbol of the token
    * @param _tokenURI URI for token metadata/image
    * @param _tokenDescription Description of the token
    */
    constructor(
        string memory _tokenName,
        string memory _tokenSymbol,
        string memory _tokenURI,
        string memory _tokenDescription
    ) ERC20(_tokenName, _tokenSymbol) Ownable(msg.sender){
        // Input validation
        if (bytes(_tokenName).length == 0 || 
            bytes(_tokenSymbol).length == 0 || 
            bytes(_tokenURI).length == 0) {
            revert EmptyString();
        }
        
        // Minting entire supply
        _mint(msg.sender, MAX_SUPPLY);
        s_tokenURI = _tokenURI;
        s_tokenDescription = _tokenDescription;
    }

}