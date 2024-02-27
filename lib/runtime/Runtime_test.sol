// SPDX-License-Identifier: GPL-3.0
pragma solidity >= 0.8.0 < 0.9.0;

import "./Runtime.sol";
import "../multiprocess/Multiprocess.sol";
import "../commutative/U256Cum.sol";

contract NumConcurrentInstanceTest is Runtime {   
    U256Cumulative value = new U256Cumulative(1, 100);

    function call() public{
        Multiprocess mp = new Multiprocess(2); // 2 Threads
        mp.push(4000000, address(this), abi.encodeWithSignature("init(uint256)", 11)); // Will require about 1.5M gas
        mp.push(4000000, address(this), abi.encodeWithSignature("init(uint256)", 12));
        mp.run();
        require(value.get() == 0);

        instances(address(this),bytes4(keccak256(bytes("call()"))));
    }

    function init(uint256 v) public {
        if (instances(address(this),bytes4(keccak256(bytes("init(uint256)")))) == 0) {
            value.add(v);    
        }
    }
}

