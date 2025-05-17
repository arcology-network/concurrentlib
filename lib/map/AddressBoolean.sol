// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0;

import "../shared/Const.sol"; 
import "../shared/Base.sol";

/**
 * @author Arcology Network
 * @title AddressBooleanMap Contract
 * @dev The map contract provides a simple mapping structure to associate
 *      address keys with boolean values. It inherits from the "Base" contract
 *      to utilize container functionalities for key-value storage.
 */
contract AddressBooleanMap is Base { 
    constructor() Base(Const.BYTES) {}

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
        (bool success, bytes memory data) = Base._get(abi.encodePacked(k));
        if(success)
            return (abi.decode(data, (bool))); 
        else
            return false;   
    }   

    /**
     * @notice Get the key based on it index.
     * @param idx The key to retrieve the associated index.
     * @return The index key associated with the index.
     */
    function keyAt(uint256 idx) public virtual view returns(address) {    
        bytes memory rawdata=Base.indToKey(idx);
        bytes20 resultAdr;
        for (uint i = 0; i < 20; i++) {
            resultAdr |= bytes20(rawdata[i]) >> (i * 8); 
        }
        return address(uint160(resultAdr));  
    }   

    /**
     * @notice Retrieves the value stored at the specified index.
     * @param idx The index of the element to retrieve.
     * @return value The value retrieved from the storage array at the given index.    
    */
    function valueAt(uint256 idx) public virtual view returns(bool){ 
        (bool success,bytes memory data) = Base._get(idx);
        if(success)
            return abi.decode(data, (bool));  
        else
            return false;
    }    

    /**
     * @notice Delete a key-value pair from the map.
     * @param k The address key to delete.
     */
    function del(address k) public { 
        Base._del((abi.encodePacked(k)));  
    }
}