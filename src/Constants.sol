// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.24;

// referral code for aave
uint16 constant REFERRAL_CODE = 0;

// type of debt. (For Stable: 1, Variable: 2)
uint256 constant INTEREST_RATE_MODE = 2;

// maximum percentage factor (100.00%)
uint256 constant PERCENTAGE_FACTOR = 1e4;
// max LTV of USDC. 7000 bp, 70%
uint256 constant USDC_MAX_LTV = 7000;

// borrow asset
address constant DAI = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
// collateral asset
address constant USDC = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;

address constant DEBT_DAI = 0xcF8d0c70c850859266f5C338b38F9D663181C314;

address constant A_USDC = 0x98C23E9d8f34FEFb1B7BD6a91B7FF122F4e16F5c;
