// SPDX_License_Identifier: MIT
pragma solidity ^0.8.0;

import "contracts/Montgomery.sol";

interface Montgomery_int {
    function mont_mulmod(uint256 a0, uint256 a1, uint256 b0, uint256 b1, uint256 n0, uint256 n1) 
    external returns(uint256, uint256);
}