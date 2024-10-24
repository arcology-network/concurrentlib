// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0 <0.9.0;

import "./U256Cum.sol";

contract U256CumArrayTest {
    U256Cum container = new U256Cum();

    constructor() {    
        require(container.push(17, 17, 111)); 
        require(container.push(111, 17, 111)); 

        require(container.get(0) == 17);
        require(container.get(1) == 111);

        require(container.length() == 2);
        container.clear();
        require(container.length() == 0);

        container.push(18, 17, 111);
        container.push(19, 18, 112);                
        container.push(20, 19, 113);
      
        require(container.length() == 3);

        require(container.get(0) == 18);
        require(container.get(1) == 19);
        require(container.get(2) == 20);

        container.set(0, 1);
        require(container.get(0) == 19);

        container.set(0, -1);
        require(container.get(0) == 18);      

        container.set(0, -1);
        require(container.get(0) == 17);  

        require(!container.set(0, -1)); // Must fail, because the value is out of range
        require(container.get(0) == 17);  // The value should not be changed

        container.set(1, 1);
        require(container.get(1) == 20);

        container.set(2, 1);
        require(container.get(2) == 21);
    }
}