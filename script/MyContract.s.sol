// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.12;

import "forge-std/console.sol";
import { Script } from "forge-std/Script.sol";
import { TransparentUpgradeableProxy, ITransparentUpgradeableProxy } from "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";
import { ProxyAdmin } from "@openzeppelin/contracts/proxy/transparent/ProxyAdmin.sol";
import { MyContract, MyContractV2 } from "../src/MyContract.sol";

contract DeployMyContract is Script {
    MyContract implementationV1;
    TransparentUpgradeableProxy proxy;
    MyContract wrappedProxyV1;
    MyContractV2 wrappedProxyV2;
    ProxyAdmin admin;

    function run() public {
        vm.startBroadcast();

        admin = new ProxyAdmin();

        implementationV1 = new MyContract();
        
        // deploy proxy contract and point it to implementation
        proxy = new TransparentUpgradeableProxy(address(implementationV1), address(admin), "");
        
        // wrap in ABI to support easier calls
        wrappedProxyV1 = MyContract(address(proxy));
        wrappedProxyV1.initialize(100);


        // expect 100
        console.log(wrappedProxyV1.x());

        // new implementation
        MyContractV2 implementationV2 = new MyContractV2();
        admin.upgrade(ITransparentUpgradeableProxy(address(proxy)), address(implementationV2));
        
        wrappedProxyV2 = MyContractV2(address(proxy));
        wrappedProxyV2.setY(200);

        console.log(wrappedProxyV2.x(), wrappedProxyV2.y());

        vm.stopBroadcast();
    }

}