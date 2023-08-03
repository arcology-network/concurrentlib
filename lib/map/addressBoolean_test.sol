// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.19;

import "./AddressBoolean.sol";
import "../multiprocess/Multiprocess.sol";

contract AddressBooleanMapTest {
    AddressBooleanMap map = new AddressBooleanMap();
    constructor() {     
        address addr1 = 0x1111111110123456789012345678901234567890;
        address addr2 = 0x2222222220123456789012345678901234567890;
        address addr3 = 0x3333337890123456789012345678901234567890;
        address addr4 = 0x4444444890123456789012345678901234567890;

        require(map.length() == 0); 
        map.set(addr1, true);
        map.set(addr2, false);
        map.set(addr3, false);
        require(map.length() == 3); 
        
        require(map.exist(addr1)); 
        require(map.exist(addr2)); 
        require(map.exist(addr3)); 
        require(!map.exist(addr4)); 

        (,bool v) = map.get(addr1);
        require(v == true); 

        (, v) = map.get(addr2);
        require(v == false); 

        (, v) = map.get(addr3);
        require(v == false); 

        (, v) = map.get(addr4);
        require(v == false); 

        map.del(addr1);
        map.del(addr2);
        map.del(addr3);
        require(map.length() == 0); 
    }
}
