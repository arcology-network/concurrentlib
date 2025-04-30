// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0 <0.9.0;

import "../shared/Const.sol";
import "../runtime/Runtime.sol";

/**
 * @author Arcology Network
 * @title BytesOrderedSet Concurrent Container
 * @dev The BytesOrderedSet contract is designed for concurrent operations,
 *      allowing elements to be added in different processes running in parallel without
 *      causing state conflicts. It provides functionalities for both key-value lookup and
 *      linear access.
 */
contract BytesOrderedSet {
    address internal API = Const.CONTAINER_ADDR;
    bytes internal constant MIN = abi.encodePacked(uint256(0));
    bytes internal constant MAX = abi.encodePacked(type(uint256).max);
    
    /**
     * @notice Constructor to initiate communication with the external contract.
     */
    constructor () {       
        (bool success,) = address(API).call(abi.encodeWithSignature(
            "new(uint8,bytes,bytes)", uint8(Const.U256_CUM), new bytes(0), new bytes(0)));
        require(success);
    }
    
    /**
     * @notice Retrieve the data at the given index from the container.
     * @param idx The index of the data to retrieve.
     * @return The data stored at the specified index.
     */
    function get(uint256 idx) public virtual returns(bytes memory) {
        (,bytes memory elem) = address(API).call(abi.encodeWithSignature("indToKey(uint256)", idx)); 
        return elem;
    }
      
    /**
     * @notice Checks if a key exists in the the data structure. *
     * @param elem The elem to check for existence.
     * @return A boolean indicating whether the key exists in it or not.
    */
    function exists(bytes memory elem) public returns(bool) {
        (bool success,) = address(API).call(abi.encodeWithSignature("getByKey(bytes)", elem));
        return success;
    }
         
    /**
     * @notice Retrieve the length of the container, including newly appended and deleted values if any.
     * @return The length of the container.
     */
    function Length() public returns(uint256) {
        (,bytes memory data) = address(API).call(abi.encodeWithSignature("fullLength()"));
        return abi.decode(data, (uint256));
    }  

    /**
     * @notice Set the data associated with the given key in the container.
     * @param elem The data to be stored.
     * @return success true if the data was successfully updated, false otherwise.
     */
    function set(bytes memory elem) public returns(bool) {
        (bool success,) = address(API).call(abi.encodeWithSignature("init(bytes,bytes,bytes)", elem, MIN, MAX));
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