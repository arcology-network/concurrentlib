pragma solidity >=0.8.0 <0.9.0;

import "../../lib/array/Bytes32.sol";
import "../../lib/map/AddressBoolean.sol";

contract Lotto {
    // The keyword "public" makes variables
    // accessible from other contracts
    address public owner;
    uint256 poolSize = 100;
    uint256 maxParticipants = 5;
    AddressBooleanMap registry = new AddressBooleanMap();

    // Constructor code is only run when the contract
    // is created
    constructor() {
        owner = msg.sender;
    }
    
    // Sends an amount of newly created coins to an address
    // Can only be called by the contract creator
    function Register() public {
        if (!registry.exist(msg.sender)) {
            registry.set(msg.sender, true);
        }
        draw();
    }

    // Sends an amount of existing coins
    // from any caller to an address
    function draw() public returns(bool, uint256) {
        if (registry.peek() >= poolSize) {
            return (true, uint256(bytes32(registry.pid())) % poolSize);
        }
        return (false, type(uint256).max);
    }
}