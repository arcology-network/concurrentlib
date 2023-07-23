# Concurrent Lib 
This repository contains a set of Solidity API utilizing its parallel execution design to enable concurrent operations on data structures. They are the gateways for Solidity smart contract developers to fully utilize the power of Arcology's parallel execution capabilities.

## 1. Contracts
Please check the [doc](https://doc.arcology.network/concurrent-programming-guide/) for more details.

## 2. Examples

There are two examples  U256ParaCompute and CumulativeU256ParaCompute, demonstrate the use of the Multiprocess and cumulative u256 libraries together.

```js
contract U256ParaCompute {
    uint256 num = 0;

    function calculate() public {     
        Multiprocess mp = new Multiprocess(2);  // Create Multiprocess instance with 2 threads
        mp.push(200000, address(this), abi.encodeWithSignature("add(uint256)", 2)); 
        mp.push(200000, address(this), abi.encodeWithSignature("add(uint256)", 2));
        mp.run(); 			            // Call the functions in parallel
        require(num == 2);                      // Ensure that the 'num' variable is 2
    }

    function add(uint256 elem) public {         // Perform addition to the 'num' variable
        num += elem;
    }  
}
```
```js
// Example contract using the Multiprocess library and U256Cumulative for cumulative operations
// to perform parallel additions and ensure state consistency
contract CumulativeU256ParaCompute {
    U256Cumulative cumulative = new U256Cumulative(0, 100);  // Concurrent uint256

    function calculate() public {       
        Multiprocess mp = new Multiprocess(2);   // Create Multiprocess instance with 2 threads
        mp.push(200000, address(this), abi.encodeWithSignature("add(uint256)", 2));     
        mp.push(200000, address(this), abi.encodeWithSignature("add(uint256)", 2));   
        mp.run();   					// Call the functions in parallel
        require(cumulative.get() == 4);         // Ensure that the cumulative value is 4
    }

    function add(uint256 elem) public { 
        cumulative.add(elem);                   // Perform addition to the variable
    }  
}
```

###  2.2. Analysis:

The main difference between the two contracts is how they handle the concurrent state changes during concurrent execution. In `U256ParaCompute`, the num variable is a regular state variable, and concurrent execution of the add function results in a race condition. Arcology's concurrency will detect it at runtime and revert the execution of one transtions. As a result, the final value of num only reflects the delta change from one call.

In `CumulativeU256ParaCompute`, the U256Cumulative container handles concurrent delta changes. It allows concurrent additions and subtractions to the value and prevents any out-of-bounds changes. Therefore, the cumulative value correctly reflects the sum of the two `add()` calls, which is 4. Only the U256Cumulative container ensures thread safety and provides the expected result.

##  3. Benchmark
- [Reverse String](https://doc.arcology.network/concurrent-programming-guide/benchmark/reverse-string)
