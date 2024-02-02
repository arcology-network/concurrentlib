// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.19;

import "../base/Base.sol";

/**
 * @author Arcology Network
 * @title Bytes Concurrent Array
 * @dev The Bytes contract is a concurrent array specialized for storing bytes data.
 *      It inherits from the Base contract to utilize container functionalities for bytes storage.
 */
contract Bytes is Base {
    constructor() {}

    /**
     * @notice Add a bytes data element to the concurrent array.
     * @param elem The bytes data element to add to the array.
     */
    function push(bytes memory elem) public virtual { 
        Base.setByKey(uuid(), (elem));
    }    

    /**
     * @notice Remove and return the last bytes data element from the concurrent array.
     * @return The last bytes data element from the array.
     */
    function pop() public virtual returns(bytes memory) { 
        return Base.popBack();  
    }

    /**
     * @notice Retrieve the bytes data element at the given index from the concurrent array.
     * @param idx The index of the bytes data element to retrieve.
     * @return The bytes data element stored at the given index.
     */
    function get(uint256 idx) public virtual returns(bytes memory)  { 
        return Base.getByIndex(idx);  
    }

    /**
     * @notice Set the bytes data element at the given index in the concurrent array.
     * @param idx The index where the bytes data element should be stored.
     * @param elem The bytes data element to be stored at the specified index.
     */
    function set(uint256 idx, bytes memory elem) public { 
        Base.setByIndex(idx, (elem));
    }   
}
