// SPDX-License-Identifier: GPL-3.0
pragma solidity >= 0.8.0 < 0.9.0;

import "@arcologynetwork/concurrentlib/lib/commutative/U256Cum.sol";

contract Like {
    U256Cumulative public likes;

    constructor() {
        likes = new U256Cumulative(0, type(uint256).max);
    }

    function like() public {
        likes.add(1);
    }    
}