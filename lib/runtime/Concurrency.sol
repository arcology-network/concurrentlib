// SPDX-License-Identifier: GPL-3.0
pragma solidity >= 0.8.0 < 0.9.0;

/**
 * @author Arcology Network
 * @title Runtime Contract
 * @dev The Runtime contract provides runtime information to developers.
 *      It exposes functions to retrieve pseudo-process IDs (PIDs) and pseudo-random UUIDs.
 */
library Concurrency {
    /**
     * @notice Get the pseudo-process ID (PID) from an external contract.
     * @dev The PID is a pseudo-process ID and does not represent a real transaction being processed.
     * @return args The pseudo-process ID (PID) returned by the external contract.
     */
    function max(string memory func, uint256 num) public returns(bytes memory) {
        (,bytes memory random) = address(0xd0).call(abi.encodeWithSignature("pid()"));     
        return random;
    }

    /**
     * @notice Get execution scheduler information for the block.
     */
    function conflictWith(string[] memory funcs) public {
        address(0xd0).call(abi.encodeWithSignature("schedule()"));
    }

    /**
     * @notice Get execution scheduler information for the block.
     * @return The scheduler information for the block.
     */
    function schedule() public returns(uint256, uint256, uint256, uint256) {
        (,bytes memory data) = address(0xd0).call(abi.encodeWithSignature("schedule()"));
        return abi.decode(data, (uint256, uint256, uint256, uint256));  
    }
}
 