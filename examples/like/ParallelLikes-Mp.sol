// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0 <0.9.0;

import "../../lib/commutative/U256Cum.sol";

contract Like {
    // Cumulative counter for likes, it allows concurrent increment operations.
    // The first parameter is the lower bound, the second parameter is the upper bound.
    // The variable will never exceed the bounds
    U256Cumulative likes = new U256Cumulative(0, type(uint256).max);

    function like() public {
        likes.add(1);
    }
}