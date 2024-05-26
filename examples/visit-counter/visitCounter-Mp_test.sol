// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.19;

import "../../lib/multiprocess/Multiprocess.sol";
import "../../lib/commutative/U256Cum.sol";
import "./VisitCounter.sol";

contract VisitCounterCaller {
    VisitCounter counter = new VisitCounter();
    function call() public {
        // counter.visit();
        Multiprocess mp = new Multiprocess(4);
        mp.push(100000, address(this), abi.encodeWithSignature("callVisit()"));
        // mp.push(100000, address(this), abi.encodeWithSignature("callVisit()"));
        mp.run();
        // require(counter.getCounter() == 2);
    }

    function callVisit() public {
        counter.visit();
    }
}
    
