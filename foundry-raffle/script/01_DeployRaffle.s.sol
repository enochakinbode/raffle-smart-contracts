// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import { Script, console } from "forge-std/Script.sol";
import { Raffle } from "../src/Raffle.sol";

contract DeployRaffle is Script {
    Raffle public raffle;
    uint256 entranceFeeInWei = 0.01 ether;
    address sepoliaWrapperAddress = 0x195f15F2d49d693cE265b4fB0fdDbE15b1850Cc1;

    function setUp() public view {
        if (block.chainid != 11_155_111) {
            revert("This script is only for Sepolia network");
        }
    }

    function run() public {
        uint256 deployerKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerKey);

        raffle = new Raffle(entranceFeeInWei, sepoliaWrapperAddress);
        console.log("Raffle deployed at:", address(raffle));

        vm.stopBroadcast();
    }
}
