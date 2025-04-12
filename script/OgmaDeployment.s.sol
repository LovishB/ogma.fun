// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {OgmaToken} from "../src/OgmaToken.sol";
import {OgmaStorage} from "../src/OgmaStorage.sol";
import {OgmaTokenLock} from "../src/OgmaTokenLock.sol";
import {OgmaFactory} from "../src/OgmaFactory.sol";

import {HelperConfig} from "./HelperConfig.s.sol";

contract OgmaDeployment is Script {

    function run() external {
         HelperConfig helperConfig = new HelperConfig();
        (uint256 deployerKey, ) = helperConfig.activeNetworkConfig();

        vm.startBroadcast(deployerKey);
        OgmaStorage ogmaStorage = new OgmaStorage();
        OgmaTokenLock ogmaTokenLock = new OgmaTokenLock(address(ogmaStorage));
        OgmaFactory ogmaFactory = new OgmaFactory(address(ogmaStorage), address(ogmaTokenLock));

        console.log("ogmaStorage", address(ogmaStorage));
        console.log("ogmaTokenLock", address(ogmaTokenLock));
        console.log("ogmaFactory", address(ogmaFactory));

        vm.stopBroadcast();
    }
}