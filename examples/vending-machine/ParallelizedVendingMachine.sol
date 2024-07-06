pragma solidity 0.8.7;

import "@arcologynetwork/concurrentlib/lib/commutative/U256Cum.sol";

contract VendingMachine {

    // Declare state variables of the contract
    address public owner;
    mapping (address => U256Cum) public cupcakeBalances;

    // When 'VendingMachine' contract is deployed:
    // 1. set the deploying address as the owner of the contract
    // 2. set the deployed smart contract's cupcake balance to 100
    constructor() {
        owner = msg.sender;
        cupcakeBalances[address(this)] = new U256Cum(0, 100);
    }

    // Allow the owner to increase the smart contract's cupcake balance
    function refill(uint amount) public {
        require(msg.sender == owner, "Only the owner can refill.");
        cupcakeBalances[address(this)].add(amount);
    }

    // Allow anyone to purchase cupcakes
    function purchase(uint amount) public payable {
        require(msg.value >= amount * 1 ether, "You must pay at least 1 ETH per cupcake");
        cupcakeBalances[address(this)].sub(amount);
        cupcakeBalances[msg.sender].add(amount);
    }
}