// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.18;

// 1.deploy mocks when we oare on local anvil chain
// 2. keep track of ctrct addys accross fdiff chains
// Sepolia eth/usd
// mainnet eth/usd
import {Script} from "forge-std/Script.sol";
import {MockV3Aggregator} from "../test/mocks/MockV3Aggregator.sol";

contract HelperConfig is Script{
    //if we are on a local anivle we deploy mocks
    // otherwise grab the existing addy from the live net
    NetworkConfig public activeNetworkConfig;
    uint8 public constant DECIMALS = 8;
    int256 public constant INITIAL_PRICE = 2000e8;

    struct NetworkConfig{
        address priceFeed; //Eth/ussd price feed addy
     }

    constructor(){
        if (block.chainid == 11155111){
            activeNetworkConfig = getSepoliaEthConfig();
        } else {
            activeNetworkConfig = getOrCreateAnvilEthConfig();
        }
    }
    function getSepoliaEthConfig() public pure returns(NetworkConfig memory){
        NetworkConfig memory sepoliaConfig = NetworkConfig({
            priceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306
        });
        return sepoliaConfig;
    }

    function getOrCreateAnvilEthConfig() public  returns(NetworkConfig memory){
        if (activeNetworkConfig.priceFeed != address(0)){
            return activeNetworkConfig;
        }
        vm.startBroadcast();
        MockV3Aggregator mockPriceFeed = new MockV3Aggregator(DECIMALS, INITIAL_PRICE);
        vm.stopBroadcast();

        NetworkConfig memory anvilConfig = NetworkConfig({
            priceFeed: address(mockPriceFeed)
        });
        return anvilConfig;
    }
}