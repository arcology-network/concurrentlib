// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0 <0.9.0;

/**
 * @author Arcology Network
 * @title U256Cumulative
 * @dev The U256Cumulative contract is an integer designed for cumulative operations in full concurrency. 
 * It has both minimum and maximum bounds and allows concurrent delta changes as long as they are not mixed 
 * with timing-dependent opeartions like reads ensuring thread safety. It is crucial to note that out-of-limit 
 * delta changes will fail to ensure that the variable stays within its prescribed bounds.
 */
contract U256Cumulative {
    address constant public API = address(0x85);    

    /**
     * @notice Constructor to initialize the U256Cumulative variable with specified minimum and maximum bounds.
     * @param minv The minimum bound of the cumulative value.
     * @param maxv The maximum bound of the cumulative value.
     */
    constructor (uint256 minv, uint256 maxv) {
        (bool success,) = address(API).call(abi.encodeWithSignature("New(uint256, uint256, uint256)", minv, maxv));
        assert(success);
    }

    /**
     * @notice Get the current value of the cumulative variable.
     * @return The current value of the cumulative variable.
     */
    function get() public view returns(uint256) {  
        (,bytes memory data) = address(API).staticcall(abi.encodeWithSignature("get()"));
        return abi.decode(data, (uint256));
    }

    /**
     * @notice Add the given value to the cumulative variable.
     * @param delta The value to be added to the cumulative variable.
     * @return A boolean indicating the success of the operation.
     */
    function add(uint256 delta) public returns(bool) { 
        (bool success,) = address(API).call(abi.encodeWithSignature("add(uint256)", delta));
        return success; 
    }

    /**
     * @notice Subtract the given value from the cumulative variable.
     * @param delta The value to be subtracted from the cumulative variable.
     * @return A boolean indicating the success of the operation.
     */
    function sub(uint256 delta) public returns(bool) { 
        (bool success,) = address(API).call(abi.encodeWithSignature("sub(uint256)", delta));
        return success;
    }   

    /**
     * @notice Get the minimum bound of the cumulative variable.
     * @return The minimum bound of the cumulative variable.
     */
    function min() public returns(uint256) { 
        (, bytes memory data) = address(API).call(abi.encodeWithSignature("min()"));
        return abi.decode(data, (uint256));
    }  

    /**
     * @notice Get the maximum bound of the cumulative variable.
     * @return The maximum bound of the cumulative variable.
     */
    function max() public returns(uint256) { 
        (, bytes memory data) = address(API).call(abi.encodeWithSignature("max()"));
        return abi.decode(data, (uint256));
    }    
}
