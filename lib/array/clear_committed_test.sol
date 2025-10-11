// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0;

import "./Bool.sol";

contract ClearCommittedTest {
    Bool boolContainer = new Bool();
    
    constructor() {     
        boolContainer.push(true);
        boolContainer.push(true);       
    }

    function clear() public{        
        require(boolContainer.nonNilCount() == 2);  
   
        boolContainer.clearCommitted();
        require(boolContainer.nonNilCount() == 0);  
        require(boolContainer.committedLength() == 2); // This is the length of committed elements at the beginning.
    }
}
