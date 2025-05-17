// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0;

import "./Bool.sol";

contract BoolTest {
    Bool boolContainer = new Bool();
    
    constructor() {     
        require(boolContainer.nonNilCount() == 0); 
    
        boolContainer.push(true);
        boolContainer.push(false);
        boolContainer.push(false);
        boolContainer.push(true);
        require(boolContainer.nonNilCount() == 4); 

       require(boolContainer.get(0));
        require(!boolContainer.get(1));
        require(!boolContainer.get(2));
        require(boolContainer.get(3));

        boolContainer.set(0, false);
        boolContainer.set(1, true);
        boolContainer.set(2, true);
        boolContainer.set(3, false);

        require(!boolContainer.get(0));
        require(boolContainer.get(1));
        require(boolContainer.get(2));
        require(!boolContainer.get(3));

        require(!boolContainer.delLast());
        require(boolContainer.delLast());
        require(boolContainer.delLast());
        require(!boolContainer.delLast());
        require(boolContainer.nonNilCount() == 0);  
        boolContainer.push(true);
        boolContainer.push(true);

        require(boolContainer.fullLength() == 6);  
    }

    function check() public{
        require(boolContainer.nonNilCount() == 2);  
    }

    function call() public{
        boolContainer.push(true);
        require(boolContainer.nonNilCount() == 2);  
        boolContainer.push(true);
        require(boolContainer.nonNilCount() == 2);  
    }
}
