// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0 <0.9.0;

import "./U256Cum.sol";

contract U256CumTest {
    U256Cum container = new U256Cum();

    constructor() {     
        container.push(18, 17, 111);
        require(container.get(0) == 18);

        // container.push(19, 18, 112);
        // require(container.get(1) == 19);

        // container.push(20, 19, 113);
        // require(container.get(2) == 20);

        // require(container.get(0) == 18);
        // require(container.get(1) == 19);
        // require(container.get(2) == 20);

          // require(container.length() == 0); 
    
        // container.push(uint256(10));
        // container.push(uint256(20));
        // container.push(uint256(30));
        // container.push(uint256(40));
        // require(container.length() == 4;
    }
}