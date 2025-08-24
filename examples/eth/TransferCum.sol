// SPDX-License-Identifier: MIT
pragma solidity 0.7.6;


contract TransferCum {
    event Step(uint256 val);
    function refund(uint256 val) public payable {
        emit Step(0);
        payable(msg.sender).transfer(50);
        emit Step(1);
        payable(msg.sender).transfer(60);
        emit Step(2);
    }

}