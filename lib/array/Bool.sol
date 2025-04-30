// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0 <0.9.0;

import "../shared/Const.sol"; 
import "../shared/Base.sol";

/** 
 * @author Arcology Network
 * @title Bool Concurrent Array
 * @dev The Bool contract is a concurrent array specialized for storing boolean values.
 *      It inherits from the Base contract to utilize container functionalities for boolean storage.
 */
contract Bool is Base {
    constructor() Base(Const.BYTES) {}

    /**
     * @notice Add a boolean element to the concurrent array.
     * @param elem The boolean element to add to the array.
     */
    function push(bool elem) public virtual { 
        Base._set(uuid(), abi.encode(elem));
    }    

    /**
     * @notice Remove and return the last boolean element from the concurrent array.
     * @return The last boolean element from the array.
     */
    function delLast() public virtual returns(bool) { 
        return abi.decode(Base._delLast(), (bool));  
    }

    /**
     * @notice Retrieve the boolean element at the given index from the concurrent array.
     * @param idx The index of the boolean element to retrieve.
     * @return The boolean element stored at the given index.
     */
    function get(uint256 idx) public virtual returns(bool)  {
        (,bytes memory data) = Base._get(idx);
        return abi.decode(data, (bool));  
    }

    /**
     * @notice Set the boolean element at the given index in the concurrent array.
     * @param idx The index where the boolean element should be stored.
     * @param elem The boolean element to be stored at the specified index.
     */
    function set(uint256 idx, bool elem) public { 
        Base._set(idx, abi.encode(elem));    
    }
}
