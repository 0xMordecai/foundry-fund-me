// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Script} from "forge-std/Script.sol";
import {MockV3Aggregator} from "./mocks/MockV3Aggregator.sol";

// 1. Deploy mocks when we are on a local anvail chain
// 2. keep track of contract address across different chains
// sepolia ETH/USD have different address
// Mainnet ATH/USD have different address
contract HelperConfig is Script {
    // if we are ona local anvail, we deploy mocks
    // otherwise, grab the existing address from the live network

    NetworkConfig public activeNetworkConfig;

    uint8 public constant DECIMALS = 8;
    int256 public constant INITIAL_PRICE = 3800e8;

    struct NetworkConfig {
        address priceFeed; // ETH/USD price feed address
    }

    constructor() {
        if (block.chainid == 11155111) {
            activeNetworkConfig = getSeploiaEthConfig();
        } else if (block.chainid == 1) {
            activeNetworkConfig = getEthMainnetConfig();
        } else {
            activeNetworkConfig = getOrCreateAnvilEthConfig();
        }
    }

    function getSeploiaEthConfig() public pure returns (NetworkConfig memory) {
        // price Feed address
        NetworkConfig memory sepoliaConfig = NetworkConfig({
            priceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306
        });
        return sepoliaConfig;
    }

    function getEthMainnetConfig() public pure returns (NetworkConfig memory) {
        NetworkConfig memory EthMainnetConfig = NetworkConfig({
            priceFeed: 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419
        });
        return EthMainnetConfig;
    }

    /*
        Our `getAnvilEthConfig` function in `HelperConfig` must deploy a mock contract.
        After it deploys it we need it to return the mock address, 
        so our contracts would know where to send their calls.
    */
    function getOrCreateAnvilEthConfig() public returns (NetworkConfig memory) {
        // price Feed address
        if (activeNetworkConfig.priceFeed != address(0)) {
            return activeNetworkConfig;
        }

        // 1. Deploy the mocks (fake/dummy contract{A mock contract is a special type of contract designed to simulate the behavior of another contract during testing.})
        // 2. Return the mock address
        vm.startBroadcast();
        MockV3Aggregator mockPriceFeed = new MockV3Aggregator(
            DECIMALS,
            INITIAL_PRICE
        );
        vm.stopBroadcast();

        NetworkConfig memory anvilConfig = NetworkConfig({
            priceFeed: address(mockPriceFeed)
        });
        return anvilConfig;
    }
}
