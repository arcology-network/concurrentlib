// The is a parallelized of the Ballot contract. This contract is specifically designed 
// to be used by the multiprocess for testing.
// 
// DO NOT USE THIS CONTRACT IN A PRODUCTION ENVIRONMENT !!!!
//
// The following changes have been made to the original contract:
// 
// 1. Added concurrent arrays for bidders and bids.
// 
// 2. Stopped finding the highest bidder and the highest bid in the auctionEnd function, but 
//  stored the all the bidder and the bids in concurrent arrays and then find the highest bidder and
//  the highest bid in the auctionEnd function.
// 
// 3. Removed the auctionEndTime variable. This is because the this is no block.timestamp when using
//   the multiprocessor. 

// 4. Added an extra return value to the auctionEnd function to allow the highest bid to be returned. This

// 5. Stopped transferring the highest bid to the beneficiary in the auctionEnd function.
// The original contract can be found here: https://docs.soliditylang.org/en/latest/solidity-by-example.html#simple-auction

// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0 <0.9.0;

import "../../lib/array/U256.sol";
import "../../lib/array/Address.sol";
import "../../lib/map/AddressUint256.sol";

contract SimpleAuction {
    // Parameters of the auction. Times are either
    // absolute unix timestamps (seconds since 1970-01-01)
    // or time periods in seconds.
    address payable public beneficiary;
    // uint public auctionEndTime;

    // Current state of the auction.
    address public highestBidder;
    uint public highestBid;

    // Concurrent data structures.
    // Address public bidders;
    U256 public bids;

    AddressUint256Map public bidders;

    // Allowed withdrawals of previous bids
    mapping(address => uint) pendingReturns;

    // Set to true at the end, disallows any change.
    // By default initialized to `false`.
    bool ended;

    // Events that will be emitted on changes.
    event HighestBidIncreased(address bidder, uint amount);
    event AuctionEnded(address winner, uint amount);

    // Errors that describe failures.

    // The triple-slash comments are so-called natspec
    // comments. They will be shown when the user
    // is asked to confirm a transaction or
    // when an error is displayed.

    /// The auction has already ended.
    error AuctionAlreadyEnded();
    /// There is already a higher or equal bid.
    error BidNotHighEnough(uint highestBid);
    /// The auction has not ended yet.
    error AuctionNotYetEnded();
    /// The function auctionEnd has already been called.
    error AuctionEndAlreadyCalled();

    /// Create a simple auction with `biddingTime`
    /// seconds bidding time on behalf of the
    /// beneficiary address `beneficiaryAddress`.
    constructor(
        // uint biddingTime,
        address payable beneficiaryAddress
    ) {
        beneficiary = beneficiaryAddress;
        // auctionEndTime = block.timestamp + biddingTime;

        bidders = new AddressUint256Map();
        // bidders = new Address();
        // bids = new U256();
    }

    /// Bid on the auction with the value sent
    /// together with this transaction.
    /// The value will only be refunded if the
    /// auction is not won.
    function bid(address bidder, uint256 bidValue) external payable {
        // No arguments are necessary, all
        // information is already part of
        // the transaction. The keyword payable
        // is required for the function to
        // be able to receive Ether.

        // Revert the call if the bidding
        // period is over.
        // if (block.timestamp > auctionEndTime)
        //     revert AuctionAlreadyEnded();

        // 
        // bidders.push(msg.sender);
        // bids.push(msg.value);
        bidders.set(bidder, bidValue);
        // bidders.push(bidder);
        // bids.push(bidValue);

        // If the bid is not higher, send the
        // Ether back (the revert statement
        // will revert all changes in this
        // function execution including
        // it having received the Ether).
        // if (msg.value <= highestBid)
        //     revert BidNotHighEnough(highestBid);

        // if (highestBid != 0) {
        //     // Sending back the Ether by simply using
        //     // highestBidder.send(highestBid) is a security risk
        //     // because it could execute an untrusted contract.
        //     // It is always safer to let the recipients
        //     // withdraw their Ether themselves.
        //     pendingReturns[highestBidder] += highestBid;
        // }
        // highestBidder = msg.sender;
        // highestBid = msg.value;
        // emit HighestBidIncreased(msg.sender, msg.value);
    }

    /// Withdraw a bid that was overbid.
    function withdraw(address addr) external returns (bool) {
        // if (!ended) {
        //     revert AuctionNotYetEnded();
        // }

        if(addr == highestBidder) {
            return false;
        }

        uint amount = bidders.get(addr);
        if (amount > 0) {
            // It is important to set this to zero because the recipient
            // can call this function again as part of the receiving call
            // before `send` returns.
            // pendingReturns[msg.sender] = 0;
            bidders.set(addr, 0);

            // msg.sender is not of type `address payable` and must be
            // explicitly converted using `payable(msg.sender)` in order
            // use the member function `send()`.
            if (!payable(addr).send(amount)) {
                // No need to call throw here, just reset the amount owing
                // pendingReturns[msg.sender] = amount;
                bidders.set(addr, amount);
                return false;
            }
        }
        return true;
    }

    /// End the auction and send the highest bid
    /// to the beneficiary.
    function auctionEnd() external returns(uint256){
        // It is a good guideline to structure functions that interact
        // with other contracts (i.e. they call functions or send Ether)
        // into three phases:
        // 1. checking conditions
        // 2. performing actions (potentially changing conditions)
        // 3. interacting with other contracts
        // If these phases are mixed up, the other contract could call
        // back into the current contract and modify the state or cause
        // effects (ether payout) to be performed multiple times.
        // If functions called internally include interaction with external
        // contracts, they also have to be considered interaction with
        // external contracts.

        // 1. Conditions
        // if (block.timestamp < auctionEndTime)
        //     revert AuctionNotYetEnded();
        // if (ended)
        //     revert AuctionEndAlreadyCalled();


        // We need to find the highest bidder and the highest bid.
        (highestBidder,, highestBid) = bidders.max();

        // // 2. Effects
        ended = true;
        emit AuctionEnded(highestBidder, highestBid);
    
        // // 3. Interaction
        // beneficiary.transfer(highestBid);
        return highestBid;
    }
}