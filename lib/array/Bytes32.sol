// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0;

import "../shared/Const.sol"; 
import "../shared/Base.sol";

/**
 * @author Arcology Network
 * @title Bytes32 Concurrent Array
 * @dev The Bytes32 contract is a concurrent array specialized for storing bytes32 data.
 *      It inherits from the Base contract to utilize container functionalities for bytes32 storage.
 */
contract Bytes32 is Base {
    constructor(bool isBlockBound) Base(Const.BYTES, isBlockBound){}

    /**
     * @notice Add a bytes32 data element to the concurrent array.
     * @param elem The bytes32 data element to add to the array.
     */
    function push(bytes32 elem) public virtual{
        Base._set(uuid(), abi.encodePacked(elem));
    }    

    /**
     * @notice Remove and return the last bytes32 data element from the concurrent array.
     * @return The last bytes32 data element from the array.
     */
    function delLast() public virtual returns(bytes32) {
        return abi.decode(Base._delLast(), (bytes32));
    }

    /**
     * @notice Retrieve the bytes32 data element at the given index from the concurrent array.
     * @param idx The index of the bytes32 data element to retrieve.
     * @return The bytes32 data element stored at the given index.
     */
    function get(uint256 idx) public virtual returns(bytes32)  {
        (bool exist,bytes memory data)=Base._get(idx);
        if(exist)
            return abi.decode(data, (bytes32));
        else{
            bytes32 defaultVal;
            return defaultVal;
        }
    }

    /**
     * @notice Set the bytes32 data element at the given index in the concurrent array.
     * @param idx The index where the bytes32 data element should be stored.
     * @param elem The bytes32 data element to be stored at the specified index.
     */
    function set(uint256 idx, bytes32 elem) public { 
        Base._set(idx, abi.encodePacked(elem));
    }
}
