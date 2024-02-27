// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0 <0.9.0;

import "@arcologynetwork/concurrentlib/lib/commutative/U256Cum.sol";

// This is a simple contract that allows users to like and retrieve the number of likes. 
// It supports concurrent calls to the like function is OK.
contract Like {
    U256Cumulative likes = new U256Cumulative(0, type(uint256).max); // Using a commutative counter to store the number of likes. 
    event CounterQuery(uint256 value);

    //Increments the number of likes by 1. Concurrent calls to this function is OK
    function like() public {
        likes.add(1);
    } 

    //Returns the number of likes
    function getLikes() public returns(uint256){
        emit CounterQuery(likes.get());
        return likes.get();
    }
}