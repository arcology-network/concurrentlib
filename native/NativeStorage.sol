// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.19;

contract NativeStorage {   
        uint256 x = 1 ;
        uint256 y = 100 ;
        uint256[3] public shortArr;
        uint256[32] public mediumArr;
        uint256[33] public longArr;

   constructor() { 
        incrementX();
        incrementY();
        require(x == 2);
        require(y == 102);   

        shortArr[2] = 1;
        mediumArr[31] = 1;
        longArr[32] = 1;
   }

   function call() public{
        incrementX();
        incrementY();
        require(x == 3);
        require(y == 104);

        require(shortArr[2] == 1);
        require(mediumArr[31] == 1);
        require(longArr[32] == 1);        
   }

    function incrementX() public {
        x ++;
    }

    function incrementY() public {
       y += 2;
    }

    function checkX(uint256 value) view public {
        require(x == value);
    }

    function checkY(uint256 value) view public {
         require(y == value);
    }
}

contract TestFailed {   
     uint256 x = 1;
     uint256 y = 100;

     constructor() {}

     function call() public {
          require(x == 1);
     }
}


