// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.24;

import { MyContract } from "../src/MyContract.sol";
import { BaseScript } from "./Base.s.sol";

/// @dev See the Solidity Scripting tutorial: https://book.getfoundry.sh/tutorials/solidity-scripting
contract Deploy is BaseScript {
    MyContract public myContract;

    function run() public broadcast {
        myContract = new MyContract();
    }
}
