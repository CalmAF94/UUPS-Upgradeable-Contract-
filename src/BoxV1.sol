// SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

import {OwnableUpgradeable} from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol"; // Adds the standard ownership pattern (owner(), onlyOwner, transferOwnership), but upgradeable.
import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol"; // As proxy contracts cant use constructors because the proxy contract only dirercts calls to implementation contract which is the one having the constructor, so in order to have constructor logic in ur proxy initializable is used
import {UUPSUpgradeable} from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol"; // Implements the logic needed for a contract to be upgradeable using the UUPS pattern.

contract BoxV1 is Initializable, UUPSUpgradeable, OwnableUpgradeable {
    uint256 internal number;

    // @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
        // Your proxy contract will call initialize().
        // The implementation contract must remain “uninitialized” (to avoid being hijacked).
    }

    function initialize() public initializer {
        __Ownable_init(msg.sender); // added msg.sender as OZ v5.x requires it unlike the earlier versions
        __UUPSUpgradeable_init();
    }

    function getNumber() external view returns (uint256) {
        return number;
    }

    function version() external pure returns (uint256) {
        return 1;
    }
    // Gonna leave it as it is as we dont need any authorization, this is like our contract is saying anyone can upgrade this
    function _authorizeUpgrade(address newImplementation) internal override onlyOwner {}
    // This is a required override from UUPSUpgradeable.
    // _authorizeUpgrade() defines who can perform upgrades.
    // Here, it uses onlyOwner, meaning only the contract owner can upgrade the implementation.
    // It’s empty because we don’t need to add logic beyond onlyOwner.
    // If you removed this function, the contract wouldn’t compile, since it’s abstract in the parent.
}
