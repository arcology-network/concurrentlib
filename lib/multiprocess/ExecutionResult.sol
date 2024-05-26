// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0 <0.9.0;

/**
 * @author Arcology Network
 * @title ExecutionResult
 * @dev The ExecutionResult struct is used to store the result of an executable message from the Multiprocess.
 */
struct ExecutionResult {   
    uint256 errorCode;
    string errorMsg;
    uint256 gasUsed;
    bytes retData;
}