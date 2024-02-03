# Simple Auction

- [Simple Auction](#simple-auction)
  - [1. Code Analysis](#1-code-analysis)
    - [1.1. Shared Variables](#11-shared-variables)
    - [1.2. Functions Involved](#12-functions-involved)
  - [2. Parallelized Contract](#2-parallelized-contract)
    - [2.1. Functional Changes](#21-functional-changes)
    - [2.2. Changes to the Original](#22-changes-to-the-original)
  - [3. Performance](#3-performance)


This is another demonstration of a simple Ethereum smart contract that can be parallelized using Arcology's concurrentlib. The original contract is from https://docs.soliditylang.org/en/latest/solidity-by-example.html

## 1. Code Analysis

The first step is to analyze the original contract to identify the shared state and the functions that need to be replaced. The goal is to make the contract concurrently executable by **different bidders**. 

### 1.1. Shared Variables

The `bid()` is the function that modifies the highest bid. If the `bid()` function is called concurrently by multiple bidders, the highest bid will be modified concurrently.  The highestBidder is another shared state. The `bid()` function also modifies the highestBidder.

### 1.2. Functions Involved

| Function Name          | Shared State                        | Concurrency Allowed      | Description       |
|------------------------|-------------------------------------|--------------------------|-------------------|
| `constructor()`        | N/A                                 | No                       | Only called once. |
| `bid()`                | `Voter List`                        | No                       |                   |
| `withdraw()`           | `pendingReturns`, `highestBidder`, `highestBid`     |          |                   |
| `auctionEnd()`         | N/A                                                 |          | Only called once  |


## 2. Parallelized Contract

To make the `bid()` and `withdraw()` functions concurrently executable. A concurrent map in Arcology's concurrentlib is used to store the list of bidders and their bids instead of using single variables to store the highest bid and the highest bidder. The task of calculating the highest bid and the highest bidder is moved to the `auctionEnd()` function when the auction ends. 

The new version is designed to be parallelized and executed on Arcology's platform. 

### 2.1. Functional Changes

The new version is functionally similar to the original version but not the same. Calling the `withdraw()` function isn't permitted before the auction ends. Bidders can no longer withdraw their bids and bid again. This is because the highest bid and the highest bidder are not available at this time.

This would be a issue if the bidders were allowed to increase their bids. However, this is out of the scope of this example.

### 2.2. Changes to the Original

In the parallelized version of the contract is [here](./ParallelSimpleAuction.sol). The following changes have been made to the original contract:

- A concurrent map is used to store the list of bidders and their bids. 

- The `pendingReturns` is removed.
  
- Calling `withdraw()` is no longer allowed before the auction ends.
  
- The highest bid and the highest bidder are calculated in the `auctionEnd()` function when the auction ends.

## 3. Performance

The following table shows the performance comparison of the original contract and the parallelized contract. The parallelized contract is executed on a 8-core machine.

| Function Name          | Original Contract   | Parallelized Contract | Speedup |
|------------------------|---------------------|-----------------------|---------|
| `bid()`                | 0.000000            | 0.000000              | 0.00    |
| `withdraw()`           | 0.000000            | 0.000000              | 0.00    |
