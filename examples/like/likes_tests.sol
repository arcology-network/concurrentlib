// SPDX-License-Identifier: GPL-3.0
pragma solidity >= 0.8.0 < 0.9.0;

import "../../lib/multiprocess/Multiprocess.sol";
import "./likes.sol";

contract LottoCaller {
    function call(address coin) public{        
        address Alice = 0x1111111110123456789012345678901234567890;
        address Bob = 0x2222222220123456789012345678901234567890;
        address Carol = 0x4444444890123456789012345678901234567890;
        address Dave = 0x3333337890123456789012345678901234567890;
        // Coin(coin).mint(Alice, 1111);
   
        Multiprocess mp = new Multiprocess(4);
        mp.push(100000, address(coin), abi.encodeWithSignature("mint(address,uint256)", Alice, 1111));
        mp.push(100000, address(coin), abi.encodeWithSignature("mint(address,uint256)", Bob, 2222));
        mp.push(100000, address(coin), abi.encodeWithSignature("mint(address,uint256)", Carol, 3333));
        mp.push(100000, address(coin), abi.encodeWithSignature("mint(address,uint256)", Dave, 4444));
        require(mp.length() == 4);
        mp.run();

        // require(Lotto(coin).getter(Alice) == 1111);
        // require(Lotto(coin).getter(Bob) == 2222);
        // require(Lotto(coin).getter(Carol) == 3333);
        // require(Lotto(coin).getter(Dave) == 4444);
    }
}
