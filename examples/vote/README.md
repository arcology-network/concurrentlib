# Voting
- [Voting](#voting)
  - [1. Parallization Strategy](#1-parallization-strategy)
  - [2. Code Analysis](#2-code-analysis)
    - [2.1. Proposals](#21-proposals)
    - [2.2. Voter](#22-voter)
    - [2.3. Functions](#23-functions)
  - [3. Solution](#3-solution)
  - [4. Contracts](#4-contracts)
  - [5. Performance](#5-performance)

Here we domonstrate how to use Arcology's concurrentlib to make an [Ethereum example](https://docs.soliditylang.org/en/v0.8.21/solidity-by-example.html#voting) contract concurrently executable.


## 1. Parallization Strategy

The key to make this contract concurrent concurrently executable is to make sure that the contract's shared state is not modified by concurrent transactions. We need to identify the shared state of the contract and how they are modified by the contract's functions. Once this is done, we can use Arcology's concurrentlib to replace the shared state with [concurrent data structures or variables]().

## 2. Code Analysis

This is a simple voting contract that stores a list of proposals, and for each proposal, a list of votes. Each vote is weighted by the number of tokens the voter holds. The winning proposal is the one with the most votes weighted by the number of tokens the voter holds.

### 2.1. Proposals

In this contract, the shared state is the list of proposals and the list of votes for each proposal. The proposals are stored in a dynamic array. The constructor is only invoked once, so the initialization of the proposals is not a problem. 

```solidity
struct Proposal {
        bytes32 name;   // short name (up to 32 bytes)
        uint voteCount; // number of accumulated votes
    }
```
The real problem is that the `voteCount` of each proposal is modified by the `vote()` function. If the `vote()` function is called concurrently by multiple voters, the `voteCount` will be modified concurrently. This, of course, is not allowed.

The votes for each proposal are stored in a mapping, and in Solidity, entries in a mapping are occupying different storage slots. So the votes for each proposal are not shared state.

### 2.2. Voter

It is possible that a voter delegating other voters to vote on they. When multiple voters are delegating their votes to the same voter simultaneously by calling the `delegate()` function, the `weight` of the voter will be modified concurrently. This is another contention point that needs to be addressed.

```solidity
   struct Voter {
        uint weight; // weight is accumulated by delegation
        bool voted;  // if true, that person already voted
        address delegate; // person delegated to
        uint vote;   // index of the voted proposal
    }
```

### 2.3. Functions

There are five functions in this contract:


| Function Name          | Shared State        | Concurrency Enabled | Description                      |
|------------------------|---------------------|----------------------|---------------------------------|
| `constructor()`        | N/A                 | No                   | Only called once.               |
| `giveRightToVote()`    | `Voter List`        | No                   | Called by the chairperson       |
| `winnerName()`         | No                  | No                   | A view function only            |
| `winningProposal()`    | No                  | No                   | A view function only.           |
| `vote()`               | `voteCount`         | Yes                  | Needs to be replaced            |
| `delegate()`           | `weight`            | Yes                  | Needs to be replaced            |


## 3. Solution

Arcology's concurrentlib provides a set of concurrent data structures and variables allowing concurrent manipulations. In the parallelized version of the contract, we make the following replacements to the original contract:

- Replaced the `voteCount` with a [cumulative uint256](https://doc.arcology.network/arcology-concurrent-programming-guide/data-structure/commutative/cumulative-u256) variable.
  
- Added a boolean variable `canDelegata` to the `Voter` struct to indicate whether the voter can delegate others' votes. 
  
```solidity
    struct Voter {
        U256Cumulative weight; // weight is accumulated by delegation
        bool voted;  // if true, that person already voted
        bool canDelegata; // If this voter can others
        address delegate; // person delegated to
        uint vote;   // index of the voted proposal
    }
```

- Replaced the `weight` a [`]cumulative uint256]() variable.
  
```solidity
    struct Proposal {
        bytes32 name;   // short name (up to 32 bytes)
        U256Cumulative voteCount;
    }
```

## 4. Contracts

* [Original Contract](./contracts/Vote.sol)
* [Parallelized Contract](./contracts/ParallelVote.sol)
* [Parallelized Contract specficly for the multiprocessor](./contracts/VoteMp.sol)

## 5. Performance

The following table shows the performance comparison of the original contract and the parallelized contract. The parallelized contract is executed on a 8-core machine.

| Function Name          | Original Contract   | Parallelized Contract | Speedup |
|------------------------|---------------------|-----------------------|---------|
| `giveRightToVote()`    | 0.000000            | 0.000000              | 0.00    |
| `vote()`               | 0.000000            | 0.000000              | 0.00    |
| `delegate()`           | 0.000000            | 0.000000              | 0.00    |
