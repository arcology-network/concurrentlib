// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0;
import "../runtime/Runtime.sol";
import "./ConcurrentGateway.sol";
import "./Const.sol";
/**
 * @author Arcology Network
 * @title Base Concurrent Container
 * @dev The Base contract is a concurrent container designed for concurrent operations,
 *      allowing elements to be added in different processes running in parallel without
 *      causing state conflicts. It provides functionalities for both key-value lookup and
 *      linear access.
 *
 *      The contract serves as a hybrid data structure, functioning as a map set behind the scenes.
 *      The order of elements is formed when any timing-dependent functions like "delLast()" or "nonNilCount()"
 *      are called. However, performing concurrent "delLast()" or getting the length is not recommended in
 *      a parallel environment, as these operations are timing-independent and may lead to conflicts. 
 *      Transactions resulting conflicts will be reverted to protect the state consistency.
 *
 *      Delopers should exercise caution when accessing the container concurrently to avoid conflicts.
 */
contract Base is ConcurrentGateway{    
    /**
     * @notice Constructor to initiate communication with the external contract.
     */
    constructor (uint8 typeID) ConcurrentGateway(typeID, Const.CONTAINER_ADDR) {}
         
    /**
     * @notice Retrieve the length of the container, including newly appended and deleted values if any.
     * @return The length of the container.
     */
    function fullLength() public returns(uint256) {
        (,bytes memory data) = eval(abi.encodeWithSignature("fullLength()"));
        return abi.decode(data, (uint256));
    }  

    /**
     * @notice Retrieve the total number of non nil element in the container.
     * @return The total number of non-nil values in the container.
     */
    function nonNilCount() public returns(uint256) {
        (,bytes memory data) = eval(abi.encodeWithSignature("length()"));
        return abi.decode(data, (uint256));
    }
     
    /**
     * @notice Retrieve the committed length of the container. This usually is the length after previous generation or block.
     * @dev This function is used to get the length of the container after the last commit. 
     * @return The latest committed length of the container. This is function is thread-safe.
     */
    function committedLength() public returns(uint256) {
        (,bytes memory data) = eval(abi.encodeWithSignature("committedLength()"));
        if (data.length > 0) {
            return abi.decode(data, (uint256));   
        }
        return 0;    
    }

    /**
     * @notice Removes and returns the last element of the container.
     * @return The data of the removed element.
     */
    function _delLast() public virtual returns(bytes memory) {
        (,bytes memory data) = eval(abi.encodeWithSignature("delLast()"));
        return data;
    }
    
    /**
     * @notice Delete the data at the given index in the container.
     * @param idx The index of the data to be deleted.
     * @return success true if the data was successfully deleted, false otherwise.
     */
    function del(uint256 idx) public virtual returns(bool) {
        bytes memory key = indToKey(idx);
        if (key.length == 0) {
            return false;
        }
        return _del(key);
    }
    
    /**
     * @notice Delete the data associated with the given key from the container.
     * @param key The key associated with the data to be deleted.
     * @return success true if the data was successfully deleted, false otherwise.
     */
    function _del(bytes memory key) public returns(bool) {
       (bool success,)  = eval(abi.encodeWithSignature("delByKey(bytes)", key));
       return success;
    }
    
    /**
     * @notice Delete all the elements.
     * @return success true if the all the data was successfully deleted, false otherwise.
     */
    function clear() public returns(bool)  {
        (bool success,)  = eval(abi.encodeWithSignature("clear()"));
        return success;       
    }
    
    /**
     * @notice Reset the data associated with the key to its default value.
     * @param key The key associated with the data to be reset.
     * @return success true if the data was successfully reset, false otherwise.
     */
    function _resetByKey(bytes memory key) public returns(bool) {
       (bool success,) = eval(abi.encodeWithSignature("resetByKey(bytes)", key));
       return success;
    }

    /**
     * @notice Reset the data associated at the index to its default value.
     * @param idx The index associated with the data to be reset.
     * @return success true if the data was successfully reset, false otherwise.
     */
    function resetByInd(uint256 idx) public returns(bool) {
       (bool success,) = eval(abi.encodeWithSignature("resetByInd(uint256)", idx));
       return success;
    }

    /**
     * @notice Retrieves the key associated with the given index in the concurrent container.
     * @param idx The index for which to retrieve the key.
     * @return The key associated with the given index.
     */
    function indToKey(uint256 idx) public returns(bytes memory) {
        (, bytes memory data) = eval(abi.encodeWithSignature("indToKey(uint256)", idx));
        return data;  
    }

    /**
     * @notice Retrieves the index associated with the given key in the concurrent container.
     * @param key The key for which to retrieve the index.
     * @return The index associated with the given key.
     */
    function keyToInd(bytes memory key) public returns(uint256) {
        (, bytes memory data) = eval(abi.encodeWithSignature("keyToInd(bytes)", key));   
        return abi.decode(data,(uint256));     
    }
    
    /**
     * @notice Set the data at the given index in the container. It equals to append if the index is the length of the container.
     * @param idx The index where the data should be stored.
     * @param encoded The data to be stored.
     * @return success true if the data was successfully updated, false otherwise.
     */
    function _set(uint256 idx, bytes memory encoded) public returns(bool) {
        bytes memory key = indToKey(idx);
        if (key.length == 0) {
            return false;
        }
        return _set(key, encoded);
    }

    /**
     * @notice Set the data associated with the given key in the container.
     * @param key The key associated with the data.
     * @param elem The data to be stored.
     * @return success true if the data was successfully updated, false otherwise.
     */
    function _set(bytes memory key, bytes memory elem) public returns(bool) {
        (bool success,) = eval(abi.encodeWithSignature("setByKey(bytes,bytes)", key, elem));
        return success;   
    }

    /**
     * @notice Set the data associated with the given key in the container.
     * @param key The key associated with the data.
     * @param min The lower bound of the data to be stored.
     * @param max The upper bound of the data to be stored.
     * @return success true if the data was successfully updated, false otherwise.
     */
    function _init(bytes memory key, bytes memory min, bytes memory max) public returns(bool) {
        (bool success,) = eval(abi.encodeWithSignature("init(bytes,bytes,bytes)", key, min, max));
        return success;   
    }
    
    /**
     * @notice Checks if a key exists in the the data structure. *
     * @param key The key to check for existence.
     * @return A boolean indicating whether the key exists in it or not.
    */
    function exists(bytes memory key) public returns(bool) {
        (bool success,) = eval(abi.encodeWithSignature("getByKey(bytes)", key));
        return success;
    }

    /**
     * @notice Checks if the index exists in the the data structure.
     * @param idx The index to check for existence.
     * @return A boolean indicating whether the key exists in it or not.
    */
    function exists(uint256 idx) public returns(bool) {
        bytes memory key = indToKey(idx);
        if (key.length == 0) {
            return false;
        }
        return exists(key);
    }
    
    /**
     * @notice Retrieve the data at the given index from the container.
     * @param idx The index of the data to retrieve.
     * @return The data stored at the specified index.
     */
    function _get(uint256 idx) public returns(bool, bytes memory) {
        return eval(abi.encodeWithSignature("getByIndex(uint256)", idx)); 
    }

    /**
     * @notice Retrieve the data associated with the given key from the container.
     * @param key The key associated with the data to retrieve.
     * @return The data stored at the specified key.
     */
    function _get(bytes memory key) public returns(bool, bytes memory)  {
        return eval(abi.encodeWithSignature("getByKey(bytes)", key));  
    }

    /**
     * @notice Retrieve the minimum entry stored in the container sorted by value numerically.
     * @return encoded The minimum valu and the index.
     */
    function _min() public returns(bytes memory)  {
        (,bytes memory data) = eval(abi.encodeWithSignature("min()"));
        return data;
    }

    /**
     * @notice Retrieve the maximum entry stored in the container sorted by value numerically.
     * @return The encoded maximum value and the index.
     */
    function _max() public returns(bytes memory)  {
        (,bytes memory data) = eval(abi.encodeWithSignature("max()"));
        return data;
    }

    /**
     * @notice Execute a custom operation on the container's data stored.
     * @param data Arbitrary data to be used in the custom operation.
     */
    function invoke(bytes memory data) public returns(bool, bytes memory) {
        return address(API).call(abi.encodeWithSignature("invoke(bytes)", data));  
    }

    /**
     * @notice Get a pseudo-random UUID from an external contract.
     * @dev The UUID is a pseudo-random number generated by the external contract.
     * @return The pseudo-random UUID returned by the external contract.
     */
    function uuid() public returns(bytes memory) {
        return  Runtime.uuid(); 
    }
}