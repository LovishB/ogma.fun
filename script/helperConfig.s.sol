// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

// Import the Forge-VM cheatcodes interface
import "forge-std/Script.sol";

contract HelperConfig is Script {

    NetworkConfig public activeNetworkConfig;

    struct NetworkConfig {
        uint256 deployerPrivateKey;
        string rpcUrl;
    }

    constructor() {
        if (block.chainid == 11155111) {
            activeNetworkConfig = getSepoliaEthConfig();
        } else {
            activeNetworkConfig = getAnvilConfig();
        }
    }

    function getSepoliaEthConfig() public view returns (NetworkConfig memory) {
        return NetworkConfig({
            deployerPrivateKey: vm.envUint("PRIVATE_KEY"),
            rpcUrl: vm.envString("SEPOLIA_RPC_URL")
        });
    }

    function getAnvilConfig() public pure returns (NetworkConfig memory) {
        return NetworkConfig({
            deployerPrivateKey: 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80,
            rpcUrl: "http://localhost:8545"
        });
    }
}