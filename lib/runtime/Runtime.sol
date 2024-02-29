// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0 <0.9.0;

/**
 * @author Arcology Network
 * @title Runtime Library
 * @dev The Runtime Library provides runtime information to developers.
 *      It exposes functions to retrieve pseudo-process IDs (PIDs) and pseudo-random UUIDs.
 */
library Runtime {
    /**
     * @notice Get the pseudo-process ID (PID) from an external contract.
     * @dev The PID is a pseudo-process ID and does not represent a real transaction being processed.
     * @return args The pseudo-process ID (PID) returned by the external contract.
     */
    function pid() internal returns(bytes memory) {
        (,bytes memory random) = address(0xa0).call(abi.encodeWithSignature("pid()"));     
        return random;
    }

    /**
     * @notice Get a pseudo-random UUID from an external contract.
     * @dev The UUID is a pseudo-random number generated by the external contract.
     * @return The pseudo-random UUID returned by the external contract.
     */
    function uuid() internal returns(bytes memory) {
        (,bytes memory id) = address(0xa0).call(abi.encodeWithSignature("uuid()"));     
        return id;
    }
  
    /**
     * @notice Call a custom operation.
     * @return The result of the custom operation.
     */
    function eval(string memory func, bytes memory data) internal returns(bool, bytes memory) {
        return address(0xa0).call(abi.encodeWithSignature(func, data)); 
    }

    /**
     * @notice Call a custom operation.
     * @return The result of the custom operation.
     */
    function eval(string memory func, uint256 data) internal returns(bool, bytes memory) {
        return address(0xa0).call(abi.encodeWithSignature(func, data)); 
    }

    /**
     * @notice The funtion instructs the scheduler to avoid executing the specified functions with itself in parallel.
     * @param funcs The list of function signatures and their contract addresses to avoid executing in parallel.
     */
    // function avoid(string[] memory funcs) internal {
    //     address(0xa0).call(abi.encodeWithSignature("avoid(string[])", funcs));
    // }

    /**
     * @notice Get the number of concurrent instances of the specified function.
     * @return The number of concurrent instances.
     */
    function instances(address addr, string memory func) internal returns(uint256) {
        bytes4 funSign = bytes4(keccak256(bytes(func)));
        (,bytes memory data) = address(0xa0).call(abi.encodeWithSignature("instances(address,bytes4)", addr, funSign));
        return abi.decode(data, (uint256));  
    }

    /**
     * @notice Inform the scheduler that a function needs to schedule a deferred call. This function can only be called once in the constructor.
     * @return The number of concurrent instances.
     */
    function deferred(bytes4 funSign) internal returns(bool) {
        (bool successful,) = address(0xa0).call(abi.encodeWithSignature("deferred(bytes4)", funSign));
        return successful;  
    }
}
