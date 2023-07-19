// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.19;

import "../runtime/Runtime.sol";
import "../array/Bool.sol";

/**
 * @title Multiprocess Container
 * @dev The Multiprocess contract inherits from "Base" and "Revertible" contracts.
 *      It serves as a container for executable messages, enabling parallel processing
 *      similar to Python's `multiprocessing` library.
 */
contract Multiprocess is Base, Revertible {
    uint256 numProcesses = 1;

    /**
     * @notice Constructor to initialize the Multiprocess container.
     * @param threads The number of processes (ranging from 1 to 2048) of execution for parallel processing.
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

    function push(uint256 gaslimit, address contractAddr, bytes memory funcCall) public virtual { // 9e c6 69 25
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
     * @dev This function processes the executable messages concurrently,
     *      similar to Python's `multiprocessing` or C++ thread libraries,
     *      using the specified number of threads for concurrent execution.
     */
    function run() public {       
        foreach(abi.encode(numProcesses));
    }
}