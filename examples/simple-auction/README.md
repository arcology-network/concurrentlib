# Simple Auction

This is another demonstration of a simple Ethereum smart contract that can be parallelized using Arcology's concurrentlib. The original contract is from https://docs.soliditylang.org/en/latest/solidity-by-example.html

## 1. Code Analysis

The first step is to analyze the original contract to identify the shared state and the functions that need to be replaced. There are two shared states in this contract: 

- The list of bidders and the highest bid. The `bid()` function is the only function that modifies the highest bid. If the `bid()` function is called concurrently by multiple bidders, the highest bid will be modified concurrently. 

- The highestBidder is another shared state. The `bid()` function also modifies the highestBidder.

## 2. Solution


