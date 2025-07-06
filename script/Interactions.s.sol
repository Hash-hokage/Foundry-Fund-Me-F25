//SPDX-License-Identifier: Unlicense

//fund
//withdraw

pragma solidity ^0.8.0;

import {Script, console} from "forge-std/Script.sol";
import {DevOpsTools} from "lib/foundry-devops/src/DevOpsTools.sol";
import {FundMe} from "../src/FundMe.sol";

contract FundFundMe is Script {
    uint256 constant SEND_VALUE = 0.1 ether;
    
    function fundFundMe(address mostRecentDeployment) public {
        vm.startBroadcast();
        FundMe(payable(mostRecentDeployment)).fund{value: SEND_VALUE}();
        vm.stopBroadcast();
        console.log("Funded fundMe with %s", SEND_VALUE);
    }

    function run() external view {
        address mostRecentDeployment = DevOpsTools.get_most_recent_deployment(
            "FundMe",
            block.chainid
        );
        FundFundMe(mostRecentDeployment);
    }
}

contract WithdrawFundMe is Script {
    function withdrawFundMe(address mostRecentDeployment) public {
        vm.startBroadcast();
        FundMe(payable(mostRecentDeployment)).withdraw();
        vm.stopBroadcast();
        console.log("Withdraw FundMe balance!");
    }

    function run() external {
        address mostRecentDeployment = DevOpsTools.get_most_recent_deployment(
            "FundMe",
            block.chainid
        );
        withdrawFundMe(mostRecentDeployment);
    }
}
