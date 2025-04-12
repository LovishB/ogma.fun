// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title OgmaStorage
 * @dev Storage contract for tracking all tokens created through OgmaFactory
 */
contract OgmaStorage is Ownable {

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
    address private s_ogmaFactory;
    
    constructor() Ownable(msg.sender) {}

    modifier isFactoryAutorized() {
        if (msg.sender != s_ogmaFactory) {
            revert("Not authorized to register token");
        }
        _;
    }

    /**
     * @dev Register a new token in storage
     * @param _tokenAddress Address of the token contract
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
        string calldata _name,
        string calldata _symbol,
        string calldata _uri,
        string calldata _description,
        uint256 _totalSupply,
        uint256 _lockedSupply,
        uint256 _unlockDate
    ) external isFactoryAutorized {
        TokenInfo memory newToken = TokenInfo({
            name: _name,
            symbol: _symbol,
            uri: _uri,
            description: _description,
            owner: msg.sender,
            totalSupply: _totalSupply,
            lockedSupply: _lockedSupply,
            unlockDate: _unlockDate
        });
        s_tokens[_tokenAddress] = newToken;
        s_tokenAddresses.push(_tokenAddress);
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
        address[] memory latestTokens = new address[](_count);
        TokenInfo[] memory tokenInfos = new TokenInfo[](_count);

        for (uint256 i = 0; i < _count; i++) {
            latestTokens[i] = s_tokenAddresses[s_tokenAddresses.length - 1 - i];
            tokenInfos[i] = s_tokens[latestTokens[i]];
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