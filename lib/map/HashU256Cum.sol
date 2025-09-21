// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0;

import "../core/Const.sol"; 
import "../core/Primitive.sol";

/**
 * @author Arcology Network
 * @title HashU256Map Contract
 * @dev The HashU256Map contract provides a simple mapping structure to associate
 *      uint256 keys with uint256 values. It inherits from the "Base" contract
 *      to utilize container functionalities for key-value storage.
 */
contract HashU256Map is Base { 
    constructor() Base(Const.U256_CUM, false) {}

    /**
     * @notice Check if a given key exists in the map.
     * @param k The uint256 key to check for existence.
     * @return true if the key exists, false otherwise.
     */    
    function exist(bytes32 k) public returns(bool) { 
        return Base.exists(abi.encodePacked(k)); 
    }
    
    /**
     * @notice Set a NEW key-value pair in the map. If absent, it creates a new one. If exists and bounds match, it adds; else, it fails.
     * @param key The uint256 key to set.
     * @param value The uint256 value associated with the key.
     *  @param lower The uint256 value associated with the key.
     *  @param upper The uint256 value associated with the key.
     */
    function set(bytes32 key, uint256 value, uint256 lower, uint256 upper) public { 
        require((value < 0  && uint256(value) <= lower) || value >= 0 && uint256(value) >= lower && uint256(value) <= upper, "Out of bounds");
 
        if (!_init(abi.encodePacked(key), abi.encodePacked(lower), abi.encodePacked(upper))) {
            return ;
        }
        set(key, int256(value));
    } 

    /**
     * @notice Set a key-value pair in the map.
     * @param key The uint256 key to set.
     * @param delta The uint256 value associated with the key.
     */
    function set(bytes32 key, int256 delta) public { 
        Base._set(abi.encodePacked(key), abi.encodePacked(delta));       
    }

    /**
     * @notice Get the value associated with a given key in the map.
     * @param key The uint256 key to retrieve the associated value.
     * @return value The uint256 value associated with the key.
     */
    function get(bytes32 key) public returns(uint256 value){   
        (bool exist,bytes memory data)=Base._get(abi.encodePacked(key));
        if(exist)
            return uint256(abi.decode(data,(bytes32)));
        else
            return uint256(0);
    }    

    /**
     * @notice Get the key based on it index.
     * @param idx The key to retrieve the associated index.
     * @return The index key associated with the index.
     */
    function keyAt(uint256 idx) public returns(bytes32) {   
        bytes memory rawdata=Base.indToKey(idx);
        bytes32 resultAdr;
        for (uint i = 0; i < 20; i++) {
            resultAdr |= bytes32(rawdata[i]) >> (i * 8); 
        }
        return resultAdr;         
    }   

    /**
     * @notice Retrieves the value stored at the specified index.
     * @param idx The index of the element to retrieve.
     * @return value The value retrieved from the storage array at the given index.    
     */
    function valueAt(uint256 idx) public returns(uint256 value){ 
        (bool exist,bytes memory data)=Base._get(idx);
        if(exist)
            return uint256(abi.decode(data, (bytes32)));
        else
            return uint256(0);
    }  

    /**
     * @notice Delete a key-value pair from the map.
     * @param key The uint256 key to delete.
     */
    function del(bytes32 key) public returns(bool){ 
        return Base._del(abi.encodePacked(key));  
    }

    /**
     * @notice Retrieve the min value in the concurrent map.
     * @return The minimum element by numerical comparison.
     */
    function min() public  returns(bytes32, uint256, uint256) { 
        (uint256 idx, uint256 v) = abi.decode(Base._min(), (uint256, uint256));
        return (keyAt(idx), idx, v);
    }
    
    /**
     * @notice Retrieve the max value in the concurrent map.
     * @return The maximum value by numerical comparison.
     */
    function max() public returns(bytes32, uint256, uint256) { 
        (uint256 idx, uint256 v) = abi.decode(Base._max(), (uint256, uint256));
        return (keyAt(idx), idx, v);
    }
}