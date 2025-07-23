// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0;

import "./Bytes.sol";

contract ByteTest {
    Bytes container = new Bytes(false);    

    constructor() {       
        require(container.nonNilCount() == 0); 
 
        bytes memory arr1 = '0x1000000000000000000000000000000000000000000000000000000000000001';
        bytes memory arr2 = '0x0x2000000000000000000000000000000000000000000000000000000000000002';

        container.push(arr1);  
        container.push(arr2); 

        require(container.nonNilCount() == 2); 
        require(keccak256(container.get(0)) == keccak256(arr1));
        require(keccak256(container.get(1)) == keccak256(arr2));

        container.set(1, arr2);       
        require(keccak256(container.get(0)) == keccak256(arr1));
        require(keccak256(container.get(1)) == keccak256(arr2));
        require(keccak256(container.delLast()) == keccak256(arr2));

        container.clear();
        require(container.nonNilCount() == 0); 
    }
}