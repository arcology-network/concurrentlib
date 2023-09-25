<div align="left">
  <img src="./img/arcology-logo-text-dark-transparent.svg" alt="Your Image Alt Text" height="120px" align="center"/>
</div>

<!-- [![NPM Package](https://img.shields.io/badge/npm-%F0%9F%93%84-grey)](https://www.npmjs.org/package/arcologynetwork)
[![Docs](https://img.shields.io/badge/docs-%F0%9F%93%84-grey)](https://doc.arcology.network/arcology-concurrent-programming-guide/)
[![Docs](https://img.shields.io/badge/solidity-%F0%9F%93%84-grey)](https://www.arcology.network) -->

# Concurrent APIs

Solidity, the programming language used to develop smart contracts on the Ethereum platform, was not initially designed for concurrent use, so it does not include the features and capabilities necessary for efficient concurrent programming. 

[Arcology Network](https://arcology.network) offers a suite of Solidity APIs customized for concurrent programming tasks. This package includes the Solidity APIs for  smart contract developers to fully utilize the power of **Arcology's parallel execution** capabilities. Please be aware that all the libraries in the package are specifically designed for Arcology Network only.

  
## Installation

```shell
$ npm install @arcologynetwork/concurrentlib
```

## Usage

Once installed, you can use the contracts in the library by importing them:

```solidity
pragma solidity ^0.8.19;

import "arcologynetwork/contracts/concurrentlib/Bool.sol";

contract ParallizedContract{
    Bool container = new Bool(); // A concurrent container
    paraCallee() public { // Can be processed in full parallel.
        container.push(true);
    }
}
```
*Please keep the library as it is when using it; don't try to modify.*

## Learn More

You can find more examples in the [developer's guide](https://doc.arcology.network/arcology-concurrent-programming-guide/).

## License

Arcology's concurrent lib is released under the MIT License.

## Disclaimer

Arcology's concurrent lib is made available under the MIT License, which disclaims all warranties in relation to the project and which limits the liability of those that contribute and maintain the project. You acknowledge that you are solely responsible for any use of the Contracts and you assume all risks associated with any such use.
