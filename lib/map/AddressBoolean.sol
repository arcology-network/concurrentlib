// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0 <0.9.0;

import "../base/Base.sol";

/**
 * @author Arcology Network
 * @title AddressBooleanMap Contract
 * @dev The map contract provides a simple mapping structure to associate
 *      address keys with boolean values. It inherits from the "Base" contract
 *      to utilize container functionalities for key-value storage.
 */
contract AddressBooleanMap is Base { 
    constructor() Base(Base.BYTES) {}

    /**
     * @notice Check if a given key exists in the map.
     * @param k The address key to check for existence.
     * @return true if the key exists, false otherwise.
     */
    function exist(address k) public view returns(bool) { 
        return Base._exists(abi.encodePacked(k));
    }

    /**
     * @notice Set a key-value pair in the map.
     * @param k The address key to set.
     * @param value The boolean value associated with the key.
     */
    function set(address k, bool value) public { 
        Base._set(abi.encodePacked(k), abi.encode(value));       
    }

    /**
     * @notice Get the value associated with a given key in the map.
     * @param k The address key to retrieve the associated value.
     * @return The boolean value associated with the key.
     */
    function get(address k) public virtual view returns(bool){ 
        return abi.decode(Base._get(abi.encodePacked(k)), (bool));  
    }   

    /**
     * @notice Get the key based on it index.
     * @param idx The key to retrieve the associated index.
     * @return The index key associated with the index.
     */
    function keyAt(uint256 idx) public virtual view returns(address) {    
        return address(uint160(bytes20(Base.indToKey(idx))));
    }   

    /**
     * @notice Retrieves the value stored at the specified index.
     * @param idx The index of the element to retrieve.
     * @return value The value retrieved from the storage array at the given index.    
    */
    function valueAt(uint256 idx) public virtual view returns(bool){ 
        return abi.decode(Base._get(idx), (bool));  
    }    

    /**
     * @notice Delete a key-value pair from the map.
     * @param k The address key to delete.
     */
    function del(address k) public { 
        Base._del((abi.encodePacked(k)));  
    }
}