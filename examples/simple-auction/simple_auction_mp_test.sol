// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

import "../../lib/multiprocess/Multiprocess.sol";
import "./ParalllelSimpleAuctionMp.sol";

contract ParalllelSimpleAuctionTest {
    constructor() {                
        // Create 2 proposals.
        bytes32[] memory proposalNames = new bytes32[](2); 
        proposalNames[0] = keccak256("Alice");
        proposalNames[1] = keccak256("Bob");

        // Create 5 random addresses.
        address addr1 = 0x1111111110123456789012345678901234567890;
        address addr2 = 0x2222222220123456789012345678901234567890;
        address addr3 = 0x3333337890123456789012345678901234567890;
        address addr4 = 0x4444444890123456789012345678901234567890;
        address addr5 = 0x5555555550123456789012345678901234567890;

        SimpleAuction auction = new SimpleAuction(payable(addr1));   
        auction.bid(addr2, 111);
        auction.bid(addr3, 121);
        auction.bid(addr4, 141);
        auction.bid(addr5, 101);
        require(auction.auctionEnd() == 141);
    }
}
