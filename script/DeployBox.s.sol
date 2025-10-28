//SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

import {Script} from "forge-std/Script.sol";
import {BoxV1} from "../src/BoxV1.sol"; // Implementation contract
import {ERC1967Proxy} from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol"; // This is OpenZeppelin’s base proxy contract following EIP-1967 storage slots for upgradeable contracts.
import {UUPSUpgradeable} from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

contract DeployBox is Script {
    function run() external returns (address) {
        address proxy = deployBox();
        return proxy;
    }

    function deployBox() public returns (address) {
        vm.startBroadcast();
        BoxV1 box = new BoxV1(); // Implementation contract (Logic)
        bytes memory initializerData = abi.encodeWithSignature("initialize()"); // chatGPT suggested to add initialize() as data in order to get excuted with the script instead of calling the function afterwards, this also prevents anyone taking ownership
        ERC1967Proxy proxy = new ERC1967Proxy(address(box), initializerData); // It takes an address which has the logic and any data if available
        vm.stopBroadcast();
        return address(proxy);
    }
}
