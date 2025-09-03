// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0;

import "./HashU256Cum.sol";

contract HashU256MapTest {
    HashU256Map container = new HashU256Map();

    constructor() {     
        bytes32 hash1 = keccak256(abi.encodePacked("0"));
        bytes32 hash2 = keccak256(abi.encodePacked("1"));
        bytes32 hash3 = keccak256(abi.encodePacked("2"));
        bytes32 hash4 = keccak256(abi.encodePacked("3"));

        container.set(hash1, 18, 17, 111);
        container.set(hash2, 19, 18, 112);                
        container.set(hash3, 20, 19, 113);

        require(container.get(hash1) == 18);
        require(container.get(hash2) == 19);
        require(container.get(hash3) == 20);
        require(container.nonNilCount() == 3);

        container.set(hash1, 1); // Set delta to 1
        container.set(hash2, 1); // Set delta to 1
        container.set(hash3, 1); // Set delta to 1 

        require(container.get(hash1) == 19);
        require(container.get(hash2) == 20);
        require(container.get(hash3) == 21);

        container.del(hash1);
        require(container.nonNilCount() == 2);
        require(!container.exist(hash1));

        require(!container.del(hash1));
        require(container.nonNilCount() == 2);

        container.set(hash1, 38, 27, 111);
        require(container.get(hash1) == 38);
        require(container.nonNilCount() == 3);

        container.set(hash1, 1); // Set delta to 1

        // container.resetByInd(1);
        require(container.get(hash2) == 20);

        container.set(hash4, 20, 0, 113);    
    }

    function resetter() public{
        bytes32 hash4 = keccak256(abi.encodePacked("3"));
        container.resetByInd(3);
        require(container.get(hash4) == 0);     
    }
}

