// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0 <0.9.0;

import "../shared/Const.sol";
import "../runtime/Runtime.sol";

/**
 * @author Arcology Network
 * @title BytesOrderedSet Concurrent Container
 * @dev The BytesOrderedSet contract is a concurrent container designed for concurrent operations,
 *      allowing elements to be added in different processes running in parallel without
 *      causing state conflicts. It provides functionalities for both key-value lookup and
 *      linear access.
 *
 *      The contract serves as a hybrid data structure, functioning as a map set behind the scenes.
 *      The order of elements is formed when any timing-dependent functions like "pop()" or "nonNilCount()"
 *      are called. However, performing concurrent "pop()" or getting the length is not recommended in
 *      a parallel environment, as these operations are timing-independent and may lead to conflicts. 
 *      Transactions resulting conflicts will be reverted to protect the state consistency.
 *
 *      Delopers should exercise caution when accessing the container concurrently to avoid conflicts.
 */
contract BytesOrderedSet {
    address internal API = address(0x84);
    
    /**
     * @notice Constructor to initiate communication with the external contract.
     */
    constructor () {       
        (bool success,) = address(API).call(abi.encodeWithSignature(
            "new(uint8,bytes,bytes)", uint8(Const.BYTES), new bytes(0), new bytes(0)));
        require(success);
    }
    
    /**
     * @notice Retrieve the data at the given index from the container.
     * @param idx The index of the data to retrieve.
     * @return The data stored at the specified index.
     */
    function _get(uint256 idx) public virtual view returns(bytes memory) {
        // (,bytes memory key) = address(API).staticcall(abi.encodeWithSignature("keyByIndex(uint256)", idx)); 
        // if (key.length == 0) {
        //     return new bytes(0);
        // }
        // // return this._get(key);
        // (,bytes memory data) = address(API).staticcall(abi.encodeWithSignature("getByKey(bytes)", key));
        // return data;
        (,bytes memory elem) = address(API).staticcall(abi.encodeWithSignature("getByIndex(uint256)", idx)); 
        return elem;
    }
         
    /**
     * @notice Retrieve the length of the container, including newly appended and deleted values if any.
     * @return The length of the container.
     */
    function Length() public view returns(uint256) {
        (,bytes memory data) = address(API).staticcall(abi.encodeWithSignature("fullLength()"));
        return abi.decode(data, (uint256));
    }  
  
    /**
     * @notice Checks if a key exists in the the data structure. *
     * @param elem The elem to check for existence.
     * @return A boolean indicating whether the key exists in it or not.
    */
    function exists(bytes memory elem) public view returns(bool) {
        (bool success,) = address(API).staticcall(abi.encodeWithSignature("getByKey(bytes)", elem));
        return success;
    }

    /**
     * @notice Set the data associated with the given key in the container.
     * @param elem The data to be stored.
     * @return success true if the data was successfully updated, false otherwise.
     */
    function set(bytes memory elem) public returns(bool) {
        bytes memory key = Runtime.uuid();
        (bool success,) = address(API).call(abi.encodeWithSignature("setByKey(bytes,bytes)", key, elem));
        return success;   
    }

    /**
     * @notice Clear all data stored.
     * @return success true if the all the data was successfully deleted, false otherwise.
     */
    function clear() public returns(bool)  {
        (bool success,) = address(API).call(abi.encodeWithSignature("clear()"));
        return success;       
    }  
}