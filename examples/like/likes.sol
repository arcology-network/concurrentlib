// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0 <0.9.0;

contract Like {
    uint public likes;

    function like() public {
        likes += 1;
    }    
}