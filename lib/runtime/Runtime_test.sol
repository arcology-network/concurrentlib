// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0 <0.9.0;

import "./Runtime.sol";
import "../multiprocess/Multiprocess.sol";
import "../commutative/U256Cum.sol";

contract NumConcurrentInstanceTest  {   
    U256Cumulative value = new U256Cumulative(1, 100);

    function call() public {
        Multiprocess mp = new Multiprocess(2); // 2 Threads
        mp.push(4000000, address(this), abi.encodeWithSignature("init(uint256)", 11)); // Will require about 1.5M gas
        mp.push(4000000, address(this), abi.encodeWithSignature("init(uint256)", 12));
        mp.run();
        require(value.get() == 0);
    }

    function init(uint256 v) public {
        if (Runtime.instances(address(this), bytes4(keccak256(bytes("init(uint256)")))) == 0) {
            value.add(v);    
        }
    }
}

contract DeferredTest  {
    U256Cumulative value = new U256Cumulative(1, 100);

    constructor () {
        Runtime.deferred(bytes4(keccak256(bytes("init(uint256)"))));
    }

    function init(uint256 v) public {
        bytes4 funSign = bytes4(keccak256(bytes("init(uint256)")));
        if (Runtime.instances(address(this),funSign) == 0) {
            value.add(v);    
        }
    }
}

contract SequentializerTest  {
    address addr1 = 0x1111111110123456789012345678901234567890;
    address addr2 = 0x2222222220123456789012345678901234567890;
    address addr3 = 0x3333337890123456789012345678901234567890;
    address addr4 = 0x4444444890123456789012345678901234567890;

    constructor () {
        bytes4[] memory otherFuncs = new bytes4[](3);
        otherFuncs[0] = 0x01010101;
        otherFuncs[1] = 0x02020202;   
        otherFuncs[2] = 0x03030303;       

        // The init() function of the current contract cannot be called in parallel with 
        // the otherFuncs functions of the addr1 contract.
        require(Runtime.sequentialize(bytes4(keccak256("init()")), addr1, otherFuncs));
        require(Runtime.deferred(bytes4(keccak256("init()"))));
    }

    function init() public {}
    function seq() public {}
    function def() public {}
}

contract ParallizerTest  {
    address addr1 = 0x1111111110123456789012345678901234567890;
    address addr2 = 0x2222222220123456789012345678901234567890;
    address addr3 = 0x3333337890123456789012345678901234567890;
    address addr4 = 0x4444444890123456789012345678901234567890;

    constructor () {
        bytes4[] memory otherFuncs = new bytes4[](3);
        otherFuncs[0] = 0x01010101;
        otherFuncs[1] = 0x02020202;   
        otherFuncs[2] = 0x03030303;       

        // Only the init() function of the current contract can be called in parallel with the others.
        require(Runtime.parallelize(bytes4(keccak256("init()")), addr1, otherFuncs));
        require(Runtime.deferred(bytes4(keccak256("def()"))));
    }

    function init() public {}
    function seq() public {}
    function def() public {}
}