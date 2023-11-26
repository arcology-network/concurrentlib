// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.19;

import "./U256Cum.sol";
import "../multiprocess/Multiprocess.sol";

contract CumulativeU256Test {
    U256Cumulative cumulative ;

    constructor() {    
        cumulative = new U256Cumulative(1, 100);  // [1, 100]
        require(cumulative.min() == 1);
        require(cumulative.max() == 100);

        require(cumulative.add(99));
        
        cumulative.sub(99); // This won't succeed, so still 99
        require(cumulative.get() == 99);


        cumulative.add(1);
        require(cumulative.get() == 100);

        cumulative.sub(100); // This won't succeed either, so still 100
        require(cumulative.get() == 100);

        cumulative.sub(99);
        require(cumulative.get() == 1);

        cumulative = new U256Cumulative(0, 100);  // [0, 100]
        require(cumulative.get() == 0);

        require(cumulative.add(99));
        require(cumulative.get() == 99);
        
        require(cumulative.sub(99));
        require(cumulative.get() == 0);

        require(cumulative.min() == 0);
        require(cumulative.max() == 100);
    }

    function call() public {
        cumulative.add(1);
        require(cumulative.get() == 11);
    }
}

contract VisitCounter {    
    U256Cumulative visitCount;
    event CounterQuery(uint256 value);

    constructor()  {
        visitCount = new U256Cumulative(0, 1000000);
    }

    function call() public {
        visitCount.add(1);
        require(visitCount.get() == 1);
    }

    function getCounter() public returns(uint256){
        emit CounterQuery(visitCount.get());
        return visitCount.get();
    }
}