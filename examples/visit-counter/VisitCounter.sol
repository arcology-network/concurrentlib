// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.19;

import "../../lib/commutative/U256Cum.sol";

contract VisitCounter {
    U256Cumulative visitCount;

    event CounterQuery(uint256 value);

    constructor()  {
        visitCount = new U256Cumulative(0, 1000000) ;
    }

    function visit() public {
        visitCount.add(1);
    }

    function getCounter() public returns(uint256){
        emit CounterQuery(visitCount.get());
        return visitCount.get();
    }
}