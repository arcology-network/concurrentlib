// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0 <0.9.0;

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
     * @param k The uint256 key to check for existence.
     * @return true if the key exists, false otherwise.
     */    
    function exist(uint256 k) public returns(bool) { 
        return Base.keyExists(abi.encodePacked(k)); 
    }

    /**
     * @notice Set a key-value pair in the map.
     * @param key The uint256 key to set.
     * @param value The uint256 value associated with the key.
     */
    function set(uint256 key, uint256 value) public { 
        Base.setByKey(abi.encodePacked(key), abi.encodePacked(value));       
    }

    /**
     * @notice Get the value associated with a given key in the map.
     * @param key The uint256 key to retrieve the associated value.
     * @return value The uint256 value associated with the key.
     */
    function get(uint256 key) public virtual returns(uint256 value){    
        return uint256(bytes32(Base.getByKey(abi.encodePacked(key))));
    }    

    /**
     * @notice Get the key based on it index.
     * @param idx The key to retrieve the associated index.
     * @return The index key associated with the index.
     */
    function keyAt(uint256 idx) public virtual returns(uint256) {    
        return uint256(bytes32(Base.keyByIndex(idx)));      
    }   

    /**
     * @notice Retrieves the value stored at the specified index.
     * @param idx The index of the element to retrieve.
     * @return value The value retrieved from the storage array at the given index.    
     */
    function valueAt(uint256 idx) public virtual returns(uint256 value){ 
        return  uint256(bytes32(Base.getByIndex(idx)));
    }  

    /**
     * @notice Delete a key-value pair from the map.
     * @param key The uint256 key to delete.
     */
    function del(uint256 key) public { 
        Base.delByKey((abi.encodePacked(key)));  
    }

    /**
     * @notice Retrieve the min value in the concurrent map.
     * @return The minimum element by numerical comparison.
     */
    function min() public returns(uint256, uint256, uint256) { 
        (uint256 idx, uint256 v) = abi.decode(Base.minNumerical(), (uint256, uint256));
        return (keyAt(idx), idx, v);
    }

    /**
     * @notice Retrieve the max value in the concurrent map.
     * @return The maximum value by numerical comparison.
     */
    function max() public returns(uint256, uint256, uint256) { 
        (uint256 idx, uint256 v) = abi.decode(Base.maxNumerical(), (uint256, uint256));
        return (keyAt(idx), idx, v);
    }
}