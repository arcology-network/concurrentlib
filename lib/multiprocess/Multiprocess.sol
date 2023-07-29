// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.19;

import "../runtime/Runtime.sol";
import "../storage/Storage.sol";
import "../base/Base.sol";

/**
 * @author Arcology Network
 * @title Multiprocess Container
 * @dev The Multiprocess contract inherits from "Base" and "Storage" contracts.
 *      It serves as a container for executable messages, enabling parallel processing
 *      similar to Python's `multiprocessing` library.
 */
contract Multiprocess is Base, Storage {
    uint256 numProcesses = 1;

    /**
     * @notice Constructor to initialize the Multiprocess container.
     * @param threads The number of parallel processors (ranging from 1 to 255) for parallel processing.
     */
    constructor (uint256 threads) {
        Base.API = address(0xb0);
        numProcesses = threads; 
    } 

    /**
     * @notice Push an executable message into the container.
     * @param input The executable message data to be pushed into the container.
     */
    function push(bytes memory input) public virtual { // 9e c6 69 25
        setByKey(uuid(), input);
    } 

    /**
     * @notice Push an executable message into the container with specified gas limit, contract address, and function call data.
     * @param gaslimit The gas limit for the execution of the function call.
     * @param contractAddr The address of the smart contract to execute the function on.
     * @param funcCall The encoded function call data.
     */
    function push(uint256 gaslimit, address contractAddr, bytes memory funcCall) public virtual {
        setByKey(uuid(), abi.encode(gaslimit, contractAddr, funcCall));
    }
 
    /**
     * @notice Pop an executable message from the container.
     * @return The popped executable message.
     */
    function pop() public virtual returns(bytes memory) { // 80 26 32 97
        return abi.decode(Base.popBack(), (bytes));  
    }

    /**
     * @notice Get an executable message from the container at the specified index.
     * @param idx The index of the executable message to retrieve.
     * @return The executable message at the specified index.
     */
    function get(uint256 idx) public virtual returns(bytes memory) { // 31 fe 88 d0
        return abi.decode(Base.getByIndex(idx), (bytes));  
    }

    /**
     * @notice Set an executable message at the specified index in the container.
     * @param idx The index where the executable message should be stored.
     * @param elem The executable message data to be stored at the specified index.
     */
    function set(uint256 idx, bytes memory elem) public { // 7a fa 62 38
        Base.setByIndex(idx, abi.encode(elem));   
    }

    /**
     * @notice Execute the executable messages in the container concurrently.
     * @dev This function processes the executable messages concurrently with the number 
     *      of threads specified in the constructor.
     */
    function run() public {       
        foreach(abi.encode(numProcesses));
    }
}