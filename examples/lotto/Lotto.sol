pragma solidity >=0.8.0 <0.9.0;

import "../../lib/array/Bytes32.sol";
import "../../lib/set/Set.sol";

contract Lotto {
    // The keyword "public" makes variables
    // accessible from other contracts
    address public minter;
    uint256 maxParticipants = 5;
    Bytes32 participants = new Bytes32();

    // Constructor code is only run when the contract
    // is created
    constructor() {}
    
    // Sends an amount of newly created coins to an address
    // Can only be called by the contract creator
    function Register(address participant, uint amount) public {
        require(participants.indexByKey(participant) >= participants.length());
        participants.push()
        // require(msg.sender == minter);
        // require(amount < 1e60);
        // balances[receiver] += amount;
    }

    // Sends an amount of existing coins
    // from any caller to an address
    function send(address receiver, uint amount) public {
        require(amount <= balances[msg.sender], "Insufficient balance.");
        balances[msg.sender] -= amount;
        balances[receiver] += amount;
        emit Sent(msg.sender, receiver, amount);
    }

    // Additional function to query the balance of a specific address.
    function getter(address addr) public view returns(uint256) {
        return balances[addr];
    }
}