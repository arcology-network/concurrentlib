// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0;

import "../core/Const.sol";
import "../core/Primitive.sol";

/**
 * @author Arcology Network
 * @title AddressBytesMap Contract
 * @dev The AddressBytesMap contract provides a simple mapping structure to associate
 *      address keys with bytes values. It inherits from the "Base" contract
 *      to utilize container functionalities for key-value storage.
 */
contract AddressBytesMap is Base {
    constructor() Base(Const.BYTES, false) {}

    /**
     * @notice Check if a given key exists in the map.
     * @param k The address key to check for existence.
     * @return true if the key exists, false otherwise.
     */
    function exist(address k) public returns(bool) {
        return Base.exists(abi.encodePacked(k));
    }

    /**
     * @notice Set a key-value pair in the map.
     * @param key The address key to set.
     * @param value The bytes value to associate with the key.
     */
    function set(address key, bytes memory value) public {
        Base._set(abi.encodePacked(key), value);
    }

    /**
     * @notice Get the value associated with a given key in the map.
     * @param key The address key to retrieve the associated value.
     * @return value The bytes value associated with the key.
     */
    function get(address key) public virtual returns(bytes memory value) {
        (bool ifExist, bytes memory data) = Base._get(abi.encodePacked(key));
        if (ifExist)
            return data;
        else
            return "";
    }

    /**
     * @notice Get the key based on its index.
     * @param idx The index to retrieve the associated key.
     * @return The address key associated with the index.
     */
    function keyAt(uint256 idx) public virtual returns(address) {
        bytes memory rawdata = Base.indToKey(idx);
        bytes20 resultAdr;
        for (uint i = 0; i < 20; i++) {
            resultAdr |= bytes20(rawdata[i]) >> (i * 8);
        }
        return address(uint160(resultAdr));
    }

    /**
     * @notice Retrieves the value stored at the specified index.
     * @param idx The index of the element to retrieve.
     * @return value The bytes value retrieved from the storage array at the given index.
     */
    function valueAt(uint256 idx) public virtual returns(bytes memory value) {
        (bool ifExist, bytes memory data) = Base._get(idx);
        if (ifExist)
            return data;
        else
            return "";
    }

    /**
     * @notice Delete a key-value pair from the map.
     * @param key The address key to delete.
     */
    function del(address key) public returns(bool) {
        return Base._del(abi.encodePacked(key));
    }
}