// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

import {OgmaStorage} from "./OgmaStorage.sol";
import {OgmaToken} from "./OgmaToken.sol";

/**
 * @title OgmaTokenLock
 * @dev Contract for locking tokens for a specified period
 */
contract OgmaTokenLock is Ownable, ReentrancyGuard {
    OgmaStorage public ogmaStorage;
    address private s_ogmaFactory;

    struct LockInfo {
        uint256 amountLocked;
        uint256 unlockDate;
        address ownerAddress;
    }
    mapping(address=>bool) public s_isLocked;
    mapping(address=>LockInfo) public s_locks;

    // Events
    event TokenLocked(
        address indexed tokenAddress, 
        uint256 amount, 
        uint256 unlockDate, 
        address indexed owner
    );
    event TokenReleased(
        address indexed tokenAddress, 
        uint256 amount, 
        address indexed owner
    );

    // Custom Errors
    error NotAuthorized();
    error TokenLockFailed();
    error TokenNotLocked();
    error NotTokenOwner();
    error TokenStillLocked();
    error TokenReleaseFailure();
    error ZeroAddress();
    error InvalidUnlockDate();

    constructor(address _ogmaStorage) Ownable(msg.sender) {
        ogmaStorage = OgmaStorage(_ogmaStorage);
    }

    modifier isFactoryAuthorised() {
        if(msg.sender != s_ogmaFactory) {
            revert NotAuthorized();
        }
        _;
    }

    /**
     * @dev Locks tokens by transferring them from factory to this contract
     * @param _tokenAddress Address of token to lock
     * @param _amount Amount of tokens to lock
     * @param _unlockDate Timestamp when tokens can be released
     * @param _tokenOwner Address of token owner who can release tokens
     * @return success Boolean indicating success
    */
    function lockToken(
        address _tokenAddress,
        uint256 _amount,
        uint256 _unlockDate,
        address _tokenOwner
    ) external isFactoryAuthorised() nonReentrant returns (bool) {
        // Input validations
        if(_tokenAddress == address(0) || _tokenOwner == address(0)) { revert ZeroAddress(); }
        if(_unlockDate <= block.timestamp) { revert InvalidUnlockDate(); }

        // State Update
        LockInfo memory newLock = LockInfo({
            amountLocked: _amount,
            unlockDate: _unlockDate,
            ownerAddress: _tokenOwner
        });
        s_locks[_tokenAddress] = newLock;
        s_isLocked[_tokenAddress] = true;

        // transfer call
        bool success = IERC20(_tokenAddress).transferFrom(
            msg.sender,
            address(this),
            _amount
        );
        if(!success) {
            revert TokenLockFailed();
        }

        emit TokenLocked(
            _tokenAddress,
            _amount,
            _unlockDate,
            _tokenOwner
        );

        return true;
    }

    /**
     * @dev Releases locked tokens to the owner after unlock date
     * @param _tokenAddress Address of token to release
     * @return success Boolean indicating success
     */
    function release(address _tokenAddress) nonReentrant external returns(bool) {
        // state checks
        if(!s_isLocked[_tokenAddress]) {
            revert TokenNotLocked();
        }

        LockInfo memory tokenLock = s_locks[_tokenAddress];
        address tokenOwner = tokenLock.ownerAddress;
        uint256 amount = tokenLock.amountLocked;

        if(msg.sender != tokenOwner) {
            revert NotTokenOwner();
        }

        if(block.timestamp < tokenLock.unlockDate) {
            revert TokenStillLocked();
        }

        s_isLocked[_tokenAddress] = false;

        // transer call
        bool success = IERC20(_tokenAddress).transfer(
            msg.sender,
            amount
        );

        if(!success) {
            revert TokenReleaseFailure();
        }

        emit TokenReleased(
            _tokenAddress,
            amount,
            tokenOwner
        );

        return true;
    }

    /**
     * @dev Set the OgmaFactory address
     * @param _ogmaFactory Address of the OgmaFactory contract
     */
    function setOgmaFactory(address _ogmaFactory) external onlyOwner {
       s_ogmaFactory = _ogmaFactory;
    }
}