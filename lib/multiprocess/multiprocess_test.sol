// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0 <0.9.0;

import "./Multiprocess.sol";
import "../commutative/U256Cum.sol";
import "../array/Bool.sol";
import "../array/U256.sol";
import "../commutative/U256Cum.sol";
import "../map/StringUint256.sol";
import "../map/AddressU256Cum.sol";


contract U256CumulativeParallelInitTest {
    U256Cumulative[] containers = new U256Cumulative[](2);

    function call() public {  
        Multiprocess mp = new Multiprocess(2);
        mp.addJob(4000000, 0, address(this), abi.encodeWithSignature("init(uint256)", 0)); // Will require about 1.5M gas
        mp.addJob(4000000, 0, address(this), abi.encodeWithSignature("init(uint256)", 1));
        (bool success, bytes memory encoded) = mp.run();
        require(success);

        JobResult[] memory results = abi.decode(encoded, (JobResult[])); 
        require(results.length == 2);

        require(results[0].success);        
        require(abi.decode(results[0].returnData, (uint256)) == 11);

        require(results[1].success);   
        require(abi.decode(results[1].returnData, (uint256)) == 12);

        require(containers[0].get() == 11);
        require(containers[1].get() == 12);
    }

    function init(uint256 idx) public returns(uint256) { 
        containers[idx] = new U256Cumulative(1, 100);
        containers[idx].add(idx + 11);       
        return idx + 11;
    }
}

contract U256ParallelInitTest {
    U256[] containers = new U256[](2);

    function call() public {  
        // Multiprocess mp = new Multiprocess(2);
        // mp.addJob(4000000, 0, address(this), abi.encodeWithSignature("init(uint256)", 0)); // Will require about 1.5M gas
        // mp.addJob(4000000, 0, address(this), abi.encodeWithSignature("init(uint256)", 1));
        // mp.run();

        // require(containers[0].nonNilCount() == 1);
        // require(containers[1].nonNilCount() == 1);
    }

    function init(uint256 idx) public  { 
        containers[idx] = new U256();
        containers[idx].push(idx);        
    }
}
 
// More parallel jobs than the actual number of processors
contract U256ParallelInitTestExeceed {
    U256[] containers = new U256[](3);

    function call() public {  
        Multiprocess mp = new Multiprocess(2);
        mp.addJob(4000000, 0, address(this), abi.encodeWithSignature("init(uint256)", 0)); // Will require about 1.5M gas
        mp.addJob(4000000, 0, address(this), abi.encodeWithSignature("init(uint256)", 1));
        mp.addJob(4000000, 0, address(this), abi.encodeWithSignature("init(uint256)", 2));
        mp.run();

        require(containers[0].nonNilCount() == 1);
        require(containers[1].nonNilCount() == 1);
        require(containers[2].nonNilCount() == 1);
    }

    function init(uint256 idx) public  { 
        containers[idx] = new U256();
        containers[idx].push(idx);        
    }
}

contract U256ParallelPopTest {
    U256 container = new U256();

    function call() public {
        container.push(1);
        container.push(2);

        Multiprocess mp = new Multiprocess(2);
        mp.addJob(1000000, 0, address(this), abi.encodeWithSignature("delLast()"));
        mp.addJob(1000000, 0, address(this), abi.encodeWithSignature("delLast()"));
        mp.run();

        require(container.nonNilCount() == 1);
    }

    function delLast() public  { 
        container.delLast();
    }
}

contract U256ParallelConflictTest {
    U256 container = new U256();

    constructor() {
        container.push(uint256(10));
        container.push(uint256(20));
        container.push(uint256(30));
        require(container.nonNilCount() == 3);
    }

    function call() public  {     
        container.delLast(); 
        Multiprocess mp = new Multiprocess(1);
        mp.addJob(100000, 0, address(this), abi.encodeWithSignature("delLast()"));
        mp.run();
    }

    function get(uint256 idx) public returns(uint256){
        return container.get(idx);  
    }

    function delLast() public {
        container.get(1); 
        // container.delLast();   
    }
}

contract U256ParallelTest {
    U256 container = new U256();

    function call() public  { 
        require(container.nonNilCount() == 0); 
    
        container.push(uint256(10));
        container.push(uint256(20));
        container.push(uint256(30));
        require(container.nonNilCount() == 3);

        Multiprocess mp = new Multiprocess(1);
        mp.addJob(1000000, 0, address(this), abi.encodeWithSignature("push(uint256)", 41));
        mp.addJob(1000000, 0, address(this), abi.encodeWithSignature("push(uint256)", 51));
        require(mp.nonNilCount() == 2);
        require(container.nonNilCount() == 3);

        mp.run();


        require(container.nonNilCount() == 5);

        require(container.get(0) == uint256(10));
        require(container.get(1) == uint256(20));
        require(container.get(2) == uint256(30));
        require(container.get(3) == uint256(41));   
        require(container.get(4) == uint256(51));  
 
        require(container.delLast() == uint256(51));  
        require(container.nonNilCount() == 4);

        mp.addJob(1000000, 0, address(this), abi.encodeWithSignature("get(uint256)", 0));
        mp.addJob(1000000, 0, address(this), abi.encodeWithSignature("get(uint256)", 1));
        mp.run();


        delLast(); // idx == 4
        require(container.nonNilCount() == 3);

        delLast(); // idx == 3
        require(container.nonNilCount() == 2);
 
        // Here should be one conflict. So only one delLast() will take effect.
        mp.clear();
        mp.addJob(100000, 0, address(this), abi.encodeWithSignature("delLast()"));
        mp.addJob(100000, 0, address(this), abi.encodeWithSignature("delLast()"));
        mp.run();

        require(container.nonNilCount() == 1); 
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

    function delLast() public {
        container.delLast();   
    }
}


contract ArrayOfU256ParallelTest {
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

         mp.addJob(100000, 0, address(this), abi.encodeWithSignature("push(uint256,uint256)", 0, 13));
         mp.addJob(100000, 0, address(this), abi.encodeWithSignature("push(uint256,uint256)", 0, 14));
         mp.addJob(100000, 0, address(this), abi.encodeWithSignature("push(uint256,uint256)", 1, 51));
         mp.addJob(100000, 0, address(this), abi.encodeWithSignature("push(uint256,uint256)", 1, 52));
        require(mp.nonNilCount() == 4);
        mp.run();

        require(array[0].nonNilCount() == 4);
        require(array[1].nonNilCount() == 2);

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

    function get(uint256 id, uint256 idx) public view returns(uint256){
        return array[id].get(idx);  
    }

    function set(uint256 id, uint256 idx, uint256 v) public {
        return array[id].set(idx, v);  
    }

    function pop(uint256 id) public {
        array[id].delLast();  
    }
}

contract Deployer {
    U256 array; 

    constructor() { 
       Multiprocess mp = new Multiprocess(1); 
       mp.addJob(2500000, 0, address(this), abi.encodeWithSignature("init()"));
       require(mp.nonNilCount() == 1);
       mp.run();
    }

    function init() public {
        array = new U256();
    }
}  

contract ParaAssingmentTest {
    uint256 _1;
    uint256 _2;
    
    function call() public  { 
       Multiprocess mp = new Multiprocess(2); 
       mp.addJob(50000, 0, address(this), abi.encodeWithSignature("assigner(uint256)", 0));
       mp.addJob(50000, 0, address(this), abi.encodeWithSignature("assigner(uint256)", 1));
       require(mp.nonNilCount() == 2);
       mp.run();

       assert(_1 == 10);
       assert(_2 == 11);
    }

    function assigner(uint256 v)  public {
        if (v == 0) {
            _1 = v + 10;
            return;
        }
        _2 = v + 10;
    }
}   
 
contract ParaNativeArrayAssignmentTest {
    uint256[2] results;
    function call() public  { 
       Multiprocess mp = new Multiprocess(2); 
       mp.addJob(50000, 0, address(this), abi.encodeWithSignature("assigner(uint256)", 0));
       mp.addJob(50000, 0, address(this), abi.encodeWithSignature("assigner(uint256)", 1));
       require(mp.nonNilCount() == 2);
       mp.run();

       assert(results[0] == 10);
       assert(results[1] == 11);
    }

    function assigner(uint256 v)  public {
        results[v] = v + 10;
    }
}  
 
contract ParaFixedLengthWithConflictTest {  
    Bool container = new Bool();
     uint256[2] results;
     function call() public  { 
       results[0] = 100;
       results[1] = 200;
       Multiprocess mp = new Multiprocess(2);
       mp.addJob(400000, 0, address(this), abi.encodeWithSignature("updater(uint256)", 11));
       mp.addJob(400000, 0, address(this), abi.encodeWithSignature("updater(uint256)", 33));
       mp.addJob(400000, 0, address(this), abi.encodeWithSignature("updater(uint256)", 55));
       mp.run();     
       require(results[0] == 111);  // 11 and 33 will be reverted due to conflicts
       require(results[1] == 211); 
       require(container.nonNilCount() == 1); 
    }

    function updater(uint256 num) public {
         results[0] += num;
         results[1] += num;
         container.push(true);
    }
}

contract ParaContainerConcurrentPushTest {
    Bool container = new Bool();
    Bool container2 = new Bool();
    function call() public  { 
       container.push(true);

       Multiprocess mp = new Multiprocess(2);
       mp.addJob(1000000, 0, address(this), abi.encodeWithSignature("appender()"));
       mp.addJob(1000000, 0, address(this), abi.encodeWithSignature("appender()"));
       mp.run();
       require(container.nonNilCount() == 3);    
       require(container2.nonNilCount() == 2);   
       container.push(true);
       require(container.nonNilCount() == 4);    
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
       mp.addJob(1000000, 0, address(this), abi.encodeWithSignature("appender()"));
       mp.addJob(4000000, 0, address(this), abi.encodeWithSignature("appender()"));
       mp.run();
       require(container.nonNilCount() == 2);     

       Multiprocess mp2 = new Multiprocess(2);
       mp2.addJob(4000000, 0, address(this), abi.encodeWithSignature("appender()"));
       mp2.addJob(4000000, 0, address(this), abi.encodeWithSignature("appender()"));
       mp2.run();
       require(container.nonNilCount() == 4);  
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
       mp2.addJob(4000000, 0, address(this), abi.encodeWithSignature("appender()"));
       mp2.run();
       require(container.nonNilCount() == 2);    
    }

    function appender()  public {
       container.push(true);
       container.push(true);
    }
}

contract MultiprocessConcurrentBool {
    Bool container = new Bool();
    
    Multiprocess mp ; 
    Multiprocess mp2;
    function call() public  {  
       mp = new Multiprocess(2);
       mp2 = new Multiprocess(2);
       mp.addJob(4000000, 0, address(this), abi.encodeWithSignature("appender()"));
       mp.addJob(4000000, 0, address(this), abi.encodeWithSignature("appender()"));
       mp.run();
       require(container.nonNilCount() == 2);     
      
       mp2 = new Multiprocess(2);
       mp2.addJob(4000000, 0, address(this), abi.encodeWithSignature("appender()"));
       mp2.addJob(4000000, 0, address(this), abi.encodeWithSignature("appender()"));
       mp2.run();
       require(container.nonNilCount() == 4);  

       container.push(true);
       require(container.nonNilCount() == 5);  
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
       mp.addJob(1000000, 0, address(this), abi.encodeWithSignature("appender()"));
       mp.run();
       require(container.nonNilCount() == 1);    

       mp.clear();       
       require(mp.nonNilCount() == 0);   

       mp.addJob(4000000, 0, address(this), abi.encodeWithSignature("appender()"));
       mp.run();
       require(container.nonNilCount() == 2);    

       Multiprocess mp2 = new Multiprocess(2);
       mp2.addJob(4000000, 0, address(this), abi.encodeWithSignature("appender()"));
       mp2.addJob(4000000, 0, address(this), abi.encodeWithSignature("appender()"));
       mp2.run();
       require(container.nonNilCount() == 4);  
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
       parallelizers[0] .addJob(1000000, 0, address(this), abi.encodeWithSignature("appender()"));
       parallelizers[0] .addJob(1000000, 0, address(this), abi.encodeWithSignature("appender()"));
       parallelizers[0] .run();
       require(container.nonNilCount() == 2);  

       parallelizers[1] = new Multiprocess(2);
       parallelizers[1] .addJob(1000000, 0, address(this), abi.encodeWithSignature("appender()"));
       parallelizers[1] .addJob(1000000, 0, address(this), abi.encodeWithSignature("appender()"));
       parallelizers[1] .run();
       require(container.nonNilCount() == 4);  
    }

    function appender()  public {
       container.push(true);
    }
}

contract MultiParaCumulativeU256 {
    U256Cumulative cumulative = new U256Cumulative(0, 100);     
    function call() public {
        Multiprocess mp1 = new Multiprocess(1); // MultiParaCumulativeU256:nonce + 1
        mp1.addJob(400000, 0, address(this), abi.encodeWithSignature("add(uint256)", 2));
        mp1.run();
        require(cumulative.get() == 2);

        Multiprocess mp2 = new Multiprocess(1); // MultiParaCumulativeU256:nonce + 2
        mp2.addJob(400000, 0, address(this), abi.encodeWithSignature("add(uint256)", 3));
        mp2.run();
        require(cumulative.get() == 5);  

        Multiprocess mp3 = new Multiprocess(1); // MultiParaCumulativeU256:nonce + 3
        mp3.addJob(400000, 0, address(this), abi.encodeWithSignature("sub(uint256)", 4));
        mp3.run();  
        require(cumulative.get() == 1);  

        add(3);
        require(cumulative.get() == 4);
    }

    function add(uint256 elem) public { 
        cumulative.add(elem);
    }  

    function sub(uint256 elem) public { 
        cumulative.sub(elem);
    }   
}


contract MultiParaCumulativeU256WithParent {
    U256Cumulative cumulative = new U256Cumulative(0, 100);     
    function call() public {
        cumulative.add(1);

        Multiprocess mp1 = new Multiprocess(1); // MultiParaCumulativeU256:nonce + 1
        mp1.addJob(400000, 0, address(this), abi.encodeWithSignature("add(uint256)", 2));
        mp1.run();
        require(cumulative.get() == 3);

        Multiprocess mp2 = new Multiprocess(1); // MultiParaCumulativeU256:nonce + 2
        mp2.addJob(400000, 0, address(this), abi.encodeWithSignature("add(uint256)", 3));
        mp2.run();
        require(cumulative.get() == 6);  

        Multiprocess mp3 = new Multiprocess(1); // MultiParaCumulativeU256:nonce + 3
        mp3.addJob(400000, 0, address(this), abi.encodeWithSignature("sub(uint256)", 2));
        mp3.addJob(400000, 0, address(this), abi.encodeWithSignature("sub(uint256)", 2));
        mp3.addJob(400000, 0, address(this), abi.encodeWithSignature("add(uint256)", 1));
        mp3.run();  
        require(cumulative.get() == 3);  

        add(3);
        require(cumulative.get() == 6);
    }

    function add(uint256 elem) public { 
        cumulative.add(elem);
    }  

    function sub(uint256 elem) public { 
        cumulative.sub(elem);
    }   
}

contract MultiCumulativeU256ConcurrentOperation {
    U256Cumulative cumulative = new U256Cumulative(0, 100);     
    function call() public {
        Multiprocess mp1 = new Multiprocess(1);
        mp1.addJob(400000, 0, address(this), abi.encodeWithSignature("add(uint256)", 2));
        mp1.addJob(400000, 0, address(this), abi.encodeWithSignature("add(uint256)", 2));
        mp1.addJob(400000, 0, address(this), abi.encodeWithSignature("sub(uint256)", 2));
        mp1.run();        
        require(cumulative.get() == 4);  

        add(3);
        require(cumulative.get() == 7);
    }

    function add(uint256 elem) public { 
        cumulative.add(elem);
    }  

    function sub(uint256 elem) public { 
        cumulative.sub(elem);
    }   
}

contract RecursiveParallelizerOnNativeArrayTest {
    uint256[2] results;
    function call() public {
        Multiprocess mp = new Multiprocess(1);
        mp.addJob(9999999, 0, address(this), abi.encodeWithSignature("add()")); // Only one will go through
        mp.run();

        require(results[0] == 11);
        require(results[1] == 12);
    } 

    function add() public { 
        Multiprocess mp2 = new Multiprocess(1); 
        mp2.addJob(11111111, 0, address(this), abi.encodeWithSignature("add2()"));
        mp2.run();              
    }  

    function add2() public { 
        results[0] = 11;
        results[1] = 12;
    }  
}

contract RecursiveAssignerTest {
    uint256[4] array; 

    function call() public { 
       Multiprocess mp = new Multiprocess(2); 
       mp.addJob(5000000, 0, address(this), abi.encodeWithSignature("proxy(uint256)", 0));
       mp.addJob(5000000, 0, address(this), abi.encodeWithSignature("proxy(uint256)", 1));
       mp.run();

       require(array[0] == 10);
       require(array[1] == 21);   
       require(array[2] == 12);
       require(array[3] == 23); 
    }

    function proxy(uint256 idx) public {
       Multiprocess mp = new Multiprocess(2); 
       mp.addJob(2500000, 0, address(this), abi.encodeWithSignature("assign(uint256,uint256,uint256)", idx, 0, 10));
       mp.addJob(2500000, 0, address(this), abi.encodeWithSignature("assign(uint256,uint256,uint256)", idx, 1, 20));
       mp.run();        
    }

    function assign(uint256 idx, uint256 i, uint256 v) public {
        array[idx*2 + i] = v + idx*2 + i;
    }   
} 

contract RecursiveParallelizerOnContainerTest {
    uint256[2] results;
    Bool container = new Bool();
    U256Cumulative cumulative = new U256Cumulative(0, 100);  

    function call() public {
        Multiprocess mp = new Multiprocess(1);
        mp.addJob(9999999, 0, address(this), abi.encodeWithSignature("add()")); // Only one will go through
        mp.run();

        // require(results[0] == 11);
        // require(results[1] == 12);
        // require(container.nonNilCount() == 2);
        require(cumulative.get() == 5);
    } 

    function add() public { 
        container.push(true);
        cumulative.add(10);
        Multiprocess mp2 = new Multiprocess(1); 
        mp2.addJob(11111111, 0, address(this), abi.encodeWithSignature("add2()"));
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
        mp.addJob(99999999, 0, address(this), abi.encodeWithSignature("add()")); // Only one will go through
        mp.addJob(99999999, 0, address(this), abi.encodeWithSignature("add()")); // Only one will go through
        mp.run();

        require(container.nonNilCount() == 14); 
        require(container.nonNilCount() == 14);       
    } 

    function add() public { 
        Multiprocess mp2 = new Multiprocess(1); 
        mp2.addJob(41111111, 0, address(this), abi.encodeWithSignature("add2()"));
        mp2.addJob(41111111, 0, address(this), abi.encodeWithSignature("add2()"));

        mp2.run();
        container.push(true);              
    } 

    function add2() public { 
        Multiprocess mp2 = new Multiprocess(1); 
        mp2.addJob(21111111, 0, address(this), abi.encodeWithSignature("add3()"));
        mp2.addJob(21111111, 0, address(this), abi.encodeWithSignature("add3()"));
        mp2.run();
        container.push(true);              
    } 

    function add3() public { 
        container.push(true);              
    } 
}

contract MaxSelfRecursiveDepth4Test {
    Bool container = new Bool();

    Multiprocess mp;
    function call() public {
        // container.push(true);       
        mp = new Multiprocess(1);
        mp.addJob(99999999, 0, address(this), abi.encodeWithSignature("add()")); // Only one will go through
        mp.addJob(99999999, 0, address(this), abi.encodeWithSignature("add()")); // Only one will go through
        mp.run();
        require(container.nonNilCount() == 30); // 2 + 4 + 8 + 16
    } 

    function add() public { 
        Multiprocess mp2 = new Multiprocess(1); 
        mp2.addJob(21111111, 0, address(this), abi.encodeWithSignature("add()"));
        mp2.addJob(21111111, 0, address(this), abi.encodeWithSignature("add()"));
        mp2.run();
        container.push(true);              
    }     
}

contract MaxRecursiveDepthOffLimitTest {
    Bool container = new Bool();
    U256Cumulative cumulative = new U256Cumulative(0, 200);  

    Multiprocess mp;
    function call() public {
        cumulative.add(2);
        // require(cumulative.get() == 10);

        container.push(true);       
        mp = new Multiprocess(1);
        mp.addJob(9999999, 0, address(this), abi.encodeWithSignature("add()"));
        mp.addJob(9999999, 0, address(this), abi.encodeWithSignature("add()")); 
        mp.run();
  
        require(container.nonNilCount() == 31); // 1 + (2 + 4 + 8 + 16) 
        require(cumulative.get() == 62);
    } 

    function add() public { 
        cumulative.add(2);
        Multiprocess mp2 = new Multiprocess(1); 
        mp2.addJob(41111111, 0, address(this), abi.encodeWithSignature("add()"));
        mp2.addJob(41111111, 0, address(this), abi.encodeWithSignature("add()"));
        mp2.run();
        container.push(true);              
    }    
}

contract ParaFixedLengthWithConflictRollbackTest {
    Bool container = new Bool();
    uint256[2] results;
    function call() public {
        Multiprocess mp = new Multiprocess(2);
        mp.addJob(9999999, 0, address(this), abi.encodeWithSignature("worker()")); // Only one will go through
        mp.addJob(9999999, 0, address(this), abi.encodeWithSignature("worker()")); // Only one will go through
        mp.run();
        require(container.nonNilCount() == 1);

        appender();
        require(container.nonNilCount() == 2);
    } 

    function worker() public { 
        Multiprocess mp2 = new Multiprocess(2); 
        mp2.addJob(1999999, 0, address(this), abi.encodeWithSignature("appender()"));
        mp2.run();   
        results[0] = 1;
        results[1] = 1;
    }   

    function appender() public { 
        container.push(true);
    }  
}

contract ParaSubbranchConflictTest {
    Bool container = new Bool();
    uint256[2] results0;
    uint256[2] results1;
    function call() public {
        Multiprocess mp = new Multiprocess(2);
        mp.addJob(9999999, 0, address(this), abi.encodeWithSignature("worker0()")); // Only one will go through
        mp.addJob(9999999, 0, address(this), abi.encodeWithSignature("worker1()")); // Only one will go through
        mp.run();
        require(container.nonNilCount() == 4);
    } 

    function worker0() public { 
        Multiprocess mp2 = new Multiprocess(2); 
        mp2.addJob(1999999, 0, address(this), abi.encodeWithSignature("appender00()"));
        mp2.addJob(1999999, 0, address(this), abi.encodeWithSignature("appender01()"));
        mp2.run();   
        
        container.push(true);
    }   

    function appender00() public { 
        container.push(true);
        results0[0] = 1;
    }  

    function appender01() public { 
        container.push(true);
        results0[0] = 1;
    }  

    function worker1() public { 
        Multiprocess mp2 = new Multiprocess(2); 
        mp2.addJob(1999999, 0, address(this), abi.encodeWithSignature("appender10()"));
        mp2.addJob(1999999, 0, address(this), abi.encodeWithSignature("appender11()"));
        mp2.run();   
        
        container.push(true);
    }   

    function appender10() public { 
        container.push(true);
        results1[0] = 1;
    }  

    function appender11() public { 
        container.push(true);
        uint256 a = results1[0];
    }  
}

contract SimpleConflictTest {
    uint256 data;
    function call() public {
        Multiprocess mp = new Multiprocess(2);
        mp.addJob(100000, 0, address(this), abi.encodeWithSignature("assign(uint256)", 1)); // Only one will go through
        mp.addJob(100000, 0, address(this), abi.encodeWithSignature("assign(uint256)", 2)); // Only one will go through
        mp.run();
        require(data == 1);
    }

    function assign(uint256 v) public { 
        data = v;
    } 
}

contract ParentChildBranchConflictTest {
    Bool container = new Bool();
    uint256[2] results0;
    uint256[2] results1;
    function call() public {
        Multiprocess mp = new Multiprocess(2);
        mp.addJob(9999999, 0, address(this), abi.encodeWithSignature("worker0()")); // Only one will go through
        mp.addJob(9999999, 0, address(this), abi.encodeWithSignature("worker1()")); // Only one will go through
        mp.run();
        require(container.nonNilCount() == 1);
        require(results0[0] == 2);
    } 

    function worker0() public { 
        results0[0] = 2;
        Multiprocess mp2 = new Multiprocess(2); 
        mp2.run();   
        
        container.push(true);
    }   

    function worker1() public { 
        Multiprocess mp2 = new Multiprocess(2); 
        mp2.addJob(1999999, 0, address(this), abi.encodeWithSignature("appender10()"));
        mp2.run();   
        
        container.push(true);
    }   

    function appender10() public { 
        container.push(true);
        results0[0] = 1;
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
        mp.addJob(9999999, 0, address(this), abi.encodeWithSignature("add()")); // Only one will go through
        mp.addJob(9999999, 0, address(this), abi.encodeWithSignature("add()")); // Only one will go through
        mp.run();
        require(container.nonNilCount() == 3);

        require(results[0] == 11);
        require(results[1] == 12);
        require(container.nonNilCount() == 3);
        require(cumulative.get() == 55);
        require(cumulative2.get() == 70); 
    } 

    function add() public { 
        cumulative.add(10);
        Multiprocess mp2 = new Multiprocess(1); 
        mp2.addJob(11111111, 0, address(this), abi.encodeWithSignature("add2()"));
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
		// require(cumulative.committedLength() == 0);
		cumulative.add(1);
		cumulative.sub(1);
		// require(cumulative.committedLength() == 0);
	}

	function call() public {
		Multiprocess mp = new Multiprocess(1);
		mp.addJob(200000, 0, address(this), abi.encodeWithSignature("add(uint256)", 2));
		mp.addJob(200000, 0, address(this), abi.encodeWithSignature("add(uint256)", 2));   
		mp.addJob(200000, 0, address(this), abi.encodeWithSignature("add(uint256)", 1));
		mp.run();
		require(cumulative.get() == 5);

		mp.clear();
		mp.addJob(200000, 0, address(this), abi.encodeWithSignature("add(uint256)", 1));
		mp.addJob(200000, 0, address(this), abi.encodeWithSignature("add(uint256)", 2));
		mp.addJob(200000, 0, address(this), abi.encodeWithSignature("sub(uint256)", 2));
		mp.run();
		require(cumulative.get() == 6);

		mp.clear();
		mp.addJob(200000, 0, address(this), abi.encodeWithSignature("sub(uint256)", 1));
		mp.run();
		require(cumulative.get() == 5);

		mp.clear();
		mp.addJob(200000, 0, address(this), abi.encodeWithSignature("add(uint256)", 2));
		mp.run();
		require(cumulative.get() == 7);      
		// require(cumulative.committedLength() == 0);

		mp.clear();
		mp.addJob(200000, 0, address(this), abi.encodeWithSignature("add(uint256)", 50)); // 7 + 50 < 100 => 57
		mp.addJob(200000, 0, address(this), abi.encodeWithSignature("add(uint256)", 50)); // 7 + 50 + 50  > 100 still 57 
		mp.addJob(200000, 0, address(this), abi.encodeWithSignature("add(uint256)", 1)); // 7 + 50 + 1  < 100 => 58  
		mp.run();  

		require(cumulative.get() == 58);
	}
	
	function call1() public {
		Multiprocess mp = new Multiprocess(1);
		mp.addJob(200000, 0, address(this), abi.encodeWithSignature("add(uint256)", 2));
		mp.run();
		require(cumulative.get() == 2);   

		mp.clear();
		mp.addJob(200000, 0, address(this), abi.encodeWithSignature("sub(uint256)", 1));
		mp.run();
		require(cumulative.get() == 1);   
	}

	function call2() public {
		require(cumulative.get() == 1);
	}

	function add(uint256 elem) public { 
		cumulative.add(elem);
	}  

	function sub(uint256 elem) public { 
		cumulative.sub(elem);
	}  
}

contract ThreadingCumulativeU256SameMpMulti {
	U256Cumulative cumulative = new U256Cumulative(0, 100);     
	function call() public {
		Multiprocess mp1 = new Multiprocess(2);
		mp1.addJob(200000, 0, address(this), abi.encodeWithSignature("add(uint256)", 2));
		mp1.run();
		mp1.clear();
	
		mp1.addJob(200000, 0, address(this), abi.encodeWithSignature("add(uint256)", 2));
		mp1.run(); 
		mp1.clear(); 

		mp1.addJob(200000, 0, address(this), abi.encodeWithSignature("sub(uint256)", 2));
		mp1.run();   

		add(2);
		require(cumulative.get() == 4);
	}

	function add(uint256 elem) public { 
		cumulative.add(elem);
	}  

	function sub(uint256 elem) public { 
		cumulative.sub(elem);
	}  
}
	
// Example contract using the Multiprocess library and U256ParaCompute
// to perform parallel additions and ensure the state consistency
contract U256ParaCompute {
    uint256 num = 0;

    function call() public {     
        Multiprocess mp = new Multiprocess(2);                                                  // Create Multiprocess instance with 2 threads         
        mp.addJob(200000, 0, address(this), abi.encodeWithSignature("add(uint256)", 2)); // First function call    
        mp.addJob(200000, 0, address(this), abi.encodeWithSignature("add(uint256)", 2)); // Second function call    
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
		mp.addJob(200000, 0, address(this), abi.encodeWithSignature("add(uint256)", 2)); // Add the first function call      
        mp.addJob(200000, 0, address(this), abi.encodeWithSignature("add(uint256)", 2)); // Add the second function call  
        mp.run();   																// Call the functions in parallel
        require(cumulative.get() == 4);         								  // Ensure that the cumulative value is 4
	}

    function add(uint256 elem) public { 
        cumulative.add(elem);                                                      // Perform addition to the variable
    }  
}

contract NativeStorage {   
    uint256 public x = 1 ;
    uint256 public y = 100 ;

    function incrementX() public {x ++;}
    function incrementY() public {y += 2;}

    function getX() public view returns(uint256) {return x;}
    function getY() public view returns(uint256) {return y;}
}

contract NativeStorageAssignmentTest {
    NativeStorage results = new NativeStorage() ;
    function call() public  { 
        Multiprocess mp = new Multiprocess(2); 
        mp.addJob(50000, 0, address(results), abi.encodeWithSignature("incrementX()"));
        mp.addJob(50000, 0, address(results), abi.encodeWithSignature("incrementY()"));
        mp.addJob(50000, 0, address(results), abi.encodeWithSignature("incrementX()"));
        // mp.addJob(50000, 0, address(results), abi.encodeWithSignature("incrementY()"));
        mp.run();
        require(results.getX() == 2);
        require(results.getY() == 102);
    }
} 

contract sharedContract{ 
    uint256 counter = 0;
    function increment () public {
        counter ++;
    }

    function get() public view returns(uint256){
        return counter;
    }
}

contract conflictLeft{ 
    uint256 internalCounter = 0;
    function increment () public {
        internalCounter ++;
    }

    function callShared (address callee) public {
        internalCounter ++;
        sharedContract(callee).increment();
    }
    
    function get() public view returns(uint256){
        return internalCounter;
    }
}

contract conflictRight{ 
    uint256 internalCounter = 0;
    function increment () public {
        internalCounter ++;
    }
    
    function callShared (address callee) public {
        internalCounter += 2;
        sharedContract(callee).increment();
    }

    function get() public view returns(uint256){
        return internalCounter;
    }
}

contract ParaConflictTest {
    NativeStorage results = new NativeStorage() ;
    function call() public  { 
        conflictLeft left = new conflictLeft();
        conflictRight right = new conflictRight();

        Multiprocess mp = new Multiprocess(2); 
        mp.addJob(50000, 0, address(left), abi.encodeWithSignature("increment()"));
        mp.addJob(50000, 0, address(right), abi.encodeWithSignature("increment()"));
        mp.run();

        require(left.get() == 1);
        require(right.get() == 1);
        require(mp.fullLength() == 2);

        // sharedContract shared =  new sharedContract();    
        // mp.addJob(50000, 0, address(left), abi.encodeWithSignature("callShared(address)", 0, address(shared)));
        // mp.addJob(50000, 0, address(right), abi.encodeWithSignature("callShared(address)", 0, address(shared)));
        // mp.run();

        // require(shared.get() == 1);
    }
} 

contract ParaRwConflictTest {
    uint256 counter = 0;
    uint256 counterCopy = 0;
    function call() public  { 
        Multiprocess mp = new Multiprocess(2); 
        mp.addJob(500000, 0, address(this), abi.encodeWithSignature("read()"));
        mp.addJob(500000, 0, address(this), abi.encodeWithSignature("write(uint256)", 11));
        mp.run();

  
        // The conflict detection will detect the conflict and revert one of the transactions    
        require(counterCopy == 0); 
        require(counter == 0);
    }

    function read() public {
        counterCopy = counter; // Counter read
    }

    function write(uint256 v) public  {
        counter = v; // Counter write 
    }   
} 

contract ParaPayableConflictTest {
    uint256 counter = 0;
    uint256 counterCopy = 0;
    function call() public  { 
        Multiprocess mp = new Multiprocess(2); 
        mp.addJob(50000, 0, address(this), abi.encodeWithSignature("read()"));
        mp.addJob(50000, 0, address(this), abi.encodeWithSignature("write()", 11));
        mp.run();


        require(counterCopy == 0);
        require(counter == 0);
    }

    function read() public {
        counterCopy = counter;
    }

    function write(uint256 v) public  {
        counter = v;
    }   
} 

contract ParaCumU256SubTest{
    U256Cumulative counter = new U256Cumulative(0, 100);

    constructor()  {
        counter.add(100);
    }

    function call() public  { 
        Multiprocess mp = new Multiprocess(2); 
        mp.addJob(50000, 0, address(this), abi.encodeWithSignature("sub(uint256)", 40));
        mp.addJob(50000, 0, address(this), abi.encodeWithSignature("sub(uint256)", 40));
        mp.run();

        require(counter.get() == 20);

        counter.add(80);
        mp.addJob(50000, 0, address(this), abi.encodeWithSignature("sub(uint256)", 60));
        mp.addJob(50000, 0, address(this), abi.encodeWithSignature("sub(uint256)", 60));
        mp.run();
        require(counter.get() == 40);
    }

    function sub(uint256 v) public {
        counter.sub(v);
    }  
} 

contract ParaDeletions{
    StringUint256Map addBoolLookup = new StringUint256Map();

    constructor()  {
        addBoolLookup.set("key 0", 100);
        addBoolLookup.set("key 1", 200);
        addBoolLookup.set("key 2", 300);
    }

    function call() public  { 
        // require(addBoolLookup.valueAt(0) == 100);
        // require(addBoolLookup.valueAt(1) == 200);
        // require(addBoolLookup.valueAt(2) == 300);

        del("key 0");
        require(addBoolLookup.valueAt(0) == 0);
        require(addBoolLookup.valueAt(1) == 200);
        require(addBoolLookup.valueAt(2) == 300);

        Multiprocess mp = new Multiprocess(2); 
        mp.addJob(50000, 0, address(this), abi.encodeWithSignature("del(string)", "key 0"));
        mp.addJob(50000, 0, address(this), abi.encodeWithSignature("del(string)", "key 2"));
        mp.run();

        require(addBoolLookup.nonNilCount() == 1);

        mp.addJob(50000, 0, address(this), abi.encodeWithSignature("add(string,uint256)", "key 10", 21));
        mp.addJob(50000, 0, address(this), abi.encodeWithSignature("add(string,uint256)", "key 23", 31));
        mp.run();

        require(addBoolLookup.nonNilCount() == 3);
        require(addBoolLookup.get("key 10") == 21);
        require(addBoolLookup.get("key 23") == 31);

        // set a new key value pair and delete another, this should not cause any conflicts.
        mp.addJob(50000, 0, address(this), abi.encodeWithSignature("del(string)", "key 10"));
        mp.addJob(50000, 0, address(this), abi.encodeWithSignature("add(string,uint256)", "key 23", 41));
        mp.run();
      
        require(addBoolLookup.nonNilCount() == 2);

        mp.addJob(50000, 0, address(this), abi.encodeWithSignature("add(string,uint256)", "key 10", 21)); // Added it back
        mp.addJob(50000, 0, address(this), abi.encodeWithSignature("add(string,uint256)", "key 23", 41));
        mp.run();
        require(addBoolLookup.nonNilCount() == 3);      
        // require(addBoolLookup.valueAt(1) == 200);
    }

    function add(string memory key, uint256 v) public {
        addBoolLookup.set(key,  v);
    } 

    function del(string memory key) public {
        addBoolLookup.del(key);
    }  
} 

contract ParaAddressUint256ConflictTest {  
    AddressU256CumMap container = new AddressU256CumMap();

    address addr1 = 0x1111111110123456789012345678901234567890;
    address addr2 = 0x2222222220123456789012345678901234567890;
    address addr3 = 0x3333337890123456789012345678901234567890;
    address addr4 = 0x4444444440123456789012345678901234567890;
    address addr5 = 0x5555555550123456789012345678901234567890;

    address[] public addrs;

    constructor() {
        addrs.push(addr1);
        addrs.push(addr2);
        addrs.push(addr3);
        addrs.push(addr4);
        addrs.push(addr5);
    }

    function call() public  { 
        container.set(addr1, 18, 17, 111);
        container.set(addr2, 19, 18, 112);                
        container.set(addr3, 20, 19, 113);

        require(container.get(addr1) == 18);
        require(container.get(addr2) == 19);
        require(container.get(addr3) == 20);

        // pusher(2);

        Multiprocess mp = new Multiprocess(4); 
        mp.addJob(500000, 0, address(this), abi.encodeWithSignature("adder(uint256)", 1)); // Addr 2: 19
        mp.addJob(500000, 0, address(this), abi.encodeWithSignature("adder(uint256)", 2));// Addr 3 : 20
        mp.addJob(500000, 0, address(this), abi.encodeWithSignature("pusher(uint256)", 3));// Addr 4
        // mp.addJob(500000, 0, address(this), abi.encodeWithSignature("pusher(uint256)", 4));// Addr 5
        mp.run();

        // require(container.get(addr1) == 18); // Sequentially added
        

        // require(container.get(addr2) == 20);
        // require(container.get(addr3) == 21);

        // Runtime.print(container.get(addr2));
        // Runtime.print(container.get(addr4));
        // Runtime.print(container.get(addr5));
        // require(container.get(addr4) == 33);
        // require(container.get(addr5) == 34);

        // Runtime.print(container.get(addr2));
        // Runtime.print(container.get(addr3));

        // require(container.nonNilCount() == 5);
    }

    function adder(uint256 num) public {
        container.set(addrs[num], 1); // Set delta to 1
    }

    function pusher(uint256 num) public {
        container.set(addrs[num], int256(30 + num), 17, 111);
    }
}
