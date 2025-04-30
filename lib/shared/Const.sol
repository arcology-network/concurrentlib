// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0 <0.9.0;
import "../runtime/Runtime.sol";

library Const {
    uint8 public constant U256_CUM = 103; // Cumulative u256
    uint8 public constant BYTES = 107;

    address public constant CONTAINER_ADDR = address(0x84);
    address public constant MULTIPROCESSOR_ADDR = address(0xb0);
}