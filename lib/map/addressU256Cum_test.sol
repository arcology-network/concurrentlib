// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0;

import "./AddressU256Cum.sol";

contract AddressU256CumTest {
    AddressU256Map container = new AddressU256Map();
    event LogMax(address k,uint256 idx,uint256 v);
    event Step(address val);
    constructor() {     
        address addr1 = 0x1111111110123456789012345678901234567890;
        address addr2 = 0x2222222220123456789012345678901234567890;
        address addr3 = 0x3333337890123456789012345678901234567890;

        container.insert(addr1, 18, 17, 111);
        container.insert(addr2, 19, 18, 112);                
        container.insert(addr3, 20, 19, 113);
        require(container.valueAt(1) == 19);
        require(container.keyAt(0) == addr1);

        require(container.get(addr1) == 18);
        require(container.get(addr2) == 19);
        require(container.get(addr3) == 20);
        require(container.nonNilCount() == 3);

        container.set(addr1, 1); // Set delta to 1
        container.set(addr2, 1); // Set delta to 1
        container.set(addr3, 1); // Set delta to 1 

        require(container.get(addr1) == 19);
        require(container.get(addr2) == 20);
        require(container.get(addr3) == 21);
        (address k, uint256 idx, uint256 v) = container.max();
        require(idx == 2 && container.get(k) == v);
        ( k,  idx,  v) = container.min();
        require(idx == 0 && container.get(k) == v);

        container.del(addr1);
        require(container.nonNilCount() == 2);

        require(!container.exist(addr1));

        require(!container.del(addr1));
        require(container.nonNilCount() == 2);

        container.insert(addr1, 38, 27, 111);
        require(container.get(addr1) == 38);
        require(container.nonNilCount() == 3);
    }
}

