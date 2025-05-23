// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0;

import "./Int256.sol";

contract Int256Test {
    Int256 container = new Int256();
    
    constructor() {     
       require(container.nonNilCount() == 0); 
    
        container.push((10));
        container.push((-20));
        container.push((30));
        container.push((40));
        require(container.nonNilCount() == 4); 
        
        require(container.get(0) == (10));
        require(container.get(1) == (-20));
        require(container.get(2) == (30));
        require(container.get(3) == (40));    

        container.set(0, (-11));
        container.set(1, (12));
        container.set(2, (13));
        container.set(3, (14));

        require(container.get(0) == (-11));
        require(container.get(1) == (12));
        require(container.get(2) == (13));
        require(container.get(3) == (14));

        require(container.delLast() == (14));
        require(container.delLast() == (13));
        require(container.delLast() == (12));
        require(container.delLast() == (-11));
        require(container.nonNilCount() == 0); 
    }
}