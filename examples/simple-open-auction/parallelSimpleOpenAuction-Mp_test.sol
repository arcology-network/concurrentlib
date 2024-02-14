// SPDX-License-Identifier: GPL-3.0
pragma solidity >= 0.8.0 < 0.9.0;

import "../../lib/multiprocess/Multiprocess.sol";
import "./ParallelSimpleOpenAuction-Mp.sol";

contract ParallelSimpleAuctionTest {
    constructor() {                
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

        // The followings aren't going to work because the all the addresses are empty.abi
        // They have no funds to withdraw.
        require(auction.withdraw(addr1)); // addr1 didn't bid, so it should have a zero amount.
        require(!auction.withdraw(addr2));
        require(!auction.withdraw(addr3));
        require(!auction.withdraw(addr4));
        require(!auction.withdraw(addr5));
    }
}
