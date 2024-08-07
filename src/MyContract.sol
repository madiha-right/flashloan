// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.24;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { SafeERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import { IPoolAddressesProvider } from "@aave/core-v3/contracts/interfaces/IPoolAddressesProvider.sol";
import { IPool } from "@aave/core-v3/contracts/interfaces/IPool.sol";
import { FlashLoanSimpleReceiverBase } from "@aave/core-v3/contracts/flashloan/base/FlashLoanSimpleReceiverBase.sol";

import { PERCENTAGE_FACTOR, USDC_MAX_LTV, USDC, DAI, REFERRAL_CODE, INTEREST_RATE_MODE } from "./Constants.sol";

import { console } from "forge-std/src/console.sol";

contract MyContract is FlashLoanSimpleReceiverBase {
    using SafeERC20 for IERC20;

    constructor() FlashLoanSimpleReceiverBase(IPoolAddressesProvider(0x2f39d218133AFaB8F2B819B1066c7E434Ad94E9e)) { }

    function openPosition(uint256 amount) external {
        if (amount == 0) revert("Zero Amount");

        uint256 supplyAmount = amount * PERCENTAGE_FACTOR / (PERCENTAGE_FACTOR - USDC_MAX_LTV);
        uint256 flashLoanAmount = supplyAmount - amount;

        bytes memory params = abi.encode(supplyAmount);

        IERC20(USDC).safeTransferFrom(msg.sender, address(this), amount);

        IERC20(USDC).forceApprove(address(POOL), type(uint256).max);

        POOL.flashLoanSimple(address(this), USDC, flashLoanAmount, params, REFERRAL_CODE);
    }

    function executeOperation(
        address, // asset
        uint256 amount, // flashloan amount
        uint256 premium,
        address, // initiator
        bytes memory params
    )
        public
        override
        returns (bool)
    {
        (uint256 supplyAmount) = abi.decode(params, (uint256));

        IERC20(USDC).forceApprove(address(POOL), supplyAmount);

        console.log("premium", premium);

        POOL.supply(USDC, supplyAmount, address(this), REFERRAL_CODE);
        POOL.borrow(DAI, amount, INTEREST_RATE_MODE, REFERRAL_CODE, address(this));

        uint256 amountToRepayFlashLoan = amount + premium;

        // NOTE: skip Swap DAI to USDC to make it simple

        IERC20(USDC).forceApprove(address(POOL), amountToRepayFlashLoan);

        return true;
    }

    function mulTo(uint256 _x, uint256 _y) internal pure returns (uint256 amount) {
        amount = (_x * _y) / PERCENTAGE_FACTOR;
    }
}
