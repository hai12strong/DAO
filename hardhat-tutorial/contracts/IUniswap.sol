// SPDX-License-Identifier: MIT
//0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
pragma solidity ^0.8.19;


interface IUniswap {
     function swapExactETHForTokens(uint,address[] calldata,address,uint) external payable returns (uint[] memory);
}

