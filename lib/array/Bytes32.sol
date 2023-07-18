// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.19;

import "../base/Base.sol";

/**
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
    function push(bytes32 elem) public virtual{ //9e c6 69 25
        Base.setByKey(uuid(), abi.encode(elem));
    }    

    /**
     * @notice Remove and return the last bytes32 data element from the concurrent array.
     * @return The last bytes32 data element from the array.
     */
    function pop() public virtual returns(bytes32) { // 80 26 32 97
        return abi.decode(Base.popBack(), (bytes32));  
    }

    /**
     * @notice Retrieve the bytes32 data element at the given index from the concurrent array.
     * @param idx The index of the bytes32 data element to retrieve.
     * @return The bytes32 data element stored at the given index.
     */
    function get(uint256 idx) public virtual returns(bytes32)  { // 31 fe 88 d0
        return abi.decode(Base.getByIndex(idx), (bytes32));  
    }

    /**
     * @notice Set the bytes32 data element at the given index in the concurrent array.
     * @param idx The index where the bytes32 data element should be stored.
     * @param elem The bytes32 data element to be stored at the specified index.
     */
    function set(uint256 idx, bytes32 elem) public { // 7a fa 62 38
        Base.setByIndex(idx, abi.encode(elem));
    }
}
