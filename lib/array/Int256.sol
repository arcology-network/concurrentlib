// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0 <0.9.0;


import "../base/Base.sol";

/**
 * @author Arcology Network
 * @title Int256 Concurrent Array
 * @dev The Int256 contract is a concurrent array specialized for storing int256 data.
 *      It inherits from the Base contract to utilize container functionalities for int256 storage.
 */
contract Int256 is Base {
    constructor() {}

    /**
     * @notice Add an int256 data element to the concurrent array.
     * @param elem The int256 data element to add to the array.
     */
    function push(int256 elem) public virtual{ 
        Base.setByKey(uuid(), abi.encodePacked(elem));
    }    

    /**
     * @notice Remove and return the last int256 data element from the concurrent array.
     * @return The last int256 data element from the array.
     */
    function pop() public virtual returns(int256) { 
        return abi.decode(Base.popBack(), (int256));  
    }

    /**
     * @notice Retrieve the int256 data element at the given index from the concurrent array.
     * @param idx The index of the int256 data element to retrieve.
     * @return The int256 data element stored at the given index.
     */
    function get(uint256 idx) public virtual returns(int256)  {
        return abi.decode(Base.getByIndex(idx), (int256));  
    }

    /**
     * @notice Set the int256 data element at the given index in the concurrent array.
     * @param idx The index where the int256 data element should be stored.
     * @param elem The int256 data element to be stored at the specified index.
     */
    function set(uint256 idx, int256 elem) public { 
        Base.setByIndex(idx, abi.encodePacked(elem));  
    }

    /**
     * @notice Find the index of the address element in the concurrent array.
     * @param elem The element to be searched for.
     * @return The index of the firsting matching element in the array. If the element is not found, the function returns type(uint256).max.
     */
    function find(int256 elem, uint256 offset) public returns(uint256) { 
        for (uint256 i = offset; i < length(); i++)
            if (elem == get(i))
                return i;     
        return type(uint256).max;
    }

    // /**
    //  * @notice Retrieve the min element in the concurrent array.
    //  * @return The minimum element in the array by numerical comparison.
    //  */
    // function min() public returns(int256, int256) { 
    //     return abi.decode(Base.minNumerical(), (int256, int256));
    // }

    // /**
    //  * @notice Retrieve the max element in the concurrent array.
    //  * @return The maximum value in the array by numerical comparison.
    //  */
    // function max() public returns(int256, int256) { 
    //     return abi.decode(Base.maxNumerical(), (int256));
    // }
}
