// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0;

import "../shared/Const.sol"; 
import "../shared/Base.sol";

/**
 * @author Arcology Network
 * @title Bytes Concurrent Array
 * @dev The Bytes contract is a concurrent array specialized for storing bytes data.
 *      It inherits from the Base contract to utilize container functionalities for bytes storage.
 */
contract Bytes is Base {
    constructor() Base(Const.BYTES) {}

    /**
     * @notice Add a bytes data element to the concurrent array.
     * @param elem The bytes data element to add to the array.
     */
    function push(bytes memory elem) public virtual { 
        Base._set(uuid(), (elem));
    }    

    /**
     * @notice Remove and return the last bytes data element from the concurrent array.
     * @return The last bytes data element from the array.
     */
    function pop() public virtual returns(bytes memory) { 
        return Base._pop();  
    }

    /**
     * @notice Retrieve the bytes data element at the given index from the concurrent array.
     * @param idx The index of the bytes data element to retrieve.
     * @return The bytes data element stored at the given index.
     */
    function get(uint256 idx) public virtual view returns(bytes memory)  { 
        return Base._get(idx);  
    }

    /**
     * @notice Set the bytes data element at the given index in the concurrent array.
     * @param idx The index where the bytes data element should be stored.
     * @param elem The bytes data element to be stored at the specified index.
     */
    function set(uint256 idx, bytes memory elem) public { 
        Base._set(idx, (elem));
    }
    
    /**
     * @notice Find the index of the address element in the concurrent array.
     * @param elem The element to be searched for.
     * @return The index of the firsting matching element in the array. If the element is not found, the function returns type(uint256).max.
     */
    function find(bytes memory elem, uint256 offset) public view returns(uint256) { 
        for (uint256 i = offset; i < nonNilCount(); i++)
            if (keccak256(elem) == keccak256(get(i)))
                return i;     
        return type(uint256).max;   
     }
}
