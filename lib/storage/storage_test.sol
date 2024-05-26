// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0 <0.9.0;

import "./Storage.sol";
import "../array/Bool.sol";
import "../commutative/U256Cum.sol";


contract ResettableDeployer {
    TestResettable resettable;
    constructor () {
        resettable = new TestResettable();
        resettable.set();
    }
    
    // This is invalid and will not compile
    function call () public {
        resettable.afterCheck();
    }
}

contract TestResettable {
    uint256[] arr;
    uint256 [2] public array; 
    mapping (uint256 => bool) hashmap;

    constructor () {
        arr = new uint256[](0);
        arr.push(99);
        arr.push(127);

        array[0] = 10;
        array[1] = 11;     

        hashmap[123] = true;
        hashmap[456] = false;
        hashmap[890] = true;
    }

    function set() public {
        require(array[0] == 10);
        require(array[1] == 11);   
    }

    function afterCheck() public {
        require(array[0] == 10);
        require(array[1] == 11);   
        Storage.rollback();  

        require(array[0] == 10);
        require(array[1] == 11);   
        
        array[0] = 100;
        array[1] = 111;
   
        require(array[0] == 100);
        require(array[1] == 111);
        Storage.rollback();  

        require(array[0] == 10);
        require(array[1] == 11);  
    }
}





// contract TestImmutable {
//     // uint256 public immutable a;
//     // This is a valid constructor
//     constructor () {
//         address(0xa0).call(abi.encodeWithSignature("Reset()"));
//     }
    
//     // This is invalid and will not compile
//     function afterCheck () public {
//         address(0xa0).call(abi.encodeWithSignature("Reset()"));
//     }
// }