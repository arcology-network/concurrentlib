// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0;

import "./Bytes.sol";

contract WildcardTest {
    Bytes container = new Bytes(false);    

    constructor() {    
        bytes memory arr1 = '0x1000000000000000000000000000000000000000000000000000000000000001';
        container.push(arr1);      
        container.clear();
        require(container.nonNilCount() == 0); 
    }
}