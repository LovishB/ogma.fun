// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

import {OgmaToken} from "./OgmaToken.sol";
import {OgmaStorage} from "./OgmaStorage.sol";
import {OgmaTokenLock} from "./OgmaTokenLock.sol";


/**
 * @title OgmaFactory
 * @dev Factory contract for creating OgmaToken instances.
 * 1) Factory mints the entire supply to the owner
 * 2) Lock 60% of the supply for a Month
 */
contract OgmaFactory is Ownable, ReentrancyGuard {
    OgmaStorage public ogmaStorage;
    OgmaTokenLock public ogmaTokenLock;

    // Custom Errors
    error EmptyString();
    error TokenTransferFailed();
    error ApprovalFailed();

    event TokenMinted(
        address indexed tokenAddress,
        string tokenName,
        string tokenSymbol,
        string tokenURI,
        string tokenDescription
    );

    constructor(address _ogmaStorage, address _ogmaTokenLock) Ownable(msg.sender) {
        ogmaStorage = OgmaStorage(_ogmaStorage);
        ogmaTokenLock = OgmaTokenLock(_ogmaTokenLock);
    }
    
    /**
     * @dev Creates a new OgmaToken instance and mints the entire supply to the owner.
     * Locks 60% of token supply
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
    ) external nonReentrant returns (address) {
        // Validate Inputs
        if (
            bytes(_tokenName).length == 0 || 
            bytes(_tokenSymbol).length == 0 ||
            bytes(_tokenURI).length == 0 || 
            bytes(_tokenDescription).length == 0  
        ) revert EmptyString();

        address tokenOwner = msg.sender;

        // Minting New Token (factory is the initial owner)
        OgmaToken newToken = new OgmaToken(
            _tokenName,
            _tokenSymbol,
            _tokenURI,
            _tokenDescription
        );

        // Calculate token amounts
        uint256 totalSupply = newToken.MAX_SUPPLY();
        uint256 supplyToLock = (totalSupply * 60) / 100;
        uint256 remainingSupply = totalSupply - supplyToLock;
        uint256 unlockDate = block.timestamp + 30 days;

        // Approve tokens for lock contract
        bool approvalSuccess = newToken.approve(address(ogmaTokenLock), supplyToLock);
        if (!approvalSuccess) revert ApprovalFailed();

        // Lock tokens
        ogmaTokenLock.lockToken(
            address(newToken), 
            supplyToLock, 
            unlockDate, 
            tokenOwner
        );

        // Transfering Ownership of New Token
        bool success = IERC20(address(newToken)).transfer(
            tokenOwner,
            remainingSupply
        );
        if(!success) {
            revert TokenTransferFailed();
        }
        newToken.transferOwnership(tokenOwner);

        // Register token in storage
        ogmaStorage.registerToken(
            address(newToken),
            tokenOwner,
            _tokenName,
            _tokenSymbol,
            _tokenURI,
            _tokenDescription,
            totalSupply,
            supplyToLock,
            unlockDate
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