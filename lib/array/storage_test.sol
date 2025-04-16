// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0 <0.9.0;

import "./Bool.sol";

contract StorageTest {
    Bool bArray = new Bool();
    
    constructor() {
        bArray.push(true);
    }
    
    function call() view public {     
       require(bArray.fullLength() == 1);
    }
}

