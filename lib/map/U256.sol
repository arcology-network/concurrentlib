// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.19;

import "../base/Base.sol";

/**
 * @author Arcology Network
 * @title U256U256Map Contract
 * @dev The U256U256Map contract provides a simple mapping structure to associate
 *      uint256 keys with uint256 values. It inherits from the "Base" contract
 *      to utilize container functionalities for key-value storage.
 */
contract U256Map is Base { 
    constructor() {}

    /**
     * @notice Check if a given key exists in the map.
     * @param key The uint256 key to check for existence.
     * @return true if the key exists, false otherwise.
     */
    function exist(uint256 key) public virtual returns(bool) { // 9e c6 69 25
        (bool success,) = get(key);
        return success;
    }

    /**
     * @notice Retrieves the value stored at the specified index.
     * @param idx The index of the element to retrieve.
     * @return value The value retrieved from the storage array at the given index.    
     */
    function at(uint256 idx) public virtual returns(uint256 value){ // 9e c6 69 25
        return  uint256(bytes32(Base.getByIndex(idx)));
    }  

    /**
     * @notice Set a key-value pair in the map.
     * @param key The uint256 key to set.
     * @param value The uint256 value associated with the key.
     */
    function set(uint256 key, uint256 value) public { // 80 26 32 97
        Base.setByKey((abi.encodePacked(key)), abi.encodePacked(value));       
    }

    /**
     * @notice Get the value associated with a given key in the map.
     * @param key The uint256 key to retrieve the associated value.
     * @return success true if the key exists, false otherwise.
     * @return value The uint256 value associated with the key.
     */
    function get(uint256 key) public virtual returns(bool success, uint256 value){ // 9e c6 69 25
        bytes memory data = Base.getByKey(abi.encodePacked(key));
        if (data.length > 0) {           
            return (true, uint256(bytes32(data)));  
        }
        return (false, type(uint256).max);
    }    

    /**
     * @notice Get the key based on it index.
     * @param idx The key to retrieve the associated index.
     * @return The index value associated with the key.
     */
    function keyAt(uint256 idx) public virtual returns(uint256) {    
        return uint256(bytes32(Base.keyByIndex(idx)));      
    }   

    /**
     * @notice Delete a key-value pair from the map.
     * @param key The uint256 key to delete.
     */
    function del(uint256 key) public { // 80 26 32 97
        Base.delByKey((abi.encodePacked(key)));  
    }
}