//SPDX-License-Identifier: MIT

//Deploy mocks when on a local anvil chain
// keep track of contract addresses accorss different chains
// sepolia ETH/USD
// Miannet ETH/USD

pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {MockV3Aggregator} from "../test/mocks/mockV3Aggregator.sol";

contract HelperConfig is Script {
    // if we are on a local anvil chain, we want to deploy mocks
    // otherwise we want to use the existing price feed address
NetworkConfig public activeNetworkConfig;

uint8 public constant DECIMALS = 8;
int256 public constant INITIAL_PRICE = 2000e8;

struct NetworkConfig {
    address priceFeed; // ETH/USD price feed address
}

constructor() {
    if (block.chainid == 11155111) {
        // sepolia chain id
        activeNetworkConfig = getSepoliaEthConfig();
    } else {
        // mainnet or anvil
        if (block.chainid == 1) {
            // mainnet chain id
            activeNetworkConfig = getMainnetEthConfig();
        } else {
            // anvil chain id
            activeNetworkConfig = getOrCreateAnvilEthConfig();
        }
    }
}
    function getSepoliaEthConfig() public pure returns (NetworkConfig memory) {
        // price feed address
        NetworkConfig memory sepoliaConfig = NetworkConfig({
            priceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306 // Sepolia ETH/USD price feed address
        });
        return sepoliaConfig;
    }

    function getMainnetEthConfig() public pure returns (NetworkConfig memory) {
        // price feed address
        NetworkConfig memory ethConfig = NetworkConfig({
            priceFeed: 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419 // ETH/USD price feed address
        });
        return ethConfig;
    }

    function getOrCreateAnvilEthConfig() public returns (NetworkConfig memory) {
        if (activeNetworkConfig.priceFeed != address(0)) {
            return activeNetworkConfig;
        }
        // price feed address

        // 1. deploy mocks
        // 2. return the mock price feed address

        vm.startBroadcast();
        MockV3Aggregator mockPriceFeed = new MockV3Aggregator (DECIMALS, INITIAL_PRICE);
        vm.stopBroadcast();

       NetworkConfig memory anvilConfig = NetworkConfig({
            priceFeed: address(mockPriceFeed)
       });
        return anvilConfig;
    }
}