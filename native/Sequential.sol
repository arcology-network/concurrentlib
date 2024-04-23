// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0 <0.9.0;

contract SequentialTest {   
   uint256 x = 1 ;
   function add() public {
     x += 1;
   }

   function check() public {
     require(x == 2);
   }

  //  function check2() public {
  //   require(false);
  // }
}
