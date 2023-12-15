// SPDX-License-Identifier: GPL-3.0
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
        Multiprocess jobs = new Multiprocess(8);
        for (uint i = 0; i < receivers.length; i++) {
            jobs.push(100000, address(this), abi.encodeWithSignature("mint(address,uint256)", receivers[i], amounts[i]));
        }
        jobs.run()
    }
}
