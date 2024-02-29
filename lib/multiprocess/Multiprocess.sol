// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0 <0.9.0;

import "../storage/Storage.sol";
import "../base/Base.sol";

/**
 * @author Arcology Network
 * @title Multiprocess Container
 * @dev The Multiprocess contract inherits from "Base" and "Storage" contracts.
 *      It serves as a container for executable messages, enabling parallel processing
 *      similar to Python's `multiprocessing` library.
 */
contract Multiprocess is Base {
    enum Status{ 
        SUCCESSFUL, 
        EXECUTION_FAILED, 
        CONFLICT,
        ABORTED,
        FAILED_TO_RETRIVE
    }
    uint256 numProcesses = 1;

    /**
     * @notice Constructor to initialize the Multiprocess container.
     * @param threads The number of parallel processors (ranging from 1 to 255) for parallel processing.
     */
    constructor (uint256 threads){
        Base.API = address(0xb0);
        numProcesses = threads; 
    } 

    /**
     * @notice Push an executable message into the container with specified gas limit, contract address, and function call data.
     * @param gaslimit The gas limit for the execution of the function call.
     * @param contractAddr The address of the smart contract to execute the function on.
     * @param funcCall The encoded function call data.
     */
    function push(uint256 gaslimit, address contractAddr, bytes memory funcCall) public virtual {
        push(gaslimit, 0, contractAddr, funcCall);
    }

     /**
     * @notice Push an executable message into the container with specified gas limit, contract address, and function call data.
     * @param gaslimit The gas limit for the execution of the function call.
     * @param ethVal The number of wei sent with the message.
     * @param contractAddr The address of the smart contract to execute the function on.
     * @param funcCall The encoded function call data.
     */
    function push(uint256 gaslimit, uint256 ethVal, address contractAddr, bytes memory funcCall) public virtual {
        setByKey(uuid(), abi.encode(gaslimit, ethVal, contractAddr, funcCall));
    }
 
    /**
     * @notice Pop an executable message from the container.
     * @return The popped executable message.
     */
    function pop() public virtual returns(bytes memory) { 
        return abi.decode(Base.popBack(), (bytes));  
    }

    /**
     * @notice Get an executable message from the container at the specified index.
     * @param idx The index of the executable message to retrieve.
     * @return The executable message at the specified index.
     */
    function get(uint256 idx) public virtual returns(bytes memory) {
        return abi.decode(Base.getByIndex(idx), (bytes));  
    }

    /**
     * @notice Set an executable message at the specified index in the container.
     * @param idx The index where the executable message should be stored.
     * @param elem The executable message data to be stored at the specified index.
     */
    function set(uint256 idx, bytes memory elem) public { 
        Base.setByIndex(idx, abi.encode(elem));   
    }

    /**
     * @notice Execute the executable messages in the container concurrently.
     * @dev This function processes the executable messages concurrently with the number 
     *      of threads specified in the constructor.
     */
    function run() public {       
        foreach(abi.encodePacked(numProcesses));
    }

    /**
     * @notice Roll back all state changes made in the current block and reset the contract to the previous state.
     * @dev Caution: Using this function, especially in the constructor, may cause the contract deployment to fail.
     */
    function rollback() public {
        address(0xa0).call(abi.encodeWithSignature("Reset()"));     
    }
}