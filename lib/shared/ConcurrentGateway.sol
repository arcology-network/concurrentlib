pragma solidity >=0.7.0;

/**
 * @author Arcology Network
 * @title ConcurrentGateway Concurrent Container
 * @dev The ConcurrentGateway contract is a concurrent container designed for concurrent operations,
 *      allowing elements to be added in different processes running in parallel without
 *      causing state conflicts. It provides functionalities for both key-value lookup and
 *      linear access.
 *
 *      The contract serves as a hybrid data structure, functioning as a map set behind the scenes.
 *      The order of elements is formed when any timing-dependent functions like "delLast()" or "nonNilCount()"
 *      are called. However, performing concurrent "delLast()" or getting the length is not recommended in
 *      a parallel environment, as these operations are timing-independent and may lead to conflicts. 
 *      Transactions resulting conflicts will be reverted to protect the state consistency.
 *
 *      Delopers should exercise caution when accessing the container concurrently to avoid conflicts.
 */
contract ConcurrentGateway {
    address public API;

    /**
     * @notice Constructor to initiate communication with the external contract.
     */
    constructor (uint8 typeID , address APIAddr, bool isTransient) {
        API = APIAddr; // Need to set the address for the other functions to work properly.
        (bool success,) = address(API).call(abi.encodeWithSignature(
            "new(uint8,bool)", uint8(typeID), isTransient)); // A false value indicates it is NOT a transient container.
        require(success);
    }

    function eval(bytes memory command) public returns(bool, bytes memory) {
        return address(API).call(abi.encodeWithSignature("eval(bytes)", command));  
    }  
}
