// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.19;
import "../runtime/Runtime.sol";

contract BaseTest is Runtime{    
    address constant public API = address(0x84); 

    uint[] public arr2 = [1, 2, 3];
    bytes private id;

    // event logMsg(string message);

    constructor() {
        (bool success, bytes memory data) = address(API).call(abi.encodeWithSignature("new()"));       
        require(success, "Bytes.New() Failed");
        id = data;
 
        bytes memory arr1 = '11111111111111111111111111111111111111111111111';
        bytes memory arr2 = '2222222222222222222222222222222222222222222222222222222222222222222222';
        bytes memory arr3 = '333333333333333333333333333333333333333333333333333333333333333333333333333333333333333';

        require(peek() == 0);  
        require(length() == 0); 
        push(arr1);  
        push(arr2);          
        require(length() == 2); 
        require(peek() == 0);  

        require(indexByKey(keyByIndex(1)) == 1);
        require(indexByKey(keyByIndex(1)) == 1);

        bytes memory byIdx = getByIndex(1);
        bytes memory retrivedByKey = getByKey(keyByIndex(1));
        require(keccak256(retrivedByKey) == keccak256(byIdx));

        require(keccak256(byIdx) == keccak256(arr2));

        // address(0x60).call(stored);
        // address(0x60).call(retrivedByKey);

        setByIndex(1, arr3);

        byIdx = getByIndex(0);
        require(keccak256(arr1) == keccak256(byIdx));

        byIdx = getByIndex(1);
        require(keccak256(arr3) == keccak256(byIdx));

        byIdx = popBack();
        require(keccak256(arr3) == keccak256(byIdx));
        require(length() == 1); 

        // stored = getByIndex(length() - 1);
        delByIndex(length() - 1);
        require(length() == 0); 
        push(arr2);  

        byIdx = getByIndex(0);
        require(keccak256(arr2) == keccak256(byIdx));
        require(peek() == 0);  
        require(length() == 1); 
    }

    function call() public{ 
        require(peek() == 1); 
        popBack();
        require(peek() == 1); 
    }

    function keyByIndex(uint256 idx) public returns(bytes memory) {
        (,bytes memory data) = address(API).call(abi.encodeWithSignature("keyByIndex(uint256)", idx));   
        return data;     
    }

    function indexByKey(bytes memory key) public returns(uint256) {
        (,bytes memory data) = address(API).call(abi.encodeWithSignature("indexByKey(bytes)", key));   
        return uint256(bytes32(data));     
    }

    function peek() public returns(uint256) {
        (,bytes memory data) = address(API).call(abi.encodeWithSignature("peek()"));
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

    function popBack() public virtual returns(bytes memory) { // 80 26 32 97
        bytes memory v = getByIndex(length() - 1);
        delByIndex(length() - 1);
        return v;
    }

    function push(bytes memory elem) public {
        setByKey(uuid(), (elem));
    }   
    
    function setByIndex(uint256 idx, bytes memory encoded) public { // 7a fa 62 38
        address(API).call(abi.encodeWithSignature("setIndex(uint256,bytes)", idx, encoded));     
    }

    function setByKey(bytes memory key, bytes memory elem) public {
        address(API).call(abi.encodeWithSignature("setKey(bytes,bytes)", key, elem));
    }

    function delByIndex(uint256 idx) public { // 7a fa 62 38
        address(API).call(abi.encodeWithSignature("delIndex(uint256)", idx));     
    }

    function delByIndex(bytes memory key) public {
        address(API).call(abi.encodeWithSignature("delIndex(bytes)", key));
    }

    function getByIndex(uint256 idx) public virtual returns(bytes memory) { // 31 fe 88 d0
        (bool success, bytes memory data) = address(API).call(abi.encodeWithSignature("getIndex(uint256)", idx));
        if (success) {
            return data;  
        }
        return data;
    }

    function getByKey(bytes memory key) public returns(bytes memory)  {
        (bool success, bytes memory data) = address(API).call(abi.encodeWithSignature("getKey(bytes)", key));
        if (success) {
            return data;  
        }
        return data;
    }

    function clear() public {
        (bool success, bytes memory data) = address(API).call(abi.encodeWithSignature("clear()"));
        require(success, "Bytes.setByIndex() Failed");
    }
}
