
// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0 <0.9.0;

import "./Const.sol";
import "./Backend.sol";
import "../runtime/Runtime.sol";
import "../runtime/Debug.sol";

contract BackendTest {
    Backend container = new Backend(Const.BYTES, address(0x84));    

    constructor() {       
        bytes memory elem1 = '0x1111111';
        bytes memory elem2 = '0x2222222';

        (bool success, bytes memory data) = container.eval(abi.encodeWithSignature("setByKey(bytes,bytes)", Runtime.uuid(), elem1)); 
        require(success, "Failed to set element");
        container.eval(abi.encodeWithSignature("setByKey(bytes,bytes)", Runtime.uuid(), elem2)); 

        (success, data) = container.eval(abi.encodeWithSignature("getByIndex(uint256)", 0)); 
        require(success, "Failed to get element");
        require(keccak256(data) == keccak256(elem1)); 

        (success, data) = container.eval(abi.encodeWithSignature("getByIndex(uint256)", 1)); 
        require(success, "Failed to get element");
        require(keccak256(data) == keccak256(elem2)); 
    }
}
