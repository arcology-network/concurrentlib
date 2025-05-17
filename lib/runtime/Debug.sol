    // SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0;

/**
 * @author Arcology Network
 * @title Debug Library
 * @dev The Library provides a set of functions for debugging and logging information to the console.
 */

library Debug {
    /**
     * @notice print a string to the console.
     * @param info The string to print.
     * @return The number of concurrent instances.
     */
    function print(bytes memory info) internal returns(bool) {
        (bool successful,) = address(0xa0).call(abi.encodeWithSignature("print(bytes)", info));
        return successful;  
    }

    function print(uint256 info) internal returns(bool) {
        (bool successful,) = address(0xa0).call(abi.encodeWithSignature("print(bytes)", info));
        return successful;  
    }

    function print(address info) internal returns(bool) {
        (bool successful,) = address(0xa0).call(abi.encodeWithSignature("print(bytes)", info));
        return successful;  
    }
}