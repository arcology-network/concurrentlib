// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0 <0.9.0;
import "../runtime/Runtime.sol";

contract BaseTest {    
    address constant public API = address(0x84); 

    uint[] public arr2 = [1, 2, 3];
    bytes private id;

    // event logMsg(string message);

    constructor() {
        (bool success, bytes memory data) = address(API).call(abi.encodeWithSignature("new(uint8,bytes,bytes)"));       
        require(success, "Bytes.New() Failed");
        id = data;
 
        bytes memory arr1 = '11111111111111111111111111111111111111111111111';
        bytes memory arr2 = '2222222222222222222222222222222222222222222222222222222222222222222222';
        bytes memory arr3 = '333333333333333333333333333333333333333333333333333333333333333333333333333333333333333';

        require(committedLength() == 0);  
        require(length() == 0); 
        push(arr1);  
        push(arr2);          
        require(length() == 2); 
        require(committedLength() == 0);  

        require(KeyToInd(indToKey(1)) == 1);
        require(KeyToInd(indToKey(1)) == 1);

        bytes memory byIdx = _get(1);
        bytes memory retrivedByKey = _get(indToKey(1));
        require(keccak256(retrivedByKey) == keccak256(byIdx));

        require(keccak256(byIdx) == keccak256(arr2));

        _set(1, arr3);

        byIdx = _get(0);
        require(keccak256(arr1) == keccak256(byIdx));

        byIdx = _get(1);
        require(keccak256(arr3) == keccak256(byIdx));

        byIdx = _pop();
        require(keccak256(arr3) == keccak256(byIdx));
        require(length() == 1); 

        // stored = _get(length() - 1);
        // _del(length() - 1);
        _pop();
        require(length() == 0); 
        push(arr2);  

        require(committedLength() == 0); 
    }

    function call() public{ 
        require(committedLength() == 0); 
        // require(committedLength() == 1); 
        _pop();
        require(committedLength() == 0); 
    }

    function nonexists() public returns(bytes memory) {
        (,bytes memory data) = address(API).call(abi.encodeWithSignature("nonexists()"));   
        return data;     
    }

    function indToKey(uint256 idx) public returns(bytes memory) {
        (,bytes memory data) = address(API).call(abi.encodeWithSignature("keyByIndex(uint256)", idx));   
        return data;     
    }

    function KeyToInd(bytes memory key) public returns(uint256) {
        (,bytes memory data) = address(API).call(abi.encodeWithSignature("indexByKey(bytes)", key));   
        return uint256(bytes32(data));     
    }

    function committedLength() public returns(uint256) {
        (,bytes memory data) = address(API).call(abi.encodeWithSignature("committedLength()"));
        if (data.length > 0) {
            return abi.decode(data, (uint256));   
        }
        return 0;    
    }

    function length() public returns(uint256) {
        (bool success, bytes memory data) = address(API).call(abi.encodeWithSignature("length()"));
        require(success, "Bytes.length() Failed");
        return  abi.decode(data, (uint256));
    }

    function _pop() public virtual returns(bytes memory) { 
        (,bytes memory data) = address(API).call(abi.encodeWithSignature("pop()"));
        return data;
    }

    function push(bytes memory elem) public {
        _set(Runtime.uuid(), (elem));
    }   
    
    function _set(uint256 idx, bytes memory encoded) public { 
        address(API).call(abi.encodeWithSignature("setIndex(uint256,bytes)", idx, encoded));     
    }

    function _set(bytes memory key, bytes memory elem) public {
        address(API).call(abi.encodeWithSignature("setKey(bytes,bytes)", key, elem));
    }

    // function _del(uint256 idx) public { 
    //     address(API).call(abi.encodeWithSignature("delIndex(uint256)", idx));     
    // }

    // function _del(bytes memory key) public {
    //     address(API).call(abi.encodeWithSignature("delIndex(bytes)", key));
    // }

    function _get(uint256 idx) public virtual returns(bytes memory) {
        (bool success, bytes memory data) = address(API).call(abi.encodeWithSignature("getIndex(uint256)", idx));
        if (success) {
            return data;  
        }
        return data;
    }

    function _get(bytes memory key) public returns(bytes memory)  {
        (bool success, bytes memory data) = address(API).call(abi.encodeWithSignature("getKey(bytes)", key));
        if (success) {
            return data;  
        }
        return data;
    }

    function clear() public {
        (bool success, bytes memory data) = address(API).call(abi.encodeWithSignature("clear()"));
        require(success, "Bytes._set() Failed");
    }
}
