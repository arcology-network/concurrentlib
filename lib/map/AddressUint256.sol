// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0;

import "../shared/Const.sol"; 
import "../shared/Base.sol";

/**
 * @author Arcology Network
 * @title AddressUint256Map Contract
 * @dev The map contract provides a simple mapping structure to associate
 *      address keys with uint256 values. It inherits from the "Base" contract
 *      to utilize container functionalities for key-value storage.
 */
contract AddressUint256Map is Base { 
    constructor() Base(Const.BYTES) {}

    /**
     * @notice Check if a given key exists in the map.
     * @param k The address key to check for existence.
     * @return true if the key exists, false otherwise.
     */
    function exist(address k) public virtual returns(bool) { 
        return Base._exists(abi.encodePacked(k));
    }

    /**
     * @notice Set a key-value pair in the map.
     * @param k The address key to set.
     * @param value The address value associated with the key.
     */
    function set(address k, uint256 value) public { 
        Base._set(abi.encodePacked(k), abi.encodePacked(value));       
    }

    /**
     * @notice Get the value associated with a given key in the map.
     * @param k The address key to retrieve the associated value.
     * @return value The address value associated with the key.
     */
    function get(address k) public virtual returns(uint256 value){ 
        (bool exist,bytes memory data)=Base._get(abi.encodePacked(k));
        if(exist)
            return uint256(abi.decode(data, (bytes32)));     
        else
            return uint256(0);
    }    

    /**
     * @notice Get the key based on it index.
     * @param idx The key to retrieve the associated index.
     * @return The key value associated with the index.
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
    function valueAt(uint256 idx) public virtual view returns(uint256 value){ 
        (bool exist,bytes memory data)=Base._get(idx);
        if(exist)
            return uint256(abi.decode(data, (bytes32)) ); 
        else
            return uint256(0); 
    }    

    /**
     * @notice Set the element to its intial value.
     * @param k The key of the element to retrieve.
     * @return true if the value has been reset, false otherwise.    
    */
    function resetByKey(address k) public returns(bool) {
       return Base._resetByKey(abi.encodePacked(k)); 
    }

    /**
     * @notice Delete a key-value pair from the map.
     * @param k The address key to delete.
     */
    function del(address k) public { 
        Base._del(abi.encodePacked(k));  
    }

    /**
     * @notice Retrieve the min value in the map.
     * @return The minimum element by numerical comparison.
     */
    function min() public view returns(address, uint256, uint256) { 
        (uint256 idx, uint256 v) =  abi.decode(Base.minNumerical(), (uint256, uint256));
        return (keyAt(idx),idx, v);
    }
    
    /**
     * @notice Retrieve the max value in the map.
     * @return The maximum value by numerical comparison.
     */
    function max() public view returns(address, uint256, uint256) { 
         (uint256 idx, uint256 v)  = abi.decode(Base.maxNumerical(), (uint256, uint256));
        return (keyAt(idx), idx, v);
    }
}