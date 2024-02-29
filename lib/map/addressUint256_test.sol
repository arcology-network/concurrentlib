// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0 <0.9.0;

import "./AddressUint256.sol";
import "../multiprocess/Multiprocess.sol";

contract AddressU256MapTest {
    AddressUint256Map map = new AddressUint256Map();
    constructor() {     
        address addr1 = 0x1111111110123456789012345678901234567890;
        address addr2 = 0x2222222220123456789012345678901234567890;
        address addr3 = 0x3333337890123456789012345678901234567890;
        address addr4 = 0x4444444890123456789012345678901234567890;

        require(map.length() == 0); 

        map.set(addr1, 11);  
        map.set(addr2, 21);
        map.set(addr3, 31);
        require(map.length() == 3); 

        (address k, uint256 idx, uint256 v) = map.min();
        require(v == 11); 
        require(idx == 0 && map.get(k) == v);

        (k, idx, v) = map.max();
        require(v == 31); 
        require(idx == 2 && map.get(k) == v);
        
        require(map.exist(addr1)); 
        require(map.exist(addr2)); 
        require(map.exist(addr3)); 
        require(!map.exist(addr4)); 

        require(map.get(addr1) == 11); 
        require(map.get(addr2) == 21); 
        require(map.get(addr3) == 31); 
        require(!map.exist(addr4)); 

        require(map.keyAt(0) == addr1);
        require(map.keyAt(1) == addr2);
        require(map.keyAt(2) == addr3);

        map.del(addr1);
        map.del(addr2);
        map.del(addr3);
        require(map.length() == 0); 
    }
}

contract AddressU256MapConcurrentTest {
    AddressUint256Map map = new AddressUint256Map();
    function call() public {     
        address addr1 = 0x1111111110123456789012345678901234567890;
        address addr2 = 0x2222222220123456789012345678901234567890;
        address addr3 = 0x3333337890123456789012345678901234567890;
        address addr4 = 0x4444444890123456789012345678901234567890;

        Multiprocess mp = new Multiprocess(2); 
        mp.push(500000, address(this), abi.encodeWithSignature("setter(address,uint256)", addr1, 11));
        mp.push(500000, address(this), abi.encodeWithSignature("setter(address,uint256)", addr2, 22));
        mp.push(500000, address(this), abi.encodeWithSignature("setter(address,uint256)", addr3, 33));
        require(mp.length() == 3);
        mp.run();

        require(map.exist(addr1)); 
        require(map.exist(addr2)); 
        require(map.exist(addr3)); 
        require(!map.exist(addr4)); 

        require(map.get(addr1) == 11); 
        require(map.get(addr2) == 22); 
        require(map.get(addr3) == 33); 

        require(map.valueAt(0) == 11); 
        require(map.valueAt(1) == 22); 
        require(map.valueAt(2) == 33); 

        require(map.keyAt(0) == addr1); 
        require(map.keyAt(1) == addr2); 
        require(map.keyAt(2) == addr3); 

        map.del(addr1);
        map.del(addr2);
        map.del(addr3);
        require(map.length() == 0); 
    }

    function setter(address addr, uint256 v)  public {
        map.set(addr, v);
    }
}

