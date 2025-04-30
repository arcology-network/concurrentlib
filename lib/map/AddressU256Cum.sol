// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0 <0.9.0;

import "../shared/Const.sol"; 
import "../shared/Base.sol";

/**
 * @author Arcology Network
 * @title U256U256Map Contract
 * @dev The U256U256Map contract provides a simple mapping structure to associate
 *      uint256 keys with uint256 values. It inherits from the "Base" contract
 *      to utilize container functionalities for key-value storage.
 */
contract AddressU256CumMap is Base { 
    constructor() Base(Const.U256_CUM) {}

    /**
     * @notice Check if a given key exists in the map.
     * @param k The uint256 key to check for existence.
     * @return true if the key exists, false otherwise.
     */    
    function exist(address k) public view returns(bool) { 
        return Base.exists(abi.encodePacked(k)); 
    }
     
    /**
     * @notice Set a NEW key-value pair in the map. If absent, it creates a new one. If exists and bounds match, it adds; else, it fails.
     * @param key The new uint256 key to set.
     * @param initDelta The initial delta value associated with the key.
     *  @param lower The lower bound associated with the key.
     *  @param upper The upper bound associated with the key.
     */
    function set(address key, int256 initDelta, uint256 lower, uint256 upper) public  { 
        require((initDelta < 0  && uint256(initDelta) <= lower) || initDelta >= 0 && uint256(initDelta) >= lower && uint256(initDelta) <= upper, "Out of bounds");

        if (!_init(abi.encodePacked(key), abi.encodePacked(lower), abi.encodePacked(upper))) {
            return ;
        }
        set(key, int256(initDelta));
    } 

    /**
     * @notice Set a key-value pair in the map.
     * @param key The uint256 key to set.
     * @param delta The uint256 value associated with the key.
     */
    function set(address key, int256 delta) public { 
        Base._set(abi.encodePacked(key), abi.encodePacked(delta));       
    }

    /**
     * @notice Get the value associated with a given key in the map.
     * @param key The uint256 key to retrieve the associated value.
     * @return value The uint256 value associated with the key.
     */
    function get(address key) public virtual view returns(uint256 value){    
        (, bytes memory data) = Base._get(abi.encodePacked(key));
        return uint256(bytes32(data));
    }    

    /**
     * @notice Get the key based on it index.
     * @param idx The key to retrieve the associated index.
     * @return The index key associated with the index.
     */
    function keyAt(uint256 idx) public virtual view returns(address) {    
        return address(uint160(bytes20(indToKey(idx))));           
    }   

    /**
     * @notice Retrieves the value stored at the specified index.
     * @param idx The index of the element to retrieve.
     * @return value The value retrieved from the storage array at the given index.    
     */
    function valueAt(uint256 idx) public virtual view returns(uint256 value){ 
        (,bytes memory data) = Base._get(abi.encodePacked(idx));
        return uint256(bytes32(data));
    }  

    /**
     * @notice Delete a key-value pair from the map.
     * @param key The uint256 key to delete.
     */
    function del(address key) public returns(bool){ 
        return Base._del(abi.encodePacked(key));  
    }

    /**
     * @notice Retrieve the min value in the concurrent map.
     * @return The minimum element by numerical comparison.
     */
    function min() public view returns(address, uint256, uint256) { 
        (uint256 idx, uint256 v) = abi.decode(Base.minNumerical(), (uint256, uint256));
        return (keyAt(idx), idx, v);
    }

    /**
     * @notice Retrieve the max value in the concurrent map.
     * @return The maximum value by numerical comparison.
     */
    function max() public view returns(address, uint256, uint256) { 
        (uint256 idx, uint256 v) = abi.decode(Base.maxNumerical(), (uint256, uint256));
        return (keyAt(idx), idx, v);
    }
}