    // SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0 <0.9.0;

/**
 * @author Arcology Network
 * @title Runtime Library
 * @dev The Runtime Library provides runtime information to developers.
 *      It exposes functions to retrieve pseudo-process IDs (PIDs) and pseudo-random UUIDs.
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