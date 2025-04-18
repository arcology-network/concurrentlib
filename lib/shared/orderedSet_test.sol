// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0 <0.9.0;

import "./OrderedSet.sol";

contract ByteTest {
    BytesOrderedSet container = new BytesOrderedSet();    

    constructor() {       
        // require(container.nonNilCount() == 0); 
 
        bytes memory arr1 = '0x10';
        bytes memory arr2 = '0x20';

        container.set(arr1);  
        container.set(arr2); 

        // require(container.nonNilCount() == 2);
        require(container.exists(arr1));
        // require(container.exists(arr2));

        // require(container.nonNilCount() == 2); 
        // require(keccak256(container.get(0)) == keccak256(arr1));
        // require(keccak256(container.get(1)) == keccak256(arr2));

        // container.set(1, arr2);       
        // require(keccak256(container.get(0)) == keccak256(arr1));
        // require(keccak256(container.get(1)) == keccak256(arr2));
        // require(keccak256(container.pop()) == keccak256(arr2));

        // container.clear();
        // require(container.nonNilCount() == 0); 
    }
}