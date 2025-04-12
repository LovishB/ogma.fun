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
     * @dev Register a new token in storage
     * @param _tokenAddress Address of the token contract
     * @param _tokenOwner Address of the token owner
     * @param _name Name of the token
     * @param _symbol Symbol of the token
     * @param _uri URI for token metadata/image
     * @param _description Description of the token
     * @param _totalSupply Total supply of the token
     * @param _lockedSupply Amount of supply that is locked
     * @param _unlockDate Timestamp when locked tokens become available
     */
    function registerToken(
        address _tokenAddress,
        address _tokenOwner,
        string calldata _name,
        string calldata _symbol,
        string calldata _uri,
        string calldata _description,
        uint256 _totalSupply,
        uint256 _lockedSupply,
        uint256 _unlockDate
    ) external isFactoryAuthorized {
        // Input validation
        if (_tokenAddress == address(0) || _tokenOwner == address(0)) revert ZeroAddress();
        if (bytes(_name).length == 0 || bytes(_symbol).length == 0) revert EmptyString();
        if (_totalSupply == 0 || _lockedSupply > _totalSupply) revert InvalidSupply();
        if (_unlockDate <= block.timestamp) revert InvalidUnlockDate();
        
        // Create and store token info
        TokenInfo memory newToken = TokenInfo({
            name: _name,
            symbol: _symbol,
            uri: _uri,
            description: _description,
            owner: _tokenOwner,
            totalSupply: _totalSupply,
            lockedSupply: _lockedSupply,
            unlockDate: _unlockDate
        });
        
        s_tokens[_tokenAddress] = newToken;
        s_tokenAddresses.push(_tokenAddress);
        
        emit TokenRegistered(_tokenAddress, _tokenOwner, _name, _symbol);
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