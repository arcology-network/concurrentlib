// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0 <0.9.0;

import "../base/Base.sol";

/**
 * @author Arcology Network
 * @title Bytes32 Concurrent Array
 * @dev The Bytes32 contract is a concurrent array specialized for storing bytes32 data.
 *      It inherits from the Base contract to utilize container functionalities for bytes32 storage.
 */
contract Bytes32 is Base {
    constructor() {}

    /**
     * @notice Add a bytes32 data element to the concurrent array.
     * @param elem The bytes32 data element to add to the array.
     */
    function push(bytes32 elem) public virtual{
        Base.setByKey(uuid(), abi.encodePacked(elem));
    }    

    /**
     * @notice Remove and return the last bytes32 data element from the concurrent array.
     * @return The last bytes32 data element from the array.
     */
    function pop() public virtual returns(bytes32) {
        return bytes32(Base.popBack());
    }

    /**
     * @notice Retrieve the bytes32 data element at the given index from the concurrent array.
     * @param idx The index of the bytes32 data element to retrieve.
     * @return The bytes32 data element stored at the given index.
     */
    function get(uint256 idx) public virtual returns(bytes32)  {
        return bytes32(Base.getByIndex(idx));
    }

    /**
     * @notice Set the bytes32 data element at the given index in the concurrent array.
     * @param idx The index where the bytes32 data element should be stored.
     * @param elem The bytes32 data element to be stored at the specified index.
     */
    function set(uint256 idx, bytes32 elem) public { 
        Base.setByIndex(idx, abi.encodePacked(elem));
    }

    /**
     * @notice Find the index of the address element in the concurrent array.
     * @param elem The element to be searched for.
     * @return The index of the firsting matching element in the array. If the element is not found, the function returns type(uint256).max.
     */
    function find(bytes32 elem, uint256 offset) public returns(uint256) { 
        for (uint256 i = offset; i < length(); i++)
        if (elem == get(i))
            return i;     
        return type(uint256).max;
     }
}
