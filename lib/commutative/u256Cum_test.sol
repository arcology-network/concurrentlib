// SPDX-License-Identifier: GPL-3.0
pragma solidity >= 0.8.0 < 0.9.0;

import "./U256Cum.sol";
import "../multiprocess/Multiprocess.sol";

contract EmptyCumulativeU256Test {
    U256Cumulative[2] values;
    mapping(uint256 => U256Cumulative) map;
    constructor() {  
        require(address(values[0]) == address(0));
        require(address(values[1]) == address(0));

        values[0] = new U256Cumulative(0, 100);
        require(address(values[0]) != address(0));
        require(address(values[1]) == address(0));

        map[0] = new U256Cumulative(0, 100);
        U256Cumulative empty = map[1];

        require(address(map[0]) != address(0));
        require(address(empty) == address(0));
    }
}

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

        U256Cumulative cumulative2 = new U256Cumulative(0, 100);
        cumulative2.add(1);
        require(cumulative2.get() == 1);
    }

    function call() public {
        cumulative.add(1);
        require(cumulative.get() == 1);
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