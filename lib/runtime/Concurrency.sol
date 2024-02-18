// SPDX-License-Identifier: GPL-3.0
// pragma solidity >= 0.8.0 < 0.9.0;

// /**
//  * @author Arcology Network
//  * @title Runtime Contract
//  * @dev The Runtime contract provides runtime information to developers.
//  *      It exposes functions to retrieve pseudo-process IDs (PIDs) and pseudo-random UUIDs.
//  */
// library Concurrency {
//     /**
//      * @notice Get the pseudo-process ID (PID) from an external contract.
//      * @dev The PID is a pseudo-process ID and does not represent a real transaction being processed.
//      * @return args The pseudo-process ID (PID) returned by the external contract.
//      */
//     function max(string memory func, uint256 num) public returns(bytes memory) {
//         (,bytes memory random) = address(0xd0).call(abi.encodeWithSignature("pid()"));     
//         return random;
//     }

//     /**
//      * @notice The funtion instructs the scheduler to avoid executing the specified functions with itself in parallel.
//      * @param funcs The list of function signatures and their contract addresses to avoid executing in parallel.
//      */
//     function avoid(string[] memory funcs) public {
//         address(0xd0).call(abi.encodeWithSignature("avoid()"));
//     }

//     /**
//      * @notice Get the number of concurrent instances of the specified function.
//      * @return The scheduler information for the block.
//      */
//     function instances(address addr, string memory func) public returns(uint256) {
//         (,bytes memory data) = address(0xd0).call(abi.encodeWithSignature("schedule(address, string)", addr, func));
//         return abi.decode(data, (uint256));  
//     }
// }
 