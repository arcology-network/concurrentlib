// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0;

import "./AddressU256Cum.sol";
import "../multiprocess/Multiprocess.sol";

contract AddressU256CumTest {
    AddressU256CumMap container = new AddressU256CumMap();
    event LogMax(address k,uint256 idx,uint256 v);
    event Step(address val);
    constructor() {     
        address addr1 = 0x1111111110123456789012345678901234567890;
        address addr2 = 0x2222222220123456789012345678901234567890;
        address addr3 = 0x3333337890123456789012345678901234567890;
        address addr4 = 0x4444444890123456789012345678901234567890;

        require(container.nonNilCount() == 0); 

        container.set(addr1, 0, 0, 1000);  
        container.set(addr2, 0, 0, 1000);
        container.set(addr3, 0, 0, 1000);
        require(container.nonNilCount() == 3); 

        // (address k, uint256 idx, uint256 v) = map.min();
        // require(v == 11); 
        // require(idx == 0 && map.get(k) == v);

        // (k, idx, v) = map.max();
        // require(v == 31); 
        // require(idx == 2 && map.get(k) == v);
        
        // require(map.exist(addr1)); 
        // require(map.exist(addr2)); 
        // require(map.exist(addr3)); 
        // require(!map.exist(addr4)); 

        container.set(addr1, 18, 17, 111);
        container.set(addr2, 19, 18, 112);                
        container.set(addr3, 20, 19, 113);
        require(container.valueAt(1) == 19);
        require(container.keyAt(0) == addr1);

        // require(map.keyAt(0) == addr1);
        // require(map.keyAt(1) == addr2);
        // require(map.keyAt(2) == addr3);

        // map.del(addr1);
        // map.del(addr2);
        // map.del(addr3);
        // require(map.nonNilCount() == 0); 

        require(container.get(addr1) == 19);
        require(container.get(addr2) == 20);
        require(container.get(addr3) == 21);
        (address k, uint256 idx, uint256 v) = container.max();
        require(idx == 2 && container.get(k) == v);
        ( k,  idx,  v) = container.min();
        require(idx == 0 && container.get(k) == v);

        // require(map.valueAt(0) == 110); 
        // require(map.valueAt(1) == 210); 
        // require(map.valueAt(2) == 310); 

        // map.resetByInd(0);
        // map.resetByInd(1);
        // map.resetByInd(2);

        // require(map.valueAt(0) == 0); 
        // require(map.valueAt(1) == 0); 
        // require(map.valueAt(2) == 0); 
        // require(map.nonNilCount() == 3); 


        // map.set(addr1, 410);  
        // map.set(addr2, 510);
        // map.set(addr3, 610);
        // require(map.valueAt(0) == 410); 
        // require(map.valueAt(1) == 510); 
        // require(map.valueAt(2) == 610); 

        // map.resetByKey(addr1);
        // map.resetByKey(addr2);
        // map.resetByKey(addr3);

        // require(map.valueAt(0) == 0); 
        // require(map.valueAt(1) == 0); 
        // require(map.valueAt(2) == 0); 

        // require(map.get(addr1) == 0); 
        // require(map.get(addr2) == 0); 
        // require(map.get(addr3) == 0); 
    }
}

// contract AddressU256CumMapConcurrentTest {
//     AddressU256CumMap map = new AddressU256CumMap();
//     function call() public {     
//         address addr1 = 0x1111111110123456789012345678901234567890;
//         address addr2 = 0x2222222220123456789012345678901234567890;
//         address addr3 = 0x3333337890123456789012345678901234567890;
//         address addr4 = 0x4444444890123456789012345678901234567890;

//         Multiprocess mp = new Multiprocess(2); 
//         mp.push(500000, address(this), abi.encodeWithSignature("setter(address,uint256)", addr1, 11));
//         mp.push(500000, address(this), abi.encodeWithSignature("setter(address,uint256)", addr2, 22));
//         mp.push(500000, address(this), abi.encodeWithSignature("setter(address,uint256)", addr3, 33));
//         require(mp.nonNilCount() == 3);
//         mp.run();

//         require(map.exist(addr1)); 
//         require(map.exist(addr2)); 
//         require(map.exist(addr3)); 
//         require(!map.exist(addr4)); 

//         require(map.get(addr1) == 11); 
//         require(map.get(addr2) == 22); 
//         require(map.get(addr3) == 33); 

//         require(map.valueAt(0) == 11); 
//         require(map.valueAt(1) == 22); 
//         require(map.valueAt(2) == 33); 

//         require(map.keyAt(0) == addr1); 
//         require(map.keyAt(1) == addr2); 
//         require(map.keyAt(2) == addr3); 

//         map.set(addr1, 100);
//         map.set(addr2, 100);
//         map.set(addr3, 100);

//         require(map.valueAt(0) == 110); 
//         require(map.valueAt(1) == 122); 
//         require(map.valueAt(2) == 133); 

//         map.del(addr1);
//         map.del(addr2);
//         map.del(addr3);
//         require(map.nonNilCount() == 0); 
//     }

//     function setter(address addr, uint256 v)  public {
//         map.set(addr, v);
//     }
// }

