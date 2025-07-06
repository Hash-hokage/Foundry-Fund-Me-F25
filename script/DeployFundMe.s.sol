//SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {FundMe} from "../src/FundMe.sol";
import {HelperConfig} from "./HelpConfig.s.sol";

contract DeployFundMe is Script {
    function run() external returns (FundMe) {
        HelperConfig helperConfig = new HelperConfig();
        address EthUsdFeedAddress = helperConfig.activeNetworkConfig();
        
        vm.startBroadcast();
        FundMe fundMe = new FundMe(EthUsdFeedAddress);
        vm.stopBroadcast();
        return fundMe;
    }

}