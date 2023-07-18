// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.19;

import "../base/Base.sol";

/**
 * @title U256 Concurrent Array
 * @dev The U256 contract is a concurrent array specialized for storing uint256 data.
 *      It inherits from the Base contract to utilize container functionalities for uint256 storage.
 */
contract U256 is Base {
    constructor() {}

    /**
     * @notice Add a uint256 data element to the concurrent array.
     * @param elem The uint256 data element to add to the array.
     */
    function push(uint256 elem) public virtual{ //9e c6 69 25
       Base.setKey(uuid(), abi.encode(elem));
    }    

    /**
     * @notice Remove and return the last uint256 data element from the concurrent array.
     * @return The last uint256 data element from the array.
     */
    function pop() public virtual returns(uint256) { // 80 26 32 97
        return abi.decode(Base.popBack(), (uint256));  
    }

    /**
     * @notice Retrieve the uint256 data element at the given index from the concurrent array.
     * @param idx The index of the uint256 data element to retrieve.
     * @return The uint256 data element stored at the given index.
     */
    function get(uint256 idx) public virtual returns(uint256)  { // 31 fe 88 d0
        return abi.decode(Base.getIndex(idx), (uint256));  
    }

    /**
     * @notice Set the uint256 data element at the given index in the concurrent array.
     * @param idx The index where the uint256 data element should be stored.
     * @param elem The uint256 data element to be stored at the specified index.
     */
    function set(uint256 idx, uint256 elem) public { // 7a fa 62 38
        Base.setIndex(idx, abi.encode(elem));
    }
}
