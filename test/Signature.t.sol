// SPDX-License-Identifier: GPLv3
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../contracts/Signature.sol";
import {console} from "forge-std/console.sol";

contract SignatureTest is Test {

    function testGetMessageHash() public {
    // 1. Unlock MetaMask account
        // ethereum.enable();
    // 2. Get message hash to sign
        bytes32 hash_result = Signature.getMessageHash(
            0x14723A09ACff6D2A60DcdF7aA4AFf308FDDC160C, 
            123, 
            "coffee and donuts", 
            1
        );
        bytes32 hash_check = 0xcf36ac4f97dc10d91fc2cbb20d718e94a8cbfe0f82eaedc6a4aa38946fb797cd;
        // console.logBytes32(hash_check);
        // console.logBytes32(hash_result);
        assertEq32(hash_check, hash_result);
    }


    function testPrefixed() public {
        /* 3. Sign message hash
        # using browser
        account = "copy paste account of signer here"
        ethereum.request({ method: "personal_sign", params: [account, hash]}).then(console.log)

        # using web3
        web3.personal.sign(hash, web3.eth.defaultAccount, console.log)

        Signature will be different for different accounts
        0x993dab3dd91f5c6dc28e17439be475478f5635c92a56e17e82349d3fb2f166196f466c0b4e0c146f285204f0dcb13e5ae67bc33f4b888ec32dfe0a063e8f3f781b
        */
        /*
        Signature is produced by signing a keccak256 hash with the following format:
        "\x19Ethereum Signed Message\n" + len(msg) + msg
        */


        
        // bytes32 _messageHash = 0xcf36ac4f97dc10d91fc2cbb20d718e94a8cbfe0f82eaedc6a4aa38946fb797cd;
        // bytes32 hash_result = Signature.prefixed(_messageHash);
        // // bytes32 hash_check = 0x993dab3dd91f5c6dc28e17439be475478f5635c92a56e17e82349d3fb2f166196f466c0b4e0c146f285204f0dcb13e5ae67bc33f4b888ec32dfe0a063e8f3f781b;
        // bytes32 hash_check = 0x0f36ac4f97dc10d91fc2cbb20d718e94a8cbfe0f82eaedc6a4aa38946fb797cd;
        // assertEq32(hash_check, hash_result);
    }
   
}
