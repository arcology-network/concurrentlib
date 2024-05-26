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
    constructor() {}

    /**
     * @notice Check if a given key exists in the map.
     * @param k The address key to check for existence.
     * @return true if the key exists, false otherwise.
     */
    function exist(address k) public  returns(bool) { 
        return Base.keyExists(abi.encodePacked(k));
    }

    /**
     * @notice Set a key-value pair in the map.
     * @param k The address key to set.
     * @param value The boolean value associated with the key.
     */
    function set(address k, bool value) public { 
        Base.setByKey((abi.encodePacked(k)), abi.encode(value));       
    }

    /**
     * @notice Get the value associated with a given key in the map.
     * @param k The address key to retrieve the associated value.
     * @return The boolean value associated with the key.
     */
    function get(address k) public virtual returns(bool){ 
        return abi.decode(Base.getByKey(abi.encodePacked(k)), (bool));  
    }   

    /**
     * @notice Get the key based on it index.
     * @param idx The key to retrieve the associated index.
     * @return The index key associated with the index.
     */
    function keyAt(uint256 idx) public virtual returns(address) {    
        return address(uint160(bytes20(Base.keyByIndex(idx))));
    }   

    /**
     * @notice Retrieves the value stored at the specified index.
     * @param idx The index of the element to retrieve.
     * @return value The value retrieved from the storage array at the given index.    
    */
    function valueAt(uint256 idx) public virtual returns(bool){ 
        return abi.decode(Base.getByIndex(idx), (bool));  
    }    

    /**
     * @notice Delete a key-value pair from the map.
     * @param k The address key to delete.
     */
    function del(address k) public { 
        Base.delByKey((abi.encodePacked(k)));  
    }
}