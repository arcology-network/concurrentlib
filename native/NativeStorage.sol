// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0;

contract NativeStorage {   
        uint256 x = 1 ;
        uint256 y = 100 ;
     //    uint256[3] public shortArr;
     //    uint256[32] public mediumArr;
     //    uint256[33] public longArr;

   constructor() { 
        incrementX();
        incrementY();
        require(x == 2);
        require(y == 102);   

     //    shortArr[2] = 1;
     //    mediumArr[31] = 1;
     //    longArr[32] = 1;
   }
   function call() public{
        incrementX();
        incrementY();
        require(x == 3);
        require(y == 104);

     //    require(shortArr[2] == 1);
     //    require(mediumArr[31] == 1);
     //    require(longArr[32] == 1);        
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

    function check() public {
     require(x == 3);
     require(y == 104);

     // require(shortArr[2] == 1);
     // require(mediumArr[31] == 1);
     // require(longArr[32] == 1);   
   }

   function call2() public{
     incrementX();
     incrementY();
   }

   function check2() public {
     require(x == 3);
     require(y == 104);
     // require(y == 104);
   }

   function check3() public {
     require(x == 4);
     require(y == 106);
     // require(y == 104);
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


