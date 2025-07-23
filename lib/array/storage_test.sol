// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0;

import "./Bool.sol";

contract StorageTest {
    Bool bArray = new Bool(false);
    
    constructor() {
        bArray.push(true);
    }
    
    function call() public {     
       require(bArray.fullLength() == 1);
    }
}

