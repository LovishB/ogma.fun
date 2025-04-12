// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title OgmaStorage
 * @dev Storage contract for tracking all tokens created through OgmaFactory
 */
contract OgmaStorage is Ownable {
    address private s_ogmaFactory;
    
    struct TokenInfo {
        string name;
        string symbol;
        string uri;
        string description;
        address owner;
        uint256 totalSupply;
        uint256 lockedSupply;
        uint256 unlockDate;
    }
    
    address[] public s_tokenAddresses;
    mapping(address => TokenInfo) public s_tokens;
    
    // Events
    event TokenRegistered(address indexed tokenAddress, address indexed owner, string name, string symbol);
    
    // Custom Errors
    error NotAuthorized();
    error ZeroAddress();
    error EmptyString();
    error TokenAlreadyRegistered();
    error InvalidSupply();
    error InvalidUnlockDate();
    error InvalidCount();

    constructor() Ownable(msg.sender) {}

    modifier isFactoryAuthorized() {
        if (msg.sender != s_ogmaFactory) {
            revert NotAuthorized();
        }
        _;
    }

    /**
     * @dev Register a new token in storage using TokenInfo struct directly
     * @param _tokenInfo TokenInfo struct containing all token information
     */
    function registerToken(TokenInfo calldata _tokenInfo, address _tokenAddress) external isFactoryAuthorized {
        s_tokens[_tokenAddress] = _tokenInfo;
        s_tokenAddresses.push(_tokenAddress);
        
        emit TokenRegistered(_tokenAddress, _tokenInfo.owner, _tokenInfo.name, _tokenInfo.symbol);
    }

    /**
     * @dev Get the total number of registered tokens
     * @return Total number of tokens in storage
     */
    function getTokenCount() external view returns (uint256) {
        return s_tokenAddresses.length;
    }

    /**
     * @dev Get latest tokens with their full information
     * @param _count Number of recent tokens to return
     * @return addresses Array of token addresses
     * @return infos Array of token information
     */
    function getLatestTokens(uint256 _count) 
        external 
        view 
        returns (address[] memory addresses, TokenInfo[] memory infos) 
    {
        uint256 tokenCount = s_tokenAddresses.length;
        if (_count == 0) revert InvalidCount();
        
        if (_count > tokenCount) {
            _count = tokenCount;
        }
        
        address[] memory latestTokens = new address[](_count);
        TokenInfo[] memory tokenInfos = new TokenInfo[](_count);

        for (uint256 i = 0; i < _count; i++) {
            // Prevent underflow
            if (i < tokenCount) {
                uint256 index = tokenCount - 1 - i;
                latestTokens[i] = s_tokenAddresses[index];
                tokenInfos[i] = s_tokens[latestTokens[i]];
            }
        }
        return (latestTokens, tokenInfos);
    }

    /**
     * @dev Get information about a specific token
     * @param _tokenAddress Address of the token to query
     * @return TokenInfo struct with token details
     */
    function getTokenInfo(address _tokenAddress) external view returns (TokenInfo memory) {
        return s_tokens[_tokenAddress];
    }

    /**
     * @dev Set the OgmaFactory address
     * @param _ogmaFactory Address of the OgmaFactory contract
     */
    function setOgmaFactory(address _ogmaFactory) external onlyOwner {
       s_ogmaFactory = _ogmaFactory;
    }
}