// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0;


import "../shared/Const.sol"; 
import "../shared/Base.sol";

/**
 * @author Arcology Network
 * @title Concurrent Array for Cumulative uint256 
 * @dev The uint256 contract is a concurrent array specialized for storing uint256 data.
 *      It inherits from the Base contract to utilize container functionalities for uint256 storage.
 *      It can only store positive integers within the lower and upper bounds. The lower bound must be less than the upper bound and they must be both positive.
 */
contract U256Cum is Base {
    constructor(bool isTransient) Base(Const.U256_CUM, isTransient) {}

    /**
     * @notice push an uint256 data element to the concurrent array.
     * @param value The uint256 data element to add to the array.
     */
    function push(uint256 value, uint256 lower, uint256 upper) public virtual returns(bool){ 
        require(value >= lower, "SafeConversion: Underflow");
        require(value <= upper, "SafeConversion: Overflow");

        bytes memory key = uuid();
        if (!_init(key, abi.encodePacked(lower), abi.encodePacked(upper))) {
            return false;
        }
        return _set(key, abi.encodePacked(int256(value)));
    }    

    /**
     * @notice Remove and return the last uint256 data element from the concurrent array.
     * @return The last uint256 data element from the array.
     */
    function delLast() public virtual returns(uint256) { 
        return abi.decode(Base._delLast(), (uint256));  
    }

    /**
     * @notice Retrieve the uint256 data element at the given index from the concurrent array.
     * @param idx The index of the uint256 data element to retrieve.
     * @return The uint256 data element stored at the given index.
     */
    function get(uint256 idx) public virtual returns(uint256)  {
        (bool exist, bytes memory data) = Base._get(idx);
        if(exist)
            return abi.decode(data, (uint256)); 
        else
            return  uint256(0);
    }

    /**
     * @notice Get the data at the given index from the container, returning a boolean indicating success.
     * @param idx The index of the data to retrieve.
     * @return The data stored at the specified index.
     */
    function at(uint256 idx) public returns(bool, uint256) {
        (bool success, bytes memory data) = Base._get(idx);
        if(success)
            return (success,abi.decode(data, (uint256))); 
        else
            return  (success,uint256(0));
    }

    /**
     * @notice Set the uint256 data element at the given index in the concurrent array.
     * @param idx The index where the uint256 data element should be stored.
     * @param delta The uint256 data element to be stored at the specified index.
     */
    function set(uint256 idx, int256 delta) public returns(bool) { 
        return _set(idx, abi.encodePacked(delta));  
    }
}
