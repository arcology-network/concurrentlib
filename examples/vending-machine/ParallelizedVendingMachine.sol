// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.7;

import "../../lib/map/AddressU256Cum.sol";

contract VendingMachine {

    // Declare state variables of the contract
    address public owner;
    // mapping (address => U256Cum) public cupcakeBalances;
    // We use an AddressU256CumMap to store cupcake balances instead of a mapping
    // The data structure has the advantage of being able to efficiently handle
    // concurrent updates to the same entry.
    AddressU256CumMap cupcakeBalances = new AddressU256CumMap();

    // When 'VendingMachine' contract is deployed:
    // 1. set the deploying address as the owner of the contract
    // 2. set the deployed smart contract's cupcake balance to 100
    constructor() {
        owner = msg.sender;

        // Set the smart contract's cupcake balance to 100, the lower bounds
        // is 0 and the upper bounds is type(uint256).max
        cupcakeBalances.set(address(this), 100, 0, type(uint256).max);
    }

    // Allow the owner to increase the smart contract's cupcake balance
    function refill(uint amount) public {
        require(msg.sender == owner, "Only the owner can refill.");
        cupcakeBalances.set(address(this), amount); // Set the delta amount through an overloaded function.
    }

    // Allow anyone to purchase cupcakes
    function purchase(uint amount) public payable {
        require(msg.value >= amount * 1 ether, "You must pay at least 1 ETH per cupcake");
        cupcakeBalances[address(this)].sub(amount);
        cupcakeBalances[msg.sender].add(amount);
    }
}