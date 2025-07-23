// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0;

import "./U256.sol";
import "../commutative/U256Cum.sol";
import "../multiprocess/Multiprocess.sol";

contract U256MapTest {
    U256Map map = new U256Map(false);
    constructor() {     
        require(map.nonNilCount() == 0); 
        map.set(10, 100);
        map.set(11, 111);
        require(map.nonNilCount() == 2); 

        require(map.valueAt(0) == 100); 
        require(map.valueAt(1) == 111); 

        require(map.keyAt(0) == 10); 
        require(map.keyAt(1) == 11); 

        require(!map.exist(0));
        require(map.exist(10)); 
        require(map.exist(11)); 

        require(map.get(11) == 111);       
        require(map.get(10) == 100); 

        map.del(10);
        require(map.nonNilCount() == 1); 

        require(map.exist(11));
        map.del(11);
        require(map.nonNilCount() == 0); 

        require(!map.exist(10));
        require(!map.exist(11));
    }
}

contract ConcurrenctU256MapTest {
    U256Map map = new U256Map(false);
    function call() public { 
       Multiprocess mp = new Multiprocess(2); 
       mp.addJob(500000, 0, address(this), abi.encodeWithSignature("assigner(uint256)", 11));
       mp.addJob(500000, 0, address(this), abi.encodeWithSignature("assigner(uint256)", 33));
       mp.run();

        require(map.get(11) == 110); 
        require(map.get(33) == 330); 

        map.del(11);
        require(map.nonNilCount() == 1); 
        require(!map.exist(11));

        require(map.get(33) == 330); 
        map.del(33);
        require(map.nonNilCount() == 0); 

        require(!map.exist(11));
        require(!map.exist(33));
    }

    function assigner(uint256 v)  public {
        map.set(v, v * 10);
    }
} 