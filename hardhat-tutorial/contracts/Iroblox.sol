// SPDX-License-Identifier: MIT
//
pragma solidity ^0.8.19;
interface Iroblox {
    function balanceOf(address) external view returns(uint256);
    function tokenOfOwnerByIndex(address, uint256) external view returns (uint256);
    function tokenByIndex(uint256) external view returns (uint256);

}


