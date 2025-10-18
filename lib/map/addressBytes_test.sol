// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0;

import "./AddressBytes.sol";

contract AddressBytesMapTest {
    AddressBytesMap map = new AddressBytesMap();
    event LogBytes(address k, uint256 idx, bytes v);
    event Step(address val);
    constructor() {
        address addr1 = 0x1111111110123456789012345678901234567890;
        address addr2 = 0x2222222220123456789012345678901234567890;
        address addr3 = 0x3333337890123456789012345678901234567890;
        address addr4 = 0x4444444890123456789012345678901234567890;

        require(map.exist(addr1) == false);
        require(map.exist(addr2) == false);
        require(map.exist(addr3) == false);
        require(map.exist(addr4) == false);

        map.set(addr1, hex"010203");
        map.set(addr2, hex"aabbcc");
        map.set(addr3, hex"deadbeef");
        require(map.exist(addr1));
        require(map.exist(addr2));
        require(map.exist(addr3));
        require(!map.exist(addr4));

        require(keccak256(map.get(addr1)) == keccak256(hex"010203"));
        require(keccak256(map.get(addr2)) == keccak256(hex"aabbcc"));
        require(keccak256(map.get(addr3)) == keccak256(hex"deadbeef"));
        require(keccak256(map.get(addr4)) == keccak256("") );

        require(map.keyAt(0) == addr1);
        require(map.keyAt(1) == addr2);
        require(map.keyAt(2) == addr3);

        map.del(addr1);
        map.del(addr2);
        map.del(addr3);
        require(map.exist(addr1) == false);
        require(map.exist(addr2) == false);
        require(map.exist(addr3) == false);
        require(map.exist(addr4) == false);
    }
}
