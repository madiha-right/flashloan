// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.24;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { SafeERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import { IPoolAddressesProvider } from "@aave/core-v3/contracts/interfaces/IPoolAddressesProvider.sol";

import { MyContract } from "../src/MyContract.sol";
import { USDC, DAI, A_USDC, DEBT_DAI } from "../src/Constants.sol";

import { BaseScript } from "./Base.s.sol";
import { console } from "forge-std/src/console.sol";

/// @dev See the Solidity Scripting tutorial: https://book.getfoundry.sh/tutorials/solidity-scripting
contract OpenPosition is BaseScript {
    using SafeERC20 for IERC20;

    function run() public broadcast {
        uint256 amount = 1000 * 1e6; // 레버리지 이전 홀딩하고 있는 USDC의 수량
        address myContract = 0x9bE634797af98cB560DB23260b5f7C6e98AcCAcf;

        // MyContract.sol이 EOA로부터 베이스 담보로 사용할 USDC를 가져갈 수 있게 허용합니다.
        IERC20(USDC).forceApprove(myContract, amount);

        console.log("initial DAI Balance of contract", IERC20(DAI).balanceOf(myContract));
        console.log("initial USDC Balance of contract", IERC20(USDC).balanceOf(broadcaster));
        // 포지션을 생성합니다.
        MyContract(myContract).openPosition(amount);

        console.log("DAI - Debt amount: ", IERC20(DEBT_DAI).balanceOf(myContract));
        console.log("USDC - Collateral amount: ", IERC20(A_USDC).balanceOf(broadcaster));
    }
}
