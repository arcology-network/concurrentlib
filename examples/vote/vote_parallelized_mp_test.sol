// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

import "../../lib/multiprocess/Multiprocess.sol";
import "./VoteParallelizedMp.sol";

contract ParaBallotCaller {
    constructor() {                
        bytes32[] memory proposalNames = new bytes32[](2); 
        proposalNames[0] = keccak256("Alice");
        proposalNames[1] = keccak256("Bob");

        address addr1 = 0x1111111110123456789012345678901234567890;
        address addr2 = 0x2222222220123456789012345678901234567890;
        address addr3 = 0x3333337890123456789012345678901234567890;
        address addr4 = 0x4444444890123456789012345678901234567890;
        address addr5 = 0x5555555550123456789012345678901234567890;

        ParaBallot ballot = new ParaBallot(msg.sender, proposalNames);   

        Multiprocess mp = new Multiprocess(5);

        mp.push(1000000, address(ballot), abi.encodeWithSignature("giveRightToVote(address)", addr1));
        mp.push(1000000, address(ballot), abi.encodeWithSignature("giveRightToVote(address)", addr2));
        mp.push(1000000, address(ballot), abi.encodeWithSignature("giveRightToVote(address)", addr3));
        mp.push(1000000, address(ballot), abi.encodeWithSignature("giveRightToVote(address)", addr4));
        mp.push(1000000, address(ballot), abi.encodeWithSignature("giveRightToVote(address)", addr5));
        mp.run();
        mp.clear();

        mp.push(1000000, address(ballot), abi.encodeWithSignature("vote(address,uint256)", addr1, 0));
        mp.push(1000000, address(ballot), abi.encodeWithSignature("vote(address,uint256)", addr2, 0));
        mp.push(1000000, address(ballot), abi.encodeWithSignature("vote(address,uint256)", addr3, 1));
        mp.push(1000000, address(ballot), abi.encodeWithSignature("vote(address,uint256)", addr4, 0));
        mp.push(1000000, address(ballot), abi.encodeWithSignature("vote(address,uint256)", addr5, 1));
        mp.run();
        mp.rollback();

        require(ballot.winningProposal() == 0);
        require(ballot.winnerName() == keccak256("Alice"));

        require(ballot.checkBallot(0) == 3);
        require(ballot.checkBallot(1) == 2);
    }
}
