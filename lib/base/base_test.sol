// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.19;
import "../runtime/Runtime.sol";

contract BaseTest is Runtime{    
    address constant public API = address(0x84); 

    uint[] public arr2 = [1, 2, 3];
    bytes private id;

    // event logMsg(string message);

    constructor() {
        (bool success, bytes memory data) = address(API).call(abi.encodeWithSignature("new()"));       
        require(success, "Bytes.New() Failed");
        id = data;
 
        bytes memory byteArray = new bytes(75);
        for (uint  i = 0; i < 75; i ++) {
            byteArray[i] = 0x41;
        }
    
        require(peek() == 0);  
        require(length() == 0); 
        push(byteArray);  
        push(byteArray);          
        require(length() == 2); 
        require(peek() == 0);  

        require(indexByKey(keyByIndex(1)) == 1);
    
        bytes memory stored = getByIndex(1);
        bytes memory retrivedByKey = getByKey(keyByIndex(1));
        require(keccak256(retrivedByKey) == keccak256(stored));

        require(stored.length == byteArray.length);
        for (uint  i = 0; i < byteArray.length; i ++) {
            require(stored[i] == byteArray[i]);
        }

        bytes memory elems = new bytes(5);
        for (uint  i = 0; i < elems.length; i ++) {
            elems[i] = 0xaa;
        }
        setByIndex(1, elems);
       
        stored = getByIndex(0);
        require(stored.length == byteArray.length);
        for (uint  i = 0; i < byteArray.length; i ++) {
            require(stored[i] == byteArray[i]);
        }

        stored = getByIndex(1);
        require(stored.length == elems.length); 
        for (uint  i = 0; i < elems.length; i ++) {
            require(stored[i] == elems[i]);
        }

        // stored = pop();
        stored = getByIndex(length() - 1);
        delByIndex(length() - 1);
        // stored = pop();
        // require(keccak256(temp) == keccak256(stored));
        for (uint  i = 0; i < elems.length; i ++) {
            require(stored[i] == elems[i]);
        }
        require(length() == 1); 



        // clear();
        require(peek() == 0);  
        require(length() == 1); 
    }

    function call() public{ 
        require(peek() == 1); 
        popBack();
        require(peek() == 1); 
    }

    function keyByIndex(uint256 idx) public returns(bytes memory) {
        (,bytes memory data) = address(API).call(abi.encodeWithSignature("keyByIndex(uint256)", idx));   
        return data;     
    }

    function indexByKey(bytes memory key) public returns(uint256) {
        (,bytes memory data) = address(API).call(abi.encodeWithSignature("indexByKey(bytes)", key));   
        return abi.decode(data,(uint256));     
    }

    function peek() public returns(uint256) {
        (,bytes memory data) = address(API).call(abi.encodeWithSignature("peek()"));
        if (data.length > 0) {
            return abi.decode(data, (uint256));   
        }
        return 0;    
    }

    function length() public returns(uint256) {
        (bool success, bytes memory data) = address(API).call(abi.encodeWithSignature("length()"));
        require(success, "Bytes.length() Failed");
        return  abi.decode(data, (uint256));
    }

    function popBack() public virtual returns(bytes memory) { // 80 26 32 97
        bytes memory v = getByIndex(length() - 1);
        delByIndex(length() - 1);
        return v;
    }

    function push(bytes memory elem) public {
        setByKey(uuid(), (elem));
    }   
    
    function setByIndex(uint256 idx, bytes memory encoded) public { // 7a fa 62 38
        address(API).call(abi.encodeWithSignature("setIndex(uint256,bytes)", idx, encoded));     
    }

    function setByKey(bytes memory key, bytes memory elem) public {
        address(API).call(abi.encodeWithSignature("setKey(bytes,bytes)", key, elem));
    }

    function delByIndex(uint256 idx) public { // 7a fa 62 38
        address(API).call(abi.encodeWithSignature("delIndex(uint256)", idx));     
    }

    function delByIndex(bytes memory key) public {
        address(API).call(abi.encodeWithSignature("delIndex(bytes)", key));
    }


    function getByIndex(uint256 idx) public virtual returns(bytes memory) { // 31 fe 88 d0
        (bool success, bytes memory data) = address(API).call(abi.encodeWithSignature("getIndex(uint256)", idx));
        if (success) {
            return abi.decode(data, (bytes));  
        }
        return data;
    }

    function getByKey(bytes memory key) public returns(bytes memory)  {
        (bool success, bytes memory data) = address(API).call(abi.encodeWithSignature("getKey(bytes)", key));
        if (success) {
            return abi.decode(data, (bytes));  
        }
        return data;
    }

    // function getByIndex(uint256 idx) public returns(bytes memory)  {
    //     (bool success, bytes memory data) = address(API).call(abi.encodeWithSignature("getByIndex(uint256)", idx));
    //     if (success) {
    //         return abi.decode(data, (bytes)); 
    //     }
    //     return "";
    // }

    // function setByIndex(uint256 idx, bytes memory elem) public {
    //     (bool success, bytes memory data) = address(API).call(abi.encodeWithSignature("setByIndex(uint256,bytes)", idx, elem));
    //     require(success, "Bytes.setByIndex() Failed");
    // }

    // function getByKey(uint256 idx) public returns(bytes memory)  {
    //     (bool success, bytes memory data) = address(API).call(abi.encodeWithSignature("getByKey(uint256)", idx));
    //     require(success, "Bytes.getByIndex() Failed");
    //     return abi.decode(data, (bytes));  
    // }

    // function setByKey(uint256 idx, bytes memory elem) public {
    //     (bool success, bytes memory data) = address(API).call(abi.encodeWithSignature("setByKey(uint256,bytes)", idx, elem));
    //     require(success, "Bytes.setByIndex() Failed");
    // }

    function clear() public {
        (bool success, bytes memory data) = address(API).call(abi.encodeWithSignature("clear()"));
        require(success, "Bytes.setByIndex() Failed");
    }
}


// contract BaseNonLinearTest {    
//     address constant public API = address(0x84); 

//     uint[] public arr2 = [1, 2, 3];
//     bytes private id;

//     event logMsg(string message);

//     constructor() {
//         (bool success, bytes memory data) = address(API).call(abi.encodeWithSignature("new()"));       
//         require(success, "Bytes.New() Failed");
//         id = data;
 
//         bytes memory byteArray = new bytes(75);
//         for (uint  i = 0; i < 75; i ++) {
//             byteArray[i] = 0x41;
//         }
    
//         require(peek() == 0);  
//         require(length() == 0); 
//         push(byteArray);  
//         push(byteArray);          
//         require(length() == 2); 
//         require(peek() == 0);  

//         bytes memory stored = getByIndex(1);
//         require(stored.length == byteArray.length);
//         for (uint  i = 0; i < byteArray.length; i ++) {
//             require(stored[i] == byteArray[i]);
//         }

//         bytes memory elems = new bytes(5);
//         for (uint  i = 0; i < elems.length; i ++) {
//             elems[i] = 0xaa;
//         }
//         setByIndex(1, elems);
       
//         stored = getByIndex(0);
//         require(stored.length == byteArray.length);
//         for (uint  i = 0; i < byteArray.length; i ++) {
//             require(stored[i] == byteArray[i]);
//         }

//         stored = getByIndex(1);
//         require(stored.length == elems.length); 
//         for (uint  i = 0; i < elems.length; i ++) {
//             require(stored[i] == elems[i]);
//         }

//         stored = pop();
//         for (uint  i = 0; i < elems.length; i ++) {
//             require(stored[i] == elems[i]);
//         }
//         require(length() == 1); 

//         // clear();
//         require(peek() == 0);  
//         require(length() == 1); 
//     }

//     function call() public{ 
//         require(peek() == 1); 
//         pop();
//         require(peek() == 1); 
//     }

//     function peek() public returns(uint256) {
//         (,bytes memory data) = address(API).call(abi.encodeWithSignature("peek()"));
//         if (data.length > 0) {
//             return abi.decode(data, (uint256));   
//         }
//         return 0;    
//     }

//     function length() public returns(uint256) {
//         (bool success, bytes memory data) = address(API).call(abi.encodeWithSignature("length()"));
//         require(success, "Bytes.length() Failed");
//         return  abi.decode(data, (uint256));
//     }

//     function pop() public returns(bytes memory) {
//         (bool success, bytes memory data) = address(API).call(abi.encodeWithSignature("pop()"));
//         require(success, "Bytes.pop() Failed");
//         return abi.decode(data, (bytes)); 
//     }

//     function push(bytes memory elem) public {
//         (bool success, bytes memory data) = address(API).call(abi.encodeWithSignature("push(bytes)", elem));
//         require(success, "Bytes.push() Failed");
//     }   

//     function getByKey(uint256 idx) public returns(bytes memory)  {
//         (bool success, bytes memory data) = address(API).call(abi.encodeWithSignature("getByKey(uint256)", idx));
//         require(success, "Bytes.getByIndex() Failed");
//         return abi.decode(data, (bytes));  
//     }

//     function setByKey(uint256 idx, bytes memory elem) public {
//         (bool success, bytes memory data) = address(API).call(abi.encodeWithSignature("setByKey(uint256,bytes)", idx, elem));
//         require(success, "Bytes.setByIndex() Failed");
//     }

//     function clear() public {
//         (bool success, bytes memory data) = address(API).call(abi.encodeWithSignature("clear()"));
//         require(success, "Bytes.setByIndex() Failed");
//     }
// }
