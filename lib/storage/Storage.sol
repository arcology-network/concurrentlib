
// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.19;

/**
 * @title Storage Contract
 * @dev The Storage contract provides a function to clear all storage changes made in the current block
 *      and reset the contract storage to its previous state. Caution should be exercised while using this function,
 *      especially in the constructor, as it will cause the contract deployment to fail.
 */
contract Storage { 
    /**
     * @notice Roll back all state changes made in the current block and reset the contract to the previous state.
     * @dev Caution: Using this function, especially in the constructor, may cause the contract deployment to fail.
     */
    function rollback() public {
        address(0xa0).call(abi.encodeWithSignature("Reset()"));     
    }
}