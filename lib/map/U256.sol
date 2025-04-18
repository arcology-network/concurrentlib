// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0;

import "../shared/Const.sol"; 
import "../shared/Base.sol";

/**
 * @author Arcology Network
 * @title U256U256Map Contract
 * @dev The U256U256Map contract provides a simple mapping structure to associate
 *      uint256 keys with uint256 values. It inherits from the "Base" contract
 *      to utilize container functionalities for key-value storage.
 */
contract U256Map is Base { 
    constructor() Base(Const.BYTES) {}

    /**
     * @notice Check if a given key exists in the map.
     * @param k The uint256 key to check for existence.
     * @return true if the key exists, false otherwise.
     */    
    function exist(uint256 k) public view returns(bool) { 
        return Base._exists(abi.encodePacked(k)); 
    }

    /**
     * @notice Set a key-value pair in the map.
     * @param key The uint256 key to set.
     * @param value The uint256 value associated with the key.
     */
    function set(uint256 key, uint256 value) public { 
        Base._set(abi.encodePacked(key), abi.encodePacked(value));       
    }

    /**
     * @notice Get the value associated with a given key in the map.
     * @param key The uint256 key to retrieve the associated value.
     * @return value The uint256 value associated with the key.
     */
    function get(uint256 key) public virtual view returns(uint256 value){   
        return uint256(abi.decode(Base._get(abi.encodePacked(key)), (bytes32)));
    }    

    /**
     * @notice Get the key based on it index.
     * @param idx The key to retrieve the associated index.
     * @return The index key associated with the index.
     */
    function keyAt(uint256 idx) public virtual view returns(uint256) {  
        return uint256(abi.decode(Base.indToKey(idx), (bytes32)) );      
    }   

    /**
     * @notice Retrieves the value stored at the specified index.
     * @param idx The index of the element to retrieve.
     * @return value The value retrieved from the storage array at the given index.    
     */
    function valueAt(uint256 idx) public virtual view returns(uint256 value){ 
        return  uint256(abi.decode(Base._get(idx), (bytes32)));
    }  

    /**
     * @notice Delete a key-value pair from the map.
     * @param key The uint256 key to delete.
     */
    function del(uint256 key) public { 
        Base._del((abi.encodePacked(key)));  
    }

    /**
     * @notice Retrieve the min value in the concurrent map.
     * @return The minimum element by numerical comparison.
     */
    function min() public view returns(uint256, uint256, uint256) { 
        (uint256 idx, uint256 v) = abi.decode(Base.minNumerical(), (uint256, uint256));
        return (keyAt(idx), idx, v);
    }

    /**
     * @notice Retrieve the max value in the concurrent map.
     * @return The maximum value by numerical comparison.
     */
    function max() public view returns(uint256, uint256, uint256) { 
        (uint256 idx, uint256 v) = abi.decode(Base.maxNumerical(), (uint256, uint256));
        return (keyAt(idx), idx, v);
    }
}