// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.19 <0.9.0;
import "./testlib.sol";
import "./runtimelib.sol";

contract MyContract {
    // constructor
    function call() public returns (uint){
        Runtimelib.deferred("test");
        return TestLibrary.deferred(116, 20);
    }
}
