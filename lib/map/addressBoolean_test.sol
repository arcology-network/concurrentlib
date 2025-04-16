// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0;

import "./AddressBoolean.sol";
import "../multiprocess/Multiprocess.sol";

contract AddressBooleanMapTest {
    AddressBooleanMap map = new AddressBooleanMap();
    constructor() {     
        address addr1 = 0x1111111110123456789012345678901234567890;
        address addr2 = 0x2222222220123456789012345678901234567890;
        address addr3 = 0x3333337890123456789012345678901234567890;
        address addr4 = 0x4444444890123456789012345678901234567890;

        require(map.nonNilCount() == 0); 
        map.set(addr1, true);
        map.set(addr2, true);
        map.set(addr3, true);
        require(map.valueAt(1) == true);
        require(map.nonNilCount() == 3); 

        require(map.exist(addr1)); 
        require(map.exist(addr2)); 
        require(map.exist(addr3)); 
        require(!map.exist(addr4));

        require(map.get(addr1) == true); 
        require(map.get(addr2) == true); 
        require(map.get(addr3) == true); 
        require(map._exists(2));
        require(!map._exists(3));

        require(!map.exist(addr4));

        require(map.keyAt(0) == addr1);
        require(map.keyAt(1) == addr2);
        require(map.keyAt(2) == addr3);

        map.del(addr1);
        map.del(addr2);
        map.del(addr3);
        require(map.nonNilCount() == 0); 

        map.set(addr1, true);  
        map.set(addr2, true);
        map.set(addr3, true);
        require(map.nonNilCount() == 3); 
    }
}

contract AddressBooleanMapConcurrentTest {
    AddressBooleanMap map = new AddressBooleanMap();
    function call() public {     
        address addr1 = 0x1111111110123456789012345678901234567890;
        address addr2 = 0x2222222220123456789012345678901234567890;
        address addr3 = 0x3333337890123456789012345678901234567890;
        address addr4 = 0x4444444890123456789012345678901234567890;

        Multiprocess mp = new Multiprocess(2); 
        mp.push(500000, address(this), abi.encodeWithSignature("setter(address)", addr1));
        mp.push(500000, address(this), abi.encodeWithSignature("setter(address)", addr2));
        mp.push(500000, address(this), abi.encodeWithSignature("setter(address)", addr3));
        require(mp.nonNilCount() == 3);
        mp.run();

        require(map.exist(addr1)); 
        require(map.exist(addr2)); 
        require(map.exist(addr3)); 
        require(!map.exist(addr4)); 

        require(map.get(addr1) == true); 
        require(map.get(addr2) == true); 
        require(map.get(addr3) == true); 

        require(map.valueAt(0) == true); 
        require(map.valueAt(1) == true); 
        require(map.valueAt(2) == true); 

        require(map.keyAt(0) == addr1); 
        require(map.keyAt(1) == addr2); 
        require(map.keyAt(2) == addr3); 

        map.del(addr1);
        map.del(addr2);
        map.del(addr3);
        require(map.nonNilCount() == 0); 
    }

    function setter(address v)  public {
        map.set(v, true);
    }
}

