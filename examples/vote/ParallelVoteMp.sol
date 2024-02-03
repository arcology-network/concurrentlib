// The is a parallelized version of the Ballot contract specifically for multi-process testing.
// The original contract is  from the Solidity documentation. You can find the original contract here: https://docs.soliditylang.org/en/latest/solidity-by-example.html

// It is designed to demonstrate how a standard Ethereum contract can be parallelized using the Arcology Network's concurrent libraries.
// for more information on the Arcology Network, please visit: https://doc.arcology.network/

// The follow changes have been made to the original contract:
// 1. Replaced the weight variable in the Voter struct with a U256Cumulative variable for concurrent operations.
// 2. Replaced the voteCount variable in the Proposal struct with a U256Cumulative variable for concurrent operations.
// 3. Added a canDelegate variable to the Voter struct to allow voters to delegate their votes to others. This is necessary to work around some constraints.
// 4. Added an extra parameter to the constructor to allow the owner of the contract to be set. This is for multi-processor testing.
// 5. Added an extrac parameter to the vote function to allow the voter's address to be passed in. This is for multi-processor testing.

// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

import "../../lib/commutative/U256Cum.sol";

/// @title Voting with delegation.
contract Ballot {
    // This declares a new complex type which will
    // be used for variables later.
    // It will represent a single voter.
    struct Voter {
        U256Cumulative weight; // weight is accumulated by delegation
        bool voted;  // if true, that person already voted
        bool canDelegata; // If true, the voter can delegate others to vote on their behalf.
        address delegate; // person delegated to
        uint vote;   // index of the voted proposal
    }

    // This is a type for a single proposal.
    struct Proposal {
        bytes32 name;   // short name (up to 32 bytes)
        U256Cumulative voteCount;
    }

    address public chairperson;

    // This declares a state variable that
    // stores a `Voter` struct for each possible address.
    mapping(address => Voter) public voters;

    // A dynamically-sized array of `Proposal` structs.
    Proposal[] public proposals;

    /// Create a new ballot to choose one of `proposalNames`.
    constructor(address owner, bytes32[] memory proposalNames) {
        chairperson = owner; // msg.sender;
        voters[chairperson].weight = new U256Cumulative(1, type(uint256).max);
        voters[chairperson].weight.add(1);

        voters[chairperson].canDelegata = true;
        // For each of the provided proposal names,
        // create a new proposal object and add it
        // to the end of the array.
        for (uint i = 0; i < proposalNames.length; i++) {
            // `Proposal({...})` creates a temporary
            // Proposal object and `proposals.push(...)`
            // appends it to the end of `proposals`.
            proposals.push(Proposal({
                name: proposalNames[i],
                voteCount: new U256Cumulative(0, type(uint256).max)
            }));
        }
    }

    // Give `voter` the right to vote on this ballot.
    // May only be called by `chairperson`.
    function giveRightToVote(address voter) external {
        // new U256Cumulative(1, type(uint256).max);
        // If the first argument of `require` evaluates
        // to `false`, execution terminates and all
        // changes to the state and to Ether balances
        // are reverted.
        // This used to consume all gas in old EVM versions, but
        // not anymore.
        // It is often a good idea to use `require` to check if
        // functions are called correctly.
        // As a second argument, you can also provide an
        // explanation about what went wrong.
        // require(
        //     msg.sender == chairperson,
        //     "Only chairperson can give right to vote."
        // );
        require(
            !voters[voter].voted,
            "The voter already voted."
        );
        // require(voters[voter].weight == 0);
        // voters[voter].weight = 1;

        require(address(voters[voter].weight) == address(0));
        voters[voter].weight = new U256Cumulative(0, type(uint256).max);
        voters[voter].weight.add(1);
    }

    /// Delegate your vote to the voter `to`.
    function delegate(address to) external {
        // assigns reference
        Voter storage sender = voters[msg.sender];
        require(sender.weight.get() != 0, "You have no right to vote");
        require(!sender.voted, "You already voted.");

        require(to != msg.sender, "Self-delegation is disallowed.");

        // Forward the delegation as long as
        // `to` also delegated.
        // In general, such loops are very dangerous,
        // because if they run too long, they might
        // need more gas than is available in a block.
        // In this case, the delegation will not be executed,
        // but in other situations, such loops might
        // cause a contract to get "stuck" completely.
        while (voters[to].delegate != address(0)) {
            to = voters[to].delegate;

            // We found a loop in the delegation, not allowed.
            require(to != msg.sender, "Found loop in delegation.");
        }

        Voter storage delegate_ = voters[to];

        // Voters cannot delegate to accounts that cannot vote.
        // require(delegate_.weight >= 1);
        require(delegate_.canDelegata);

        // Since `sender` is a reference, this
        // modifies `voters[msg.sender]`.
        sender.voted = true;
        sender.delegate = to;

        if (delegate_.voted) {
            // If the delegate already voted,
            // directly add to the number of votes
            // proposals[delegate_.vote].voteCount.add(sender.weight);

            proposals[delegate_.vote].voteCount.add(sender.weight.get());

        } else {
            // If the delegate did not vote yet,
            // add to her weight.
            // delegate_.weight += sender.weight;

            delegate_.weight.add(sender.weight.get());
        }
    }

    /// Give your vote (including votes delegated to you)
    /// to proposal `proposals[proposal].name`.
    function vote(address voterAddr, uint proposal) external {
        Voter storage sender = voters[voterAddr];
        require(sender.weight.get() != 0, "Has no right to vote");
        require(!sender.voted, "Already voted.");
        sender.voted = true;
        sender.vote = proposal;
 
        // If `proposal` is out of the range of the array,
        // this will throw automatically and revert all
        // changes.
        proposals[proposal].voteCount.add(sender.weight.get());
    }

    /// @dev Computes the winning proposal taking all
    /// previous votes into account.
    function winningProposal() public 
            returns (uint winningProposal_)
    {
        uint winningVoteCount = 0;
        for (uint p = 0; p < proposals.length; p++) {
            if (proposals[p].voteCount.get() > winningVoteCount) {
                winningVoteCount = proposals[p].voteCount.get();
                winningProposal_ = p;
            }
        }
    }

    // Calls winningProposal() function to get the index
    // of the winner contained in the proposals array and then
    // returns the name of the winner
    function winnerName() external 
            returns (bytes32 winnerName_)
    {
        winnerName_ = proposals[winningProposal()].name;
    }

    function checkBallot(uint256 idx) public returns (uint256)  {
        return proposals[idx].voteCount.get(); 
    }
}