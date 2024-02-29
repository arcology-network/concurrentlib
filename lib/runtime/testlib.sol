// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.19 <0.9.0;

library TestLibrary {
    function deferred(uint a, uint b) internal pure returns (uint) {
        return a - b;
    }
}
