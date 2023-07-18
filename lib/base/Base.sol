// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.19;
import "../runtime/Runtime.sol";

/**
 * @title Base Concurrent Container
 * @dev The Base contract is a concurrent container designed for concurrent operations,
 *      allowing elements to be added in different processes running in parallel without
 *      causing state conflicts. It provides functionalities for both key-value lookup and
 *      linear access.
 *
 *      The contract serves as a hybrid data structure, functioning as a map set behind the scenes.
 *      The order of elements is formed when any timing-dependent functions like "pop()" or "length()"
 *      are called. However, performing concurrent "pop()" or getting the length is not recommended in
 *      a parallel environment, as these operations are timing-independent and may lead to conflicts. 
 *      Transactions resulting conflicts will be reverted to protect the state consistency.
 *
 *      Delopers should exercise caution when accessing the container concurrently to avoid conflicts.
 */
contract Base is Runtime {
    address internal API = address(0x84);

    /**
     * @notice Constructor to initiate communication with the external contract.
     */
    constructor () {
        (bool success,) = address(API).call(abi.encodeWithSignature("new()", true));
        require(success);
    }

    /**
     * @notice Retrieve the length of the container.
     * @return The length of the container.
     */
    function length() public returns(uint256) {
        (bool success, bytes memory data) = address(API).call(abi.encodeWithSignature("length()"));
        require(success);
        return abi.decode(data, (uint256));
    }

    /**
     * @notice Retrieve the committed length of the container. This usually is the length at the previous block height.
     * @return The latest committed length of the container. This is function is thread-safe.
     */
    function peek() public returns(bytes memory) {
        (bool success, bytes memory data) = address(API).call(abi.encodeWithSignature("peek()"));
        require(success);
        return data;  
    }

    /**
     * @notice Removes and returns the last element of the container.
     * @return The data of the removed element.
     */
    function popBack() public virtual returns(bytes memory) {
        bytes memory v = getIndex(length() - 1);
        delIndex(length() - 1);
        return v;
    }

    /**
     * @notice Set the data at the given index in the container.
     * @param idx The index where the data should be stored.
     * @param encoded The data to be stored.
     * @return success true if the data was successfully updated, false otherwise.
     */
    function setIndex(uint256 idx, bytes memory encoded) public returns(bool) {
        (bool success,) = address(API).call(abi.encodeWithSignature("setIndex(uint256,bytes)", idx, encoded));   
        return success;     
    }

    /**
     * @notice Set the data associated with the given key in the container.
     * @param key The key associated with the data.
     * @param elem The data to be stored.
     * @return success true if the data was successfully updated, false otherwise.
     */
    function setKey(bytes memory key, bytes memory elem) public returns(bool) {
        (bool success,) = address(API).call(abi.encodeWithSignature("setKey(bytes,bytes)", key, elem));
        return success;   
    }

    /**
     * @notice Delete the data at the given index in the container.
     * @param idx The index of the data to be deleted.
     * @return success true if the data was successfully deleted, false otherwise.
     */
    function delIndex(uint256 idx) public returns(bool) {
        (bool success,) = address(API).call(abi.encodeWithSignature("delIndex(uint256)", idx));  
        return success;   
    }

    /**
     * @notice Delete the data associated with the given key from the container.
     * @param key The key associated with the data to be deleted.
     * @return success true if the data was successfully deleted, false otherwise.
     */
    function delKey(bytes memory key) public returns(bool) {
       (bool success,) = address(API).call(abi.encodeWithSignature("delKey(bytes)", key));
       return success;
    }

    /**
     * @notice Retrieve the data at the given index from the container.
     * @param idx The index of the data to retrieve.
     * @return The data stored at the specified index.
     */
    function getIndex(uint256 idx) public virtual returns(bytes memory) {
        (bool success, bytes memory data) = address(API).call(abi.encodeWithSignature("getIndex(uint256)", idx));
        if (success) {
            return abi.decode(data, (bytes));  
        }
        return data;
    }

    /**
     * @notice Retrieve the data associated with the given key from the container.
     * @param key The key associated with the data to retrieve.
     * @return The data stored at the specified key.
     */
    function getKey(bytes memory key) public returns(bytes memory)  {
        (bool success, bytes memory data) = address(API).call(abi.encodeWithSignature("getKey(bytes)", key));
        if (success) {
            return abi.decode(data, (bytes));  
        }
        return data;
    }

    /**
     * @notice Clear all data stored.
     * @return success true if the all the data was successfully deleted, false otherwise.
     */
    function clear() public returns(bool)  {
        (bool success,) = address(API).call(abi.encodeWithSignature("clear()"));
        return success;       
    }

    /**
     * @notice Execute a custom operation on the container's data stored.
     * @param data Arbitrary data to be used in the custom operation.
     */
    function foreach(bytes memory data) public {
        address(API).call(abi.encodeWithSignature("foreach(bytes)", data));       
    }
}