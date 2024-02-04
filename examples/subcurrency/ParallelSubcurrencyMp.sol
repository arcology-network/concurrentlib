// This is a parallel subcurrency example from the Solidity documentation. 
// The original contract can be found here: https://docs.soliditylang.org/en/latest/introduction-to-smart-contracts.html#subcurrency-example

// It is modified to be used in conjunction with the multiprocessor library from the Arcology Network.
// This is for internal testing purposes only and should not be used in a production environment.

// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0 < 0.8.19;

import "../../lib/commutative/U256Cum.sol";

contract Coin {
    // The keyword "public" makes variables
    // accessible from other contracts
    address public minter;
     mapping(address => U256Cum) public balances;

    // AddressUint256Map public balances;

    // Events allow clients to react to specific
    // contract changes you declare
    event Sent(address from, address to, uint amount);

    // Constructor code is only run when the contract
    // is created
    constructor() {
        minter = msg.sender;
    }

    // Sends an amount of newly created coins to an address
    // Can only be called by the contract creator
    function mint(address minter, address receiver, uint amount) public {
        // require(msg.sender == minter);
        // balances[receiver] += amount;
        balances.get(receiver).add(amount);
    }

    // Errors allow you to provide information about
    // why an operation failed. They are returned
    // to the caller of the function.
    error InsufficientBalance(uint requested, uint available);

    // Sends an amount of existing coins
    // from any caller to an address
    function send(address sender, address receiver, uint amount) public {
        if (amount > balances[msg.sender])
            revert InsufficientBalance({
                requested: amount,
                available: balances[msg.sender]
            });

        balances.get(sender).sub(amount);    
        balances.get(receiver).add(amount);    
        // balances[msg.sender] -= amount;
        // balances[receiver] += amount;
        emit Sent(msg.sender, receiver, amount);
    }
}