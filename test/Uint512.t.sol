// SPDX-License-Identifier: GPLv3
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../contracts/Uint512.sol";
import {console} from "forge-std/console.sol";

contract Uint512Test is Test {

    uint256 a0;
    uint256 a1;
    uint256 b0;
    uint256 b1;
    uint256 n0;
    uint256 n1;

    function setUp() public {
        // a = 0xbef38558980cc4c4be07c6416b854f6eede590a86520c659f8a23d543c0d6fb7022279e7e3295ce6bc4f4cca50951ef42d6d6472c9a89d8e03989ec052bd8440
        // b = 0x59bd0fb9a19bf11a8c6b50df95ed0bae5ce6560591d25f6b09087b0aaf149ef17e56e04d3aae0c056c70690ca838a82fe1945a4df59baf657b4e36ca2e2105b8
        // n = 0xd38558980cc4c4be07c6416b854f6eede590a86520c659f8a23d543c0d6fb7ef7e56e04d3aae0c056c70690ca838a82fe1945a4df59baf657b4e36ca2e2105b8
        a0 = 0x22279e7e3295ce6bc4f4cca50951ef42d6d6472c9a89d8e03989ec052bd8440;
        a1 = 0xbef38558980cc4c4be07c6416b854f6eede590a86520c659f8a23d543c0d6fb7;
        b0 = 0x7e56e04d3aae0c056c70690ca838a82fe1945a4df59baf657b4e36ca2e2105b8;
        b1 = 0x59bd0fb9a19bf11a8c6b50df95ed0bae5ce6560591d25f6b09087b0aaf149ef1;
        n1 = 0xd38558980cc4c4be07c6416b854f6eede590a86520c659f8a23d543c0d6fb7ef;
        n0 = 0x7e56e04d3aae0c056c70690ca838a82fe1945a4df59baf657b4e36ca2e2105b8;
    }

    function uint512Equal(uint256 x0, uint256 x1, uint256 y0, uint256 y1) public {
        assertEq(x1, y1);
        assertEq(x0, y0);
    }

    function testAdd512x512() public {
        // a + b = 0x1_18b0951239a8b5df4a73172101725b1d4acbe6adf6f325c501aab85eeb220ea880795a351dd768ec28bfb5d6f8cdc7240f01bec0bf444cf37ee6d58a80de89f8
        uint256 r1 = 0x18b0951239a8b5df4a73172101725b1d4acbe6adf6f325c501aab85eeb220ea8;
        uint256 r0 = 0x80795a351dd768ec28bfb5d6f8cdc7240f01bec0bf444cf37ee6d58a80de89f8;

        (uint256 res0, uint256 res1) = Uint512.add512x512(a0, a1, b0, b1);
        uint512Equal(r0, r1, res0, res1);
    }


    function testEq512x512() public {
        assertEq(Uint512.eq512x512(a0, a1, a0, a1), true);
        assertEq(Uint512.eq512x512(a0, a1, b0, b1), false);
    }

    function testLt512x512() public {
        assertEq(Uint512.lt512x512(a0, a1, a0, a1), false);
        assertEq(Uint512.lt512x512(a0, a1, b0, b1), false);
        assertEq(Uint512.lt512x512(b0, b1, a0, a1), true);
    }

    function testGt512x512() public {
        assertEq(Uint512.gt512x512(a0, a1, a0, a1), false);
        assertEq(Uint512.gt512x512(a0, a1, b0, b1), true);
        assertEq(Uint512.gt512x512(b0, b1, a0, a1), false);
    }

    // a and b already < N
    // function testAdd512x512mod_withoutSub() public {
    //     // a + b = 0x18b0951239a8b5df4a73172101725b1d4acbe6adf6f325c501aab85eeb220ea880795a351dd768ec28bfb5d6f8cdc7240f01bec0bf444cf37ee6d58a80de89f8
    //     // a + b < n
    //     uint256 r1 = 0x18b0951239a8b5df4a73172101725b1d4acbe6adf6f325c501aab85eeb220ea8;
    //     uint256 r0 = 0x80795a351dd768ec28bfb5d6f8cdc7240f01bec0bf444cf37ee6d58a80de89f8;
        
    //     (uint256 res0, uint256 res1) = Uint512.add512x512mod(a0, a1, b0, b1, n0, n1);
    //     uint512Equal(r0, r1, res0, res1);
    // }

    function testAdd512x512mod_withSub() public {
        // a + c > n
        // c = 0x1491d33f74b7fff949be7b2a19ca1f7ef7ab17bcbba5939ea99b16e7d16248387c3466655784af1eb0211c4257a3893bb426f5db2bf311d777b59809db7657ff
        // a + c = 0xd38558980cc4c4be07c6416b854f6eede590a86520c659f8a23d543c0d6fb7ef7e56e04d3aae0c056c70690ca838a82fe1945a4df59baf657b4e36ca2e33dc3f;
        // res = 0x12d687
        uint256 c1 = 0x1491d33f74b7fff949be7b2a19ca1f7ef7ab17bcbba5939ea99b16e7d1624838;
        uint256 c0 = 0x7c3466655784af1eb0211c4257a3893bb426f5db2bf311d777b59809db7657ff;
        uint256 r1 = 0x0;
        uint256 r0 = 0x12d687;

        (uint256 res0, uint256 res1) = Uint512.add512x512mod(a0, a1, c0, c1, n0, n1);
        uint512Equal(r0, r1, res0, res1);
    }

    // problem with converting bytes to string or vice versa to make assertion
    // function testUint512_to_bytes() public {
    //     uint256 hi = 0x4fffffffdfffffffffffffffefffffffbffffffff0000000000000003;
    //     uint256 lo = 0x8ab10928fe;
    //     // console.log(1);
    //     console.logBytes(Uint512.uint512_to_bytes(lo, hi));
    //     assertEq(bytes(0x00000004fffffffdfffffffffffffffefffffffbffffffff00000000000000030000000000000000000000000000000000000000000000000000008ab10928fe),
    //         Uint512.uint512_to_bytes(lo, hi));
    // }

}
