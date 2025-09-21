pragma solidity >=0.7.0;

/**
 * @author Arcology Network
 * @title Gateway Concurrent Container
 * @dev The Gateway contract is a concurrent container designed for concurrent operations,
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
contract Gateway {
    address public API;

    /**
     * @notice Constructor to initiate communication with the external contract.
     */
    constructor (uint8 typeID , address APIAddr, bool isBlockBound) {
        API = APIAddr; // Need to set the address for the other functions to work properly.
        (bool success,) = address(API).call(abi.encodeWithSignature(
            "new(uint8,bool)", uint8(typeID), isBlockBound)); // A false value indicates it is NOT a transient container.
        require(success);
    }

    /**
     * @notice Set the transient state of the container. If the container is transient, it is only
     *         accessible within the current BLOCK. After the block is finalized, the container will
     *         be reset automatically.
     */
    function markBlockScoped() public returns(uint256) {
        (,bytes memory data) = eval(abi.encodeWithSignature("markBlockScoped()"));
        return abi.decode(data, (uint256));
    } 

    function eval(bytes memory command) public returns(bool, bytes memory) {
        return address(API).call(abi.encodeWithSignature("eval(bytes)", command));  
    }  
}
