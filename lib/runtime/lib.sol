// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0 <0.9.0;

library lib {   
    function deferred() public returns(bool) {
        // (bool successful,) = address(0xa0).call(abi.encodeWithSignature("deferred(bytes4)", bytes4(keccak256(bytes(func)))));
        // return successful;  
        return true;
    }
}
