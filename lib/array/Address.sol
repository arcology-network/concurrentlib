// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.19;

import "../base/Base.sol";

/**
 * @author Arcology Network
 * @title Address Concurrent Array
 * @dev The Address contract is a concurrent array specialized for storing addresses.
 *      It inherits from the Base contract to utilize container functionalities for address storage.
 */
contract Address is Base {
    constructor() {}

   /**
     * @notice Add an address element to the concurrent array.
     * @param elem The address element to add to the array.
     */
    function push(address elem) public virtual{ 
        Base.setByKey(uuid(), abi.encodePacked(elem));
    }    

   /**
     * @notice Remove and return the last address element from the concurrent array.
     * @return The last address element from the array.
     */
    function pop() public virtual returns(address) { 
        return address(uint160(bytes20(Base.popBack())));
    }

    /**
     * @notice Retrieve the address element at the given index from the concurrent array.
     * @param idx The index of the address element to retrieve.
     * @return The address element stored at the given index.
     */
    function get(uint256 idx) public virtual returns(address)  {
        return address(uint160(bytes20(Base.getByIndex(idx))));
    }

    /**
     * @notice Set the address element at the given index in the concurrent array.
     * @param idx The index where the address element should be stored.
     * @param elem The address element to be stored at the specified index.
     */
    function set(uint256 idx, address elem) public { 
        Base.setByIndex(idx, abi.encodePacked(elem));
    }
}

