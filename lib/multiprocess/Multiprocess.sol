// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0;

import "../shared/Const.sol"; 
import "../shared/Base.sol";
import "../shared/ConcurrentGateway.sol";
import "../runtime/Runtime.sol";
/**
 * @author Arcology Network
 * @title Multiprocess Container
 * @dev The Multiprocess contract inherits from "Base" and "Storage" contracts.
 *      It serves as a container for executable messages, enabling parallel processing
 *      similar to Python's `multiprocessing` library.
 */
 
struct JobResult {
    bool success;
    bytes returnData;
}

contract Multiprocess is ConcurrentGateway(Const.BYTES, Const.MULTIPROCESSOR_ADDR) {
    uint256 numProcesses = 1;

    /**
     * @notice Constructor to initialize the Multiprocess container.
     * @param threads The number of parallel processors (ranging from 1 to 255) for parallel processing.
     */
    constructor (uint256 threads){
        numProcesses = threads; 
    } 

    /**
     * @notice Add an job to the parallel job queue.
     * @param gaslimit The gas limit for the execution of the function call.
     * @param ethVal The number of wei sent with the message.
     * @param contractAddr The address of the smart contract to execute the function on.
     * @param funcCall The encoded function call data.
     */
    function addJob(uint256 gaslimit, uint256 ethVal, address contractAddr, bytes memory funcCall) public returns(bool) {
        bytes memory data = abi.encode(gaslimit, ethVal, contractAddr, funcCall);
        (bool success,) = eval(abi.encodeWithSignature("setByKey(bytes,bytes)", Runtime.uuid(), data));
        return success;
    }

    /**
     * @notice Execute the executable messages in the container concurrently.
     * @dev This function processes the executable messages concurrently with the number 
     *      of threads specified in the constructor.
     */
    function run() public returns(bool, bytes memory){       
        (bool success, bytes memory data) = address(API).call(abi.encodeWithSignature("invoke(bytes)", abi.encodePacked(numProcesses))); 
        (success,) = eval(abi.encodeWithSignature("clear()"));
        return (success, data);
    }
}