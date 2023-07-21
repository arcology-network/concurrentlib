// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.19;

import "../map/Map.sol";

/**
 * @author Arcology Network
 * @title U256Set Contract
 * @dev The U256Set contract is a specialization of the U256Map contract that provides a simple set data structure.
 *      It inherits from the U256Map contract and utilizes its key-value storage functionality to implement the set.
 */
contract U256Set is U256Map { 
    constructor() {}

    /**
     * @notice Add an element to the U256Set.
     * @param key The uint256 element to add to the set.
     */
    function set(uint256 key) public { // 80 26 32 97
        Base.setByKey((abi.encodePacked(key)), abi.encodePacked(uint256(1)));       
    }
}
