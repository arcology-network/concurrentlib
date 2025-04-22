// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0;

import "./OrderedSet.sol";

contract OrderedSetTest {
    BytesOrderedSet container = new BytesOrderedSet();    

    constructor() {       
        bytes memory arr1 = '0x10';
        bytes memory arr2 = '0x20';
        bytes memory arr3 = '0x30';

        container.set(arr1);  
        container.set(arr2); 

        require(container.exists(arr1));
        require(container.exists(arr2));
        require(!container.exists(arr3));

        require(container.exists(arr1));
        require(container.exists(arr2));

        require(keccak256(container.get(0)) == keccak256(arr1));
        require(keccak256(container.get(1)) == keccak256(arr2));

        container.clear();

        require(!container.exists(arr1));
        require(!container.exists(arr2));
        require(!container.exists(arr3));

        container.set(arr1);  
        container.set(arr2); 

        require(container.exists(arr1));
        require(container.exists(arr2));
        require(!container.exists(arr3));
        require(container.Length() == 2);

        container.set(arr1);  
        container.set(arr2); 
        require(container.Length() == 2);
    }
}