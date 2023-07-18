// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.19;

import "../base/Base.sol";

/**
 * @title Bool Concurrent Array
 * @dev The Bool contract is a concurrent array specialized for storing boolean values.
 *      It inherits from the Base contract to utilize container functionalities for boolean storage.
 */
contract Bool is Base {
    constructor() {}

    /**
     * @notice Add a boolean element to the concurrent array.
     * @param elem The boolean element to add to the array.
     */
    function push(bool elem) public virtual { //9e c6 69 25
        Base.setByKey(uuid(), abi.encode(elem));
    }    

    /**
     * @notice Remove and return the last boolean element from the concurrent array.
     * @return The last boolean element from the array.
     */
    function pop() public virtual returns(bool) { // 80 26 32 97
        return abi.decode(Base.popBack(), (bool));  
    }

    /**
     * @notice Retrieve the boolean element at the given index from the concurrent array.
     * @param idx The index of the boolean element to retrieve.
     * @return The boolean element stored at the given index.
     */
    function get(uint256 idx) public virtual  returns(bool)  { // 31 fe 88 d0
        return abi.decode(Base.getByIndex(idx), (bool));  
    }

    /**
     * @notice Set the boolean element at the given index in the concurrent array.
     * @param idx The index where the boolean element should be stored.
     * @param elem The boolean element to be stored at the specified index.
     */
    function set(uint256 idx, bool elem) public { // 7a fa 62 38
        Base.setByIndex(idx, abi.encode(elem));    
    }
}
