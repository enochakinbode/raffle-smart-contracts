// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import { Script, stdJson, console } from "forge-std/Script.sol";
import { Raffle } from "../src/Raffle.sol";

contract EnterRaffle is Script {
    using stdJson for string;

    Raffle public raffle;
    uint256 entranceFeeInWei = 0.01 ether;

    function setUp() public {
        if (block.chainid != 11_155_111) {
            revert("This script is only for Sepolia network");
        }

        string memory root = vm.projectRoot();
        string memory path =
            string.concat(root, "/broadcast/01_DeployRaffle.s.sol/", vm.toString(block.chainid), "/run-latest.json");
        string memory json = vm.readFile(path);

        address deployedRaffle = json.readAddress(".transactions[0].contractAddress");
        raffle = Raffle(payable(deployedRaffle));
    }

    function run() public {
        uint256 deployerKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerKey);

        for (uint256 i = 0; i < 5; i++) {
            raffle.enterRaffle{ value: entranceFeeInWei }();
            uint256 epochNum = raffle.getCurrentEpoch();
            console.log("participating in epoch: N", epochNum);
        }

        vm.stopBroadcast();
    }
}
