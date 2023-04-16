// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.4;

import { Script } from "forge-std/Script.sol";
import { UUPSProxy } from "../src/proxies/UUPSProxy.sol";
import { Foo, FooV2 } from "../src/Foo.sol";
import "forge-std/console.sol";

/// @dev See the Solidity Scripting tutorial: https://book.getfoundry.sh/tutorials/solidity-scripting
contract DeployFoo is Script {
    UUPSProxy proxy;
    Foo internal wrappedProxyV1;
    FooV2 internal wrappedProxyV2;

    function run() public {
        vm.startBroadcast();
        
        Foo implementationV1 = new Foo();
        
        // deploy proxy contract and point it to implementation
        proxy = new UUPSProxy(address(implementationV1), "");
        
        // wrap in ABI to support easier calls
        wrappedProxyV1 = Foo(address(proxy));
        wrappedProxyV1.initialize(100);

        // expect 100
        console.log(wrappedProxyV1.x());

        // new implementation
        FooV2 implementationV2 = new FooV2();
        wrappedProxyV1.upgradeTo(address(implementationV2));
        
        wrappedProxyV2 = FooV2(address(proxy));
        wrappedProxyV2.setY(200);

        console.log(wrappedProxyV2.x(), wrappedProxyV2.y());

        vm.stopBroadcast();
    }
}
