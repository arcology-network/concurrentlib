# Concurrentlib
Concurrent Contracts
This repository contains a set of Solidity smart contracts that implement concurrent container functionalities. These contracts are designed for the Arcology network, utilizing its parallel execution design to enable concurrent operations on data structures. They serve as gateways for Solidity smart contract developers to fully utilize the power of Arcology's concurrent execution capabilities.

# Contracts
- **Base:** Serves as the foundation for concurrent container contracts, providing essential functionalities for managing data in a concurrent environment.
- **U256Map:** A concurrent container with key-value lookup using uint256 keys.
-** U256Set:** Derived from U256Map, it implements a set-like data structure for uint256 values.
- **Address:** A concurrent container with key-value lookup using address keys.
- **Bool:** A concurrent container with key-value lookup using bool keys.
- **Bytes:** A concurrent container with key-value lookup using bytes keys.
- **Bytes32:** A concurrent container with key-value lookup using bytes32 keys.
- **Int256:** A concurrent container with key-value lookup using int256 keys.
- **String:** A concurrent container with key-value lookup using string keys.
- **U256:** A concurrent container with key-value lookup using uint256 keys.
- **U256Cumulative:** An integer designed for cumulative operations in full concurrency, with minimum and maximum bounds. Allows concurrent delta changes while ensuring thread safety. 
- **Multiprocess:** A container that allows pushing executable messages and running them in parallel. Utilizes the Arcology parallel execution design for concurrent processing.
- **Runtime:** Provides runtime information to developers, including pseudo process IDs and random numbers, leveraging the power of Arcology's parallel execution model.
