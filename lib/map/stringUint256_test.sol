// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0 <0.9.0;

import "./StringUint256.sol";
import "../multiprocess/Multiprocess.sol";

contract StringUint256MapTest {
    StringUint256Map map = new StringUint256Map();
    constructor() {     
        string memory k1 = "0x33333378901234567890123456789012345678900x3333337890123456789012345678901234567890";
        string memory k2 = "0x123";
        string memory k3 = "0x3333337890123456789012345678901234567890";
        string memory k4 = "0x333333";

        require(map.length() == 0); 
        map.set(k1, 11);
        map.set(k2, 22);
        map.set(k3, 33);
        require(map.length() == 3); 
       
        require(map.exist(k1)); 
        require(map.exist(k2)); 
        require(map.exist(k3)); 
        require(!map.exist(k4)); 

        require(map.get(k1) == 11); 
        require(map.get(k2) == 22); 
        require(map.get(k3) == 33); 

        require(map.valueAt(0) == 11); 
        require(map.valueAt(1) == 22); 
        require(map.valueAt(2) == 33); 

        require(keccak256(bytes(map.keyAt(0))) == keccak256(bytes(k1))); 
        require(keccak256(bytes(map.keyAt(1))) == keccak256(bytes(k2))); //  cause error
        require(keccak256(bytes(map.keyAt(2))) == keccak256(bytes(k3))); 

        map.del(k1);
        map.del(k2);
        map.del(k3);
        require(map.length() == 0); 
    }
}
