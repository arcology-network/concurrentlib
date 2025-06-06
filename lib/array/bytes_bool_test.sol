// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0;

import "./Bytes.sol";
import "./Bool.sol";

contract PairTest {
    Bytes bytesContainer = new Bytes();
    Bool boolContainer = new Bool();
    constructor() {     
        require(bytesContainer.nonNilCount() == 0); 
 
        bytes memory arr1 = '0x1000000000000000000000000000000000000000000000000000000000000001';
        bytes memory arr2 = '0x2000000000000000000000000000000000000000000000000000000000000002';

        bytesContainer.push(arr1);  
        bytesContainer.push(arr1); 

        require(bytesContainer.nonNilCount() == 2); 

        require(keccak256(bytesContainer.get(1)) == keccak256(arr1));

        bytesContainer.set(1, arr2);       

        require(keccak256(bytesContainer.get(0)) == keccak256(arr1));
        require(keccak256(bytesContainer.get(1)) == keccak256(arr2));
        require(keccak256(bytesContainer.delLast()) == keccak256(arr2));

        bytesContainer.delLast();
        require(bytesContainer.nonNilCount() == 0); 

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
    }
}