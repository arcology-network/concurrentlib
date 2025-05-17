// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0;

import "../shared/Const.sol"; 
import "../shared/Base.sol";

/**
 * @author Arcology Network
 * @title String Concurrent Array
 * @dev The String contract is a concurrent array specialized for storing string data.
 *      It inherits from the Base contract to utilize container functionalities for string storage.
 */
contract String is Base {
    constructor() Base(Const.BYTES) {}

    /**
     * @notice Add a string data element to the concurrent array.
     * @param elem The string data element to add to the array.
     */
    function push(string memory elem) public virtual{
         Base._set(uuid(), bytes(elem));
    }    

    /**
     * @notice Remove and return the last string data element from the concurrent array.
     * @return The last string data element from the array.
     */
    function delLast() public virtual returns(string memory) {
        return string(Base._delLast());
    }

    /**
     * @notice Retrieve the string data element at the given index from the concurrent array.
     * @param idx The index of the string data element to retrieve.
     * @return The string data element stored at the given index.
     */
    function get(uint256 idx) public virtual view returns(string memory)  {
        (bool exist,bytes memory data) = Base._get(idx);
        if(exist)
            return string(data);
        else
            return string("");
    }

    /**
     * @notice Set the string data element at the given index in the concurrent array.
     * @param idx The index where the string data element should be stored.
     * @param elem The string data element to be stored at the specified index.
     */
    function set(uint256 idx, string memory elem) public { 
        Base._set(idx, bytes(elem));
    }
}
