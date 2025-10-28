// SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

import {Script} from "forge-std/Script.sol";
import {DevOpsTools} from "lib/foundry-devops/src/DevOpsTools.sol"; // utility from the foundry-devops library that keeps track of the most recently deployed contracts (so you don’t have to manually copy addresses).
import {BoxV2} from "../src/BoxV2.sol";
import {BoxV1} from "../src/BoxV1.sol";
import {UUPSUpgradeable} from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

contract UpgradeBox is Script {
    function run() external returns (address) {
        address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment("ERC1967Proxy", block.chainid);
        //This deploys the new implementation contract (BoxV2) to the blockchain — but it’s not active yet.
        //The proxy still points to BoxV1.
        vm.startBroadcast();
        BoxV2 newBox = new BoxV2();
        vm.stopBroadcast();
        address proxy = upgradeBox(mostRecentlyDeployed, address(newBox)); // Performs the upgrade
        return proxy;
    }

    function upgradeBox(address proxyAddress, address newBox) public returns (address) {
        vm.startBroadcast();
        BoxV1 proxy = BoxV1(proxyAddress); // We treat the proxy address as if it’s a BoxV1 — because the proxy delegates calls to BoxV1 logic
        proxy.upgradeToAndCall(address(newBox), ""); // This literally says proxy contract now points to this new address.
        //upgradeToAndCall is available because BoxV1 inherits from UUPSUpgradeable
        vm.stopBroadcast();
        return address(proxy);
    }
}
