// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0 <0.9.0;


import "../shared/Const.sol"; 
import "../shared/Base.sol";

/**
 * @author Arcology Network
 * @title Int256 Concurrent Array
 * @dev The Int256 contract is a concurrent array specialized for storing int256 data.
 *      It inherits from the Base contract to utilize container functionalities for int256 storage.
 */
contract Int256 is Base {
    constructor() Base(Const.BYTES) {}

    /**
     * @notice Add an int256 data element to the concurrent array.
     * @param elem The int256 data element to add to the array.
     */
    function push(int256 elem) public virtual{ 
        Base._set(uuid(), abi.encodePacked(elem));
    }    

    /**
     * @notice Remove and return the last int256 data element from the concurrent array.
     * @return The last int256 data element from the array.
     */
    function delLast() public virtual returns(int256) { 
        return abi.decode(Base._delLast(), (int256));  
    }

    /**
     * @notice Retrieve the int256 data element at the given index from the concurrent array.
     * @param idx The index of the int256 data element to retrieve.
     * @return The int256 data element stored at the given index.
     */
    function get(uint256 idx) public virtual view returns(int256)  {
        (,bytes memory data) = Base._get(idx);
        return abi.decode(data, (int256));  
    }

    /**
     * @notice Set the int256 data element at the given index in the concurrent array.
     * @param idx The index where the int256 data element should be stored.
     * @param elem The int256 data element to be stored at the specified index.
     */
    function set(uint256 idx, int256 elem) public returns(bool) { 
       return Base._set(idx, abi.encodePacked(elem));  
    }
}
