// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0;

import "./U256.sol";
import "../commutative/U256Cum.sol";
import "../multiprocess/Multiprocess.sol";

contract U256MapTest {
    U256Map map = new U256Map();
    constructor() {     
        require(map.nonNilCount() == 0); 
        map.set(10, 100);
        map.set(11, 111);
        require(map.nonNilCount() == 2); 

        require(map.valueAt(0) == 100); 
        require(map.valueAt(1) == 111); 

        (uint256 k, uint256 idx, uint256 v) = map.min();
        require(v == 100); 
        require(idx == 0 && map.get(k) == v);
        ( k,  idx,  v) = map.max();
        require(v == 111); 
        require(idx == 1 && map.get(k) == v);

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
    U256Map map = new U256Map();
    function call() public { 
       Multiprocess mp = new Multiprocess(2); 
       mp.push(500000, address(this), abi.encodeWithSignature("assigner(uint256)", 11));
       mp.push(500000, address(this), abi.encodeWithSignature("assigner(uint256)", 33));
       require(mp.nonNilCount() == 2);
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