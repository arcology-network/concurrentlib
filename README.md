<div align="left">
  <img src="./img/arcology-logo-text-dark-transparent.svg" alt="Your Image Alt Text" height="120px" align="center"/>
</div>


<!-- <h1> Concurrent APIs  <img align="center" height="30" src="./img/arcology-logo-text-dark-transparent.svg">  </h1> -->

<!-- [![NPM Package](https://img.shields.io/badge/npm-%F0%9F%93%84-grey)](https://www.npmjs.org/package/arcologynetwork)
[![Docs](https://img.shields.io/badge/docs-%F0%9F%93%84-grey)](https://doc.arcology.network/arcology-concurrent-programming-guide/)
[![Docs](https://img.shields.io/badge/solidity-%F0%9F%93%84-grey)](https://www.arcology.network) -->

<h1> Concurrent APIs <img align="center" height="32" src="./img/code-file.svg">  </h1>

<!-- # Concurrent APIs -->

Solidity, the programming language used to develop smart contracts on the Ethereum platform, was not initially designed for concurrent use, so it does not include the features and capabilities necessary for efficient concurrent programming. 

[Arcology Network](https://arcology.network) offers a suite of Solidity APIs customized for concurrent programming tasks. This package includes the Solidity APIs for  smart contract developers to fully utilize the power of **Arcology's parallel execution** capabilities. 

>>Please be aware that all the libraries in the package are specifically designed for Arcology Network only.

<h2> Installation <img align="center" height="32" src="./img/cloud-download.svg">  </h2>

``` shell
$ npm install @arcologynetwork/concurrentlib
```

<h2> Usage <img align="center" height="32" src="./img/ruler-cross-pen.svg">  </h2>

Once installed, you can use the contracts in the library by importing them:

```solidity
pragma solidity >=0.8.0 < 0.8.19;

import "arcologynetwork/contracts/concurrentlib/multiprocess/Multiprocess.sol";
import "arcologynetwork/contracts/concurrentlib/commutative/U256Cum.sol";
import "arcologynetwork/contracts/concurrentlib/array/Bool.sol";

contract Coin {
    address public minter;
    mapping (address => uint) public balances;

    constructor() {
        minter = msg.sender;
    }

    function mint(address receiver, uint amount) public {
        require(msg.sender == minter);
        require(amount < 1e60);
        balances[receiver] += amount;
    }

    function parallelMint(address[] receivers, uint[] amounts) public {
        Multiprocess jobs = new Multiprocess(8); // Initialize a job queue of of 8 threads.
        for (uint i = 0; i < receivers.length; i++) {
            jobs.push(100000, address(this), abi.encodeWithSignature("mint(address,uint256)", receivers[i], amounts[i]));
        }
        jobs.run() // Run the jobs in parallel with 8 theads.
    }
}
```

<h2> Learn More  <img align="center" height="32" src="./img/info.svg">  </h2>

You can find more examples in the [developer's guide](https://doc.arcology.network/arcology-concurrent-programming-guide/).

<h2> License  <img align="center" height="32" src="./img/copyright.svg">  </h2>

Arcology's concurrent lib is released under the MIT License.

<h2> Disclaimer  <img align="center" height="32" src="./img/warning.svg">  </h2>

<!-- ## Disclaimer  -->

Arcology's concurrent lib is made available under the MIT License, which disclaims all warranties in relation to the project and which limits the liability of those that contribute and maintain the project. You acknowledge that you are solely responsible for any use of the Contracts and you assume all risks associated with any such use.
