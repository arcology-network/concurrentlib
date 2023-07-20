// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.19;

import "./Multiprocess.sol";
import "../array/U256.sol";
import "../array/Bool.sol";

contract U256ParallelTest {
    U256 container = new U256();

    function call() public  { 
        require(container.length() == 0); 
    
        container.push(uint256(10));
        container.push(uint256(20));
        container.push(uint256(30));
        require(container.length() == 3);

        Multiprocess mp = new Multiprocess(1);
        mp.push(1000000, address(this), abi.encodeWithSignature("push(uint256)", 41));
        mp.push(1000000, address(this), abi.encodeWithSignature("push(uint256)", 51));
        require(mp.length() == 2);
        require(container.length() == 3);

        mp.run();
        require(container.length() == 5);

        require(container.get(0) == uint256(10));
        require(container.get(1) == uint256(20));
        require(container.get(2) == uint256(30));
        require(container.get(3) == uint256(41));   
        require(container.get(4) == uint256(51));  
 
        require(container.pop() == uint256(51));  
        require(container.length() == 4);


        mp.clear();
        mp.push(1000000, address(this), abi.encodeWithSignature("get(uint256)", 0));
        mp.push(1000000, address(this), abi.encodeWithSignature("get(uint256)", 1));
        require(mp.length() == 2);
        mp.run();

        // (bytes memory data) = mp.get(1);
        // require(abi.decode(data, (uint256)) == 20);

        // (data) = mp.get(0);
        // require(abi.decode(data, (uint256)) == 10);

        pop();
        require(container.length() == 3);

        // // Here should be one conflict
        // mp.clear();
        mp.push(100000, address(this), abi.encodeWithSignature("pop()"));
        mp.push(100000, address(this), abi.encodeWithSignature("pop()"));
        mp.run();

        require(container.length() == 1);  // Only one transaction went through, so only one pop() took effect
    }

    function push(uint256 v) public{
        container.push(v);
    }

    function get(uint256 idx) public returns(uint256){
        return container.get(idx);  
    }

    function set(uint256 idx, uint256 v) public {
        return container.set(idx, v);  
    }

    function pop() public {
        container.pop();   
    }
}

contract ArrayParallelTest {
    U256[] array; 

    constructor() {
        array = new U256[](2);
        array[0] = new U256();
        array[1] = new U256();
    }

    function call() public  {
        Multiprocess mp = new Multiprocess(1);
        push(0, 11);
        push(0, 12);

         mp.push(100000, address(this), abi.encodeWithSignature("push(uint256,uint256)", 0, 13));
         mp.push(100000, address(this), abi.encodeWithSignature("push(uint256,uint256)", 0, 14));
         mp.push(100000, address(this), abi.encodeWithSignature("push(uint256,uint256)", 1, 51));
         mp.push(100000, address(this), abi.encodeWithSignature("push(uint256,uint256)", 1, 52));
        require(mp.length() == 4);
        mp.run();

        require(array[0].length() == 4);
        require(array[1].length() == 2);

        require(array[0].get(0) == 11);
        require(array[0].get(1) == 12);
        require(array[0].get(2) == 13);
        require(array[0].get(3) == 14);

        require(array[1].get(0) == 51);
        require(array[1].get(1) == 52);
    }

    function push(uint256 id, uint256 v) public{
        array[id].push(v);
    }

    function get(uint256 id, uint256 idx) public returns(uint256){
        return array[id].get(idx);  
    }

    function set(uint256 id, uint256 idx, uint256 v) public {
        return array[id].set(idx, v);  
    }

    function pop(uint256 id) public {
        array[id].pop();  
    }
}
