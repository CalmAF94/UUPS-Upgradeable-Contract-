// pragma solidity ^0.8.24;

// import {Test} from "forge-std/Test.sol";
// import {DeployBox} from "../script/DeployBox.s.sol";
// import {UpgradeBox} from "../script/UpgradeBox.s.sol";
// import {BoxV1} from "../src/BoxV1.sol";
// import {BoxV2} from "../src/BoxV2.sol";

// contract DeployAndUpgradeTest is Test {
//     DeployBox public deployer;
//     UpgradeBox public upgrader;
//     address public OWNER = makeAddr("owner");

//     address public proxy;

//     function setUp() public {
//         deployer = new DeployBox();
//         upgrader = new UpgradeBox();
//         proxy = deployer.run(); // Now points to BoxV1
//     }

//     function testProxyStartsAsBoxV1() public {
//         vm.expectRevert();
//         BoxV2(proxy).setNumber(7);
//     }

//     function testUpgrades() public {
//         BoxV2 box2 = new BoxV2();
//         upgrader.upgradeBox(proxy, address(box2));

//         uint256 expectedValue = 2;
//         assertEq(expectedValue, BoxV2(proxy).version()); // This means on proxy make sure its now pointing to BoxV2

//         BoxV2(proxy).setNumber(7);
//         assertEq(7, BoxV2(proxy).getNumber());
//     }
// }

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {DeployBox} from "../script/DeployBox.s.sol";
import {UpgradeBox} from "../script/UpgradeBox.s.sol";
import {Test} from "forge-std/Test.sol";
import {StdCheats} from "forge-std/StdCheats.sol";
import {BoxV1} from "../src/BoxV1.sol";
import {BoxV2} from "../src/BoxV2.sol";

contract DeployAndUpgradeTest is StdCheats, Test {
    DeployBox public deployBox;
    UpgradeBox public upgradeBox;
    address public OWNER = address(1);

    function setUp() public {
        deployBox = new DeployBox();
        upgradeBox = new UpgradeBox();
    }

    function testBoxWorks() public {
        address proxyAddress = deployBox.deployBox();
        uint256 expectedValue = 1;
        assertEq(expectedValue, BoxV1(proxyAddress).version());
    }

    // This ensures that before the upgrade,
    //the proxy does not have access to new functions from BoxV2 yet — confirming the proxy is truly still on V1.
    function testDeploymentIsV1() public {
        address proxyAddress = deployBox.deployBox();
        uint256 expectedValue = 7;
        vm.expectRevert();
        BoxV2(proxyAddress).setNumber(expectedValue);
    }

    function testUpgradeWorks() public {
        // Step 1️⃣: Deploy V1
        address proxyAddress = deployBox.deployBox();
        // Step 2️⃣: Deploy new implementation (BoxV2)
        BoxV2 box2 = new BoxV2();
        // Step 3️⃣: Transfer ownership
        // Since upgradeTo in UUPSUpgradeable can only be called by the owner,
        // we simulate the owner transferring ownership to the test runner (msg.sender) so the test can call the upgrade.
        vm.prank(BoxV1(proxyAddress).owner());
        BoxV1(proxyAddress).transferOwnership(msg.sender);
        // Step 4️⃣: Perform the upgrade
        address proxy = upgradeBox.upgradeBox(proxyAddress, address(box2));
        // Step 5️⃣: Verify new version
        uint256 expectedValue = 2;
        assertEq(expectedValue, BoxV2(proxy).version());
        // Step 6️⃣: Test new functionality in BoxV2 only
        BoxV2(proxy).setNumber(expectedValue);
        assertEq(expectedValue, BoxV2(proxy).getNumber());
    }
}
