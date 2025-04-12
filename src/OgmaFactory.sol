// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {OgmaToken} from "./OgmaToken.sol";
import {OgmaStorage} from "./OgmaStorage.sol";

/**
 * @title OgmaFactory
 * @dev Factory contract for creating OgmaToken instances.
 * 1) Factory mints the entire supply to the owner
 * 2) Lock 60% of the supply for 3 months
 */
contract OgmaFactory is Ownable {
    OgmaStorage public ogmaStorage;

    event TokenMinted(
        address indexed tokenAddress,
        string tokenName,
        string tokenSymbol,
        string tokenURI,
        string tokenDescription
    );

    constructor(address _ogmaStorage) Ownable(msg.sender) {
        ogmaStorage = OgmaStorage(_ogmaStorage);
    }
    
    /**
     * @dev Creates a new OgmaToken instance and mints the entire supply to the owner.
     * @param _tokenName Name of the token
     * @param _tokenSymbol Symbol of the token
     * @param _tokenURI URI for token metadata/image
     * @param _tokenDescription Description of the token
     * @return The address of the newly created OgmaToken instance
     */
    function createToken (
        string memory _tokenName,
        string memory _tokenSymbol,
        string memory _tokenURI,
        string memory _tokenDescription
    ) external returns (address) {
        OgmaToken newToken = new OgmaToken(
            _tokenName,
            _tokenSymbol,
            _tokenURI,
            _tokenDescription,
            msg.sender
        );

        // Lock 60% of the supply for 3 months

        ogmaStorage.registerToken(
            address(newToken),
            _tokenName,
            _tokenSymbol,
            _tokenURI,
            _tokenDescription,
            // newToken.totalSupply(),
            // newToken.lockedSupply(),
            // newToken.unlockDate()
        );

        emit TokenMinted(
            address(newToken),
            _tokenName,
            _tokenSymbol,
            _tokenURI,
            _tokenDescription
        );
        return address(newToken);
    }

}