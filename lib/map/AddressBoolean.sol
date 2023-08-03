// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.19;

import "../base/Base.sol";

/**
 * @author Arcology Network
 * @title AddressBooleanMap Contract
 * @dev The map contract provides a simple mapping structure to associate
 *      address keys with boolean values. It inherits from the "Base" contract
 *      to utilize container functionalities for key-value storage.
 */
contract AddressBooleanMap is Base { 
    constructor() {}

    /**
     * @notice Check if a given key exists in the map.
     * @param k The address key to check for existence.
     * @return true if the key exists, false otherwise.
     */
    function exist(address k) public virtual returns(bool) { // 9e c6 69 25
        (bool success,) = get(k);
        return success;
    }

    /**
     * @notice Set a key-value pair in the map.
     * @param k The address key to set.
     * @param value The address value associated with the key.
     */
    function set(address k, bool value) public { // 80 26 32 97
        Base.setByKey((abi.encodePacked(k)), abi.encode(value));       
    }

    /**
     * @notice Get the value associated with a given key in the map.
     * @param k The address key to retrieve the associated value.
     * @return success true if the key exists, false otherwise.
     * @return value The address value associated with the key.
     */
    function get(address k) public virtual returns(bool success, bool value){ // 9e c6 69 25
        bytes memory data = Base.getByKey(abi.encodePacked(k));
        if (data.length > 0) {
            return (true, abi.decode(data, (bool)));  
        }
        return (false, false);
    }    

    /**
     * @notice Retrieves the value stored at the specified index.
     * @param idx The index of the element to retrieve.
     * @return value The value retrieved from the storage array at the given index.    
    */
    function at(uint256 idx) public virtual returns(bool value){ // 9e c6 69 25
        bytes memory data = Base.getByIndex(idx);
        if (data.length > 0) {
            return abi.decode(data, (bool));  
        }
        return false;
    }    

    /**
     * @notice Delete a key-value pair from the map.
     * @param k The address key to delete.
     */
    function del(address k) public { // 80 26 32 97
        Base.delByKey((abi.encodePacked(k)));  
    }
}