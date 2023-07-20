// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.19;

import "./Multiprocess.sol";
import "../commutative/U256Cum.sol";
import "../array/Bool.sol";

contract ParaNativeAssignmentTest {
    uint256[2] results;
    function call() public  { 
       Multiprocess mp = new Multiprocess(2); 
       mp.push(50000, address(this), abi.encodeWithSignature("assigner(uint256)", 0));
       mp.push(50000, address(this), abi.encodeWithSignature("assigner(uint256)", 1));
       require(mp.length() == 2);
       mp.run();

       assert(results[0] == 10);
       assert(results[1] == 11);
    }

    function assigner(uint256 v)  public {
        results[v] = v + 10;
    }
}  
 
contract ParaFixedLengthWithConflictTest {  
     uint256[2] results;
     function call() public  { 
       results[0] = 100;
       results[1] = 200;
       Multiprocess mp = new Multiprocess(2);
       mp.push(400000, address(this), abi.encodeWithSignature("updater(uint256)", 11));
       mp.push(400000, address(this), abi.encodeWithSignature("updater(uint256)", 33));
       mp.push(400000, address(this), abi.encodeWithSignature("updater(uint256)", 55));
       mp.run();     
       require(results[0] == 111);  // 11 and 33 will be reverted due to conflicts
       require(results[1] == 211); 
    }

    function updater(uint256 num) public {
         results[0] += num;
         results[1] += num;
    }
}

contract ParaContainerConcurrentPushTest {
    Bool container = new Bool();
    Bool container2 = new Bool();
    function call() public  { 
       container.push(true);

       Multiprocess mp = new Multiprocess(2);
       mp.push(1000000, address(this), abi.encodeWithSignature("appender()"));
       mp.push(1000000, address(this), abi.encodeWithSignature("appender()"));
       mp.run();
       require(container.length() == 3);    
       require(container2.length() == 2);   
       container.push(true);
       require(container.length() == 4);    
    //    container.push(true);        
    }

    function appender()  public {
       container.push(true);
       container2.push(true);
    }
}

contract MultiTempParaTest {
    Bool container = new Bool();
    bytes32[2] results;
    function call() public  { 
       Multiprocess mp = new Multiprocess(2);
       mp.push(1000000, address(this), abi.encodeWithSignature("appender()"));
       mp.push(4000000, address(this), abi.encodeWithSignature("appender()"));
       mp.run();
       require(container.length() == 2);     

       Multiprocess mp2 = new Multiprocess(2);
       mp2.push(4000000, address(this), abi.encodeWithSignature("appender()"));
       mp2.push(4000000, address(this), abi.encodeWithSignature("appender()"));
       mp2.run();
       require(container.length() == 4);  
    }

    function appender()  public {
       container.push(true);
    }
}

contract MultiGlobalParaSingleInUse {
    Bool container = new Bool();

    Multiprocess mp2;
    Multiprocess mp = new Multiprocess(2);
    function call() public  {  
       mp2 = new Multiprocess(2);
       mp2.push(4000000, address(this), abi.encodeWithSignature("appender()"));
       mp2.run();
       require(container.length() == 2);    
    }

    function appender()  public {
       container.push(true);
       container.push(true);
    }
}

contract MultiGlobalPara {
    Bool container = new Bool();
    
    Multiprocess mp ; 
    Multiprocess mp2;
    function call() public  {  
       mp = new Multiprocess(2);
       mp2 = new Multiprocess(2);
       mp.push(4000000, address(this), abi.encodeWithSignature("appender()"));
       mp.push(4000000, address(this), abi.encodeWithSignature("appender()"));
       mp.run();
       require(container.length() == 2);     
      
       mp2 = new Multiprocess(2);
       mp2.push(4000000, address(this), abi.encodeWithSignature("appender()"));
       mp2.push(4000000, address(this), abi.encodeWithSignature("appender()"));
       mp2.run();
       require(container.length() == 4);  

       container.push(true);
       require(container.length() == 5);  
    }

    function appender()  public {
       container.push(true);
    }
}

contract MultiLocalParaTestWithClear {
    Bool container = new Bool();
    bytes32[2] results;
    function call() public  { 
       Multiprocess mp = new Multiprocess(2);
       mp.push(1000000, address(this), abi.encodeWithSignature("appender()"));
       mp.run();
       require(container.length() == 1);    

       mp.clear();       
       require(mp.length() == 0);   

       mp.push(4000000, address(this), abi.encodeWithSignature("appender()"));
       mp.run();
       require(container.length() == 2);    

       Multiprocess mp2 = new Multiprocess(2);
       mp2.push(4000000, address(this), abi.encodeWithSignature("appender()"));
       mp2.push(4000000, address(this), abi.encodeWithSignature("appender()"));
       mp2.run();
       require(container.length() == 4);  
    }

    function appender()  public {
       container.push(true);
    }
}

contract ParallelizerArrayTest {
    Bool container = new Bool();
    Multiprocess[2] parallelizers;

    function call() public  { 
       parallelizers[0] = new Multiprocess(2);
       parallelizers[0] .push(1000000, address(this), abi.encodeWithSignature("appender()"));
       parallelizers[0] .push(1000000, address(this), abi.encodeWithSignature("appender()"));
       parallelizers[0] .run();
       require(container.length() == 2);  

       parallelizers[1] = new Multiprocess(2);
       parallelizers[1] .push(1000000, address(this), abi.encodeWithSignature("appender()"));
       parallelizers[1] .push(1000000, address(this), abi.encodeWithSignature("appender()"));
       parallelizers[1] .run();
       require(container.length() == 4);  
    }

    function appender()  public {
       container.push(true);
    }
}

contract MultiParaCumulativeU256 {
    U256Cumulative cumulative = new U256Cumulative(0, 100);     
    function call() public {
        Multiprocess mp1 = new Multiprocess(1);
        mp1.push(400000, address(this), abi.encodeWithSignature("add(uint256)", 2));
        mp1.run();

        Multiprocess mp2 = new Multiprocess(1);
        mp2.push(400000, address(this), abi.encodeWithSignature("add(uint256)", 2));
        mp2.run();  

        Multiprocess mp3 = new Multiprocess(1);
        mp3.push(400000, address(this), abi.encodeWithSignature("sub(uint256)", 2));
        mp3.run();   

        add(3);
        require(cumulative.get() == 5);
    }

    function add(uint256 elem) public { //9e c6 69 25
        cumulative.add(elem);
    }  

    function sub(uint256 elem) public { //9e c6 69 25
        cumulative.sub(elem);
    }   
}

contract RecursiveParallelizerOnNativeArrayTest {
    uint256[2] results;
    function call() public {
        Multiprocess mp = new Multiprocess(1);
        mp.push(9999999, address(this), abi.encodeWithSignature("add()")); // Only one will go through
        mp.run();

        require(results[0] == 11);
        require(results[1] == 12);
    } 

    function add() public { //9e c6 69 25
        Multiprocess mp2 = new Multiprocess(1); 
        mp2.push(11111111, address(this), abi.encodeWithSignature("add2()"));
        mp2.run();              
    }  

    function add2() public { 
        results[0] = 11;
        results[1] = 12;
    }  
}

contract RecursiveParallelizerOnContainerTest {
    uint256[2] results;
    Bool container = new Bool();
    U256Cumulative cumulative = new U256Cumulative(0, 100);  

    function call() public {
        Multiprocess mp = new Multiprocess(1);
        mp.push(9999999, address(this), abi.encodeWithSignature("add()")); // Only one will go through
        mp.run();

        require(results[0] == 11);
        require(results[1] == 12);
        require(container.length() == 2);
        require(cumulative.get() == 5);
    } 

    function add() public { //9e c6 69 25
        container.push(true);
        cumulative.add(10);
        Multiprocess mp2 = new Multiprocess(1); 
        mp2.push(11111111, address(this), abi.encodeWithSignature("add2()"));
        mp2.run();              
    }  

    function add2() public {
        container.push(true); 
        cumulative.sub(5);
        results[0] = 11;
        results[1] = 12;
    }  
}

contract MaxRecursiveDepth4Test {
    Bool container = new Bool();

    function call() public {
        // container.push(true);       
        Multiprocess mp = new Multiprocess(1);
        mp.push(99999999, address(this), abi.encodeWithSignature("add()")); // Only one will go through
        mp.push(99999999, address(this), abi.encodeWithSignature("add()")); // Only one will go through
        mp.run();

        require(container.length() == 14); 
        require(container.length() == 14);       
    } 

    function add() public { //9e c6 69 25
        Multiprocess mp2 = new Multiprocess(1); 
        mp2.push(41111111, address(this), abi.encodeWithSignature("add2()"));
        mp2.push(41111111, address(this), abi.encodeWithSignature("add2()"));

        mp2.run();
        mp2.rollback();
        container.push(true);              
    } 

    function add2() public { //9e c6 69 25
        Multiprocess mp2 = new Multiprocess(1); 
        mp2.push(21111111, address(this), abi.encodeWithSignature("add3()"));
        mp2.push(21111111, address(this), abi.encodeWithSignature("add3()"));
        mp2.run();
        mp2.rollback();
        container.push(true);              
    } 

    function add3() public { //9e c6 69 25
        container.push(true);              
    } 
}

contract MaxSelfRecursiveDepth4Test {
    Bool container = new Bool();

    Multiprocess mp;
    function call() public {
        // container.push(true);       
        mp = new Multiprocess(1);
        mp.push(99999999, address(this), abi.encodeWithSignature("add()")); // Only one will go through
        mp.push(99999999, address(this), abi.encodeWithSignature("add()")); // Only one will go through
        mp.run();
        require(container.length() == 30); // 2 + 4 + 8 + 16
    } 

    function add() public { //9e c6 69 25
        Multiprocess mp2 = new Multiprocess(1); 
        mp2.push(41111111, address(this), abi.encodeWithSignature("add()"));
        mp2.push(41111111, address(this), abi.encodeWithSignature("add()"));
        mp2.run();
        mp2.rollback();
        container.push(true);              
    }     
}

contract MaxRecursiveDepthOffLimitTest {
    Bool container = new Bool();
    U256Cumulative cumulative = new U256Cumulative(0, 200);  

    Multiprocess mp;
    function call() public {
        cumulative.add(10);
        require(cumulative.get() == 10);

        container.push(true);       
        mp = new Multiprocess(1);
        mp.push(9999999, address(this), abi.encodeWithSignature("add()"));
        mp.push(9999999, address(this), abi.encodeWithSignature("add()")); 
        mp.run();
  
        require(container.length() == 31); // 1 + (2 + 4 + 8 + 16) 
        // require(cumulative.get() == 50);
    } 

    function add() public { //9e c6 69 25
        cumulative.add(10);
        Multiprocess mp2 = new Multiprocess(1); 
        mp2.push(41111111, address(this), abi.encodeWithSignature("add()"));
        mp2.push(41111111, address(this), abi.encodeWithSignature("add()"));
        mp2.run();
        mp2.rollback();
        container.push(true);              
    }    
}

contract ParaFixedLengthWithConflictRollbackTest {
    Bool container = new Bool();
    // Bool container2 = new Bool();
    function call() public {
        // container = new Bool();
        Multiprocess mp = new Multiprocess(2);
        mp.push(9999999, address(this), abi.encodeWithSignature("worker()")); // Only one will go through
        mp.push(9999999, address(this), abi.encodeWithSignature("worker()")); // Only one will go through
        mp.run();
        require(container.length() == 2);

        appender();
        require(container.length() == 3);
    } 

    function worker() public { //9e c6 69 25
        Multiprocess mp2 = new Multiprocess(2); 
        mp2.push(1999999, address(this), abi.encodeWithSignature("appender()"));
        mp2.run();   
        mp2.rollback();
    }   

    function appender() public { 
        container.push(true);
    }  
}


contract MixedRecursiveMultiprocessTest {
    Bool container = new Bool();
    uint256[2] results;
    U256Cumulative cumulative = new U256Cumulative(0, 100);  
    U256Cumulative cumulative2 = new U256Cumulative(50, 80);  

    Multiprocess mp;
    function call() public {
		mp = new Multiprocess(1);
        cumulative.add(50);
        container.push(true);
        mp.push(9999999, address(this), abi.encodeWithSignature("add()")); // Only one will go through
        mp.push(9999999, address(this), abi.encodeWithSignature("add()")); // Only one will go through
        mp.run();
        require(container.length() == 3);

        require(results[0] == 11);
        require(results[1] == 12);
        require(container.length() == 3);
        require(cumulative.get() == 55);
        require(cumulative2.get() == 70);
    } 

    function add() public { //9e c6 69 25
        cumulative.add(10);
        Multiprocess mp2 = new Multiprocess(1); 
        mp2.push(11111111, address(this), abi.encodeWithSignature("add2()"));
        mp2.run();
        container.push(true);              
    }  

    function add2() public {
        cumulative.sub(5);
        cumulative2.add(70);
        results[0] = 11;
        results[1] = 12;
        container.push(true);
    }  
}

contract ParallelCumulativeU256 {
	U256Cumulative cumulative = new U256Cumulative(0, 100); 
	constructor() {
		require(cumulative.peek() == 0);
		cumulative.add(1);
		cumulative.sub(1);
		require(cumulative.peek() == 0);
	}

	function call() public {
		require(cumulative.peek() == 0);

		Multiprocess mp = new Multiprocess(1);
		mp.push(200000, address(this), abi.encodeWithSignature("add(uint256)", 2));

		mp.push(200000, address(this), abi.encodeWithSignature("add(uint256)", 2));   
		mp.push(200000, address(this), abi.encodeWithSignature("add(uint256)", 1));
		mp.run();
		require(cumulative.get() == 5);

		mp.clear();
		mp.push(200000, address(this), abi.encodeWithSignature("add(uint256)", 1));
		mp.push(200000, address(this), abi.encodeWithSignature("add(uint256)", 2));
		mp.push(200000, address(this), abi.encodeWithSignature("sub(uint256)", 2));
		mp.run();
		require(cumulative.get() == 6);

		mp.clear();
		mp.push(200000, address(this), abi.encodeWithSignature("sub(uint256)", 1));
		mp.run();
		require(cumulative.get() == 5);

		mp.clear();
		mp.push(200000, address(this), abi.encodeWithSignature("add(uint256)", 2));
		mp.run();
		require(cumulative.get() == 7);      
		require(cumulative.peek() == 0);

		mp.clear();
		mp.push(200000, address(this), abi.encodeWithSignature("add(uint256)", 50)); // 7 + 50 < 100 => 57
		mp.push(200000, address(this), abi.encodeWithSignature("add(uint256)", 50)); // 7 + 50 + 50  > 100 still 57 
		mp.push(200000, address(this), abi.encodeWithSignature("add(uint256)", 1)); // 7 + 50 + 1  < 100 => 58  
		mp.run();  

		require(cumulative.get() == 58);
	}
	
	function call1() public {
		Multiprocess mp = new Multiprocess(1);
		mp.push(200000, address(this), abi.encodeWithSignature("add(uint256)", 2));
		mp.run();
		require(cumulative.get() == 2);   

		mp.clear();
		mp.push(200000, address(this), abi.encodeWithSignature("sub(uint256)", 1));
		mp.run();
		require(cumulative.get() == 1);   
	}

	function call2() public {
		require(cumulative.get() == 1);
	}

	function add(uint256 elem) public { //9e c6 69 25
		cumulative.add(elem);
	}  

	function sub(uint256 elem) public { //9e c6 69 25
		cumulative.sub(elem);
	}  
}

contract ThreadingCumulativeU256SameMpMulti {
	U256Cumulative cumulative = new U256Cumulative(0, 100);     
	function call() public {
		Multiprocess mp1 = new Multiprocess(2);
		mp1.push(200000, address(this), abi.encodeWithSignature("add(uint256)", 2));
		mp1.run();
		mp1.clear();
	
		mp1.push(200000, address(this), abi.encodeWithSignature("add(uint256)", 2));
		mp1.run(); 
		mp1.clear(); 

		mp1.push(200000, address(this), abi.encodeWithSignature("sub(uint256)", 2));
		mp1.run();   

		add(2);
		require(cumulative.get() == 4);
	}

	function add(uint256 elem) public { //9e c6 69 25
		cumulative.add(elem);
	}  

	function sub(uint256 elem) public { //9e c6 69 25
		cumulative.sub(elem);
	}  
}
	
// Example contract using the Multiprocess library and U256ParaCompute
// to perform parallel additions and ensure the state consistency
contract U256ParaCompute {
    uint256 num = 0;

    function calculate() public {     
        Multiprocess mp = new Multiprocess(2);                                                  // Create Multiprocess instance with 2 threads         
        mp.push(200000, address(this), abi.encodeWithSignature("add(uint256)", 2)); // First function call    
        mp.push(200000, address(this), abi.encodeWithSignature("add(uint256)", 2)); // Second function call    
        mp.run(); 					                                                            // Call the function in parallel
        require(num == 2);                                                                      // Ensure that the 'num' variable is 2
    }

    function add(uint256 elem) public {                                                         // Perform addition to the 'num' variable
        num += elem;
    }  
}

// Example contract using the Multiprocess library and U256Cumulative for cumulative operations
// to perform parallel additions and ensure state consistency
contract CumulativeU256ParaCompute {
    U256Cumulative cumulative = new U256Cumulative(0, 100); 

    function calculate() public {       
        Multiprocess mp = new Multiprocess(2);   // Create Multiprocess instance with 2 threads
		mp.push(200000, address(this), abi.encodeWithSignature("add(uint256)", 2)); // Add the first function call      
        mp.push(200000, address(this), abi.encodeWithSignature("add(uint256)", 2)); // Add the second function call  
        mp.run();   																// Call the functions in parallel
        require(cumulative.get() == 4);         								  // Ensure that the cumulative value is 4
	}

    function add(uint256 elem) public { 
        cumulative.add(elem);                                                      // Perform addition to the variable
    }  
}