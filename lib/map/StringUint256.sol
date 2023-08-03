// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.19;

import "../base/Base.sol";

/**
 * @author Arcology Network
 * @title StringUint256Map Contract
 * @dev The map contract provides a simple mapping structure to associate
 *      string keys with boolean values. It inherits from the "Base" contract
 *      to utilize container functionalities for key-value storage.
 */
contract StringUint256Map is Base { 
    constructor() {}

    /**
     * @notice Check if a given key exists in the map.
     * @param k The string key to check for existence.
     * @return true if the key exists, false otherwise.
     */
    function exist(string memory k) public virtual returns(bool) { // 9e c6 69 25
        return Base.exist(bytes(k));
    }

    /**
     * @notice Set a key-value pair in the map.
     * @param k The string key to set.
     * @param value The string value associated with the key.
     */
    function set(string memory k, uint256 value) public { // 80 26 32 97
        Base.setByKey(bytes(k), abi.encodePacked(value));       
    }

    /**
     * @notice Get the value associated with a given key in the map.
     * @param k The string key to retrieve the associated value.
     * @return value The string value associated with the key.
     */
    function get(string memory k) public virtual returns(uint256 value){ // 9e c6 69 25
         return uint256(bytes32(Base.getByKey(bytes(k))));     
    }    

    /**
     * @notice Get the key based on it index.
     * @param idx The key to retrieve the associated index.
     * @return The key value associated with the index.
     */
    function keyAt(uint256 idx) public virtual returns(string memory) {    
        return string(Base.keyByIndex(idx));      
    }   

    /**
     * @notice Retrieves the value stored at the specified index.
     * @param idx The index of the element to retrieve.
     * @return value The value retrieved from the storage array at the given index.    
    */
    function valueAt(uint256 idx) public virtual returns(uint256 value){ // 9e c6 69 25
        return uint256(bytes32(Base.getByIndex(idx)));  
    }    

    /**
     * @notice Delete a key-value pair from the map.
     * @param k The string key to delete.
     */
    function del(string memory k) public { // 80 26 32 97
        Base.delByKey(bytes(k));  
    }
}