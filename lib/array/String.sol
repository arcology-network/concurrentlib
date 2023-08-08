// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.19;

import "../base/Base.sol";

/**
 * @author Arcology Network
 * @title String Concurrent Array
 * @dev The String contract is a concurrent array specialized for storing string data.
 *      It inherits from the Base contract to utilize container functionalities for string storage.
 */
contract String is Base {
    constructor() {}

    /**
     * @notice Add a string data element to the concurrent array.
     * @param elem The string data element to add to the array.
     */
    function push(string memory elem) public virtual{ //9e c6 69 25
         Base.setByKey(uuid(), bytes(elem));
    }    

    /**
     * @notice Remove and return the last string data element from the concurrent array.
     * @return The last string data element from the array.
     */
    function pop() public virtual returns(string memory) { // 80 26 32 97
        return string(Base.popBack());
    }

    /**
     * @notice Retrieve the string data element at the given index from the concurrent array.
     * @param idx The index of the string data element to retrieve.
     * @return The string data element stored at the given index.
     */
    function get(uint256 idx) public virtual returns(string memory)  { // 31 fe 88 d0
        return string(Base.getByIndex(idx));
    }

    /**
     * @notice Set the string data element at the given index in the concurrent array.
     * @param idx The index where the string data element should be stored.
     * @param elem The string data element to be stored at the specified index.
     */
    function set(uint256 idx, string memory elem) public { // 7a fa 62 38
        Base.setByIndex(idx, bytes(elem));
    }
}
