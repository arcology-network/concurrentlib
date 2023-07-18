// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.19;

contract U256Cumulative {
    address constant public API = address(0x85);    

    constructor (uint256 minv, uint256 maxv) {
        (bool success,) = address(API).call(abi.encodeWithSignature("New(uint256, uint256, uint256)", minv, maxv));
        assert(success);
    }

    function peek() public returns(uint256) {  
        (,bytes memory data) = address(API).call(abi.encodeWithSignature("peek()"));
        return abi.decode(data, (uint256));
    }
    
    function get() public returns(uint256) {  
        (,bytes memory data) = address(API).call(abi.encodeWithSignature("get()"));
        return abi.decode(data, (uint256));
    }

    function add(uint256 v) public returns(bool) { 
        (bool success,) = address(API).call(abi.encodeWithSignature("add(uint256)", v));
        return success; 
    }

    function sub(uint256 v) public returns(bool) { 
        (bool success,) = address(API).call(abi.encodeWithSignature("sub(uint256)", v));
        return success;
    }   

    function min() public returns(uint256) { 
        (, bytes memory data) = address(API).call(abi.encodeWithSignature("min()"));
        return abi.decode(data, (uint256));
    }  

    function max() public returns(uint256) { 
        (, bytes memory data) = address(API).call(abi.encodeWithSignature("max()"));
        return abi.decode(data, (uint256));
    }    
}
