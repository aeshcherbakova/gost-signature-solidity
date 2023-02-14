// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// import {console} from "forge-std/console.sol";



contract Uint512 {

	uint256 constant MAX_INT = 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff;
	uint256 constant internal ONE = uint(1);


	function empty() 
	public pure {}



    // returns 1 if a < b, 0 otherwise
    function lt512x512(uint256 a0, uint256 a1, uint256 b0, uint256 b1) 
	public pure  returns (bool r) {
        assembly {
            r := or(lt(a1, b1), and(eq(a1, b1), lt(a0, b0)))
        }
    }

    // returns 1 if a > b, 0 otherwise
    function gt512x512(uint256 a0, uint256 a1, uint256 b0, uint256 b1) 
	public pure  returns (bool r) {
        assembly {
            r := or(gt(a1, b1), and(eq(a1, b1), gt(a0, b0)))
        }
    }

    // returns 1 if a == b, 0 otherwise
    function eq512x512(uint256 a0, uint256 a1, uint256 b0, uint256 b1) 
	public pure  returns (bool r) {
        assembly {
            r := and(eq(a0, b0), eq(a1, b1))
        }
    }

	// returns 1 if a == 0, 0 otherwise
    function isZero512(uint256 a0, uint256 a1) 
	public pure  returns (bool r) {
        assembly {
            r := and(eq(a0, 0), eq(a1, 0))
        }
    }

    // expect a and b be already properly reduced by modulus n
	// if a + b > n, then r = a + b - n
	// if a + b overflow 512 bit, then calc a+b-n = a-(n-b) 
    function add512x512mod(uint256 a0, uint256 a1, uint256 b0, uint256 b1, uint256 n0, uint256 n1) 
    public pure  returns (uint256 r0, uint256 r1) {
        (r0, r1) = add512x512(a0, a1, b0, b1);
		if (lt512x512(r0, r1, a0, a1)) {
			(uint256 t0, uint256 t1) = sub512x512(n0, n1, b0, b1);
			(r0, r1) = sub512x512(a0, a1, t0, t1);
		}
        else if (!lt512x512(r0, r1, n0, n1)) {
            (r0, r1) = sub512x512(r0, r1, n0, n1);
        }
    }

	// expect a and b be already properly reduced by modulus n
	// if a - b < 0 -> r = n - (a - b)
    function sub512x512mod(uint256 a0, uint256 a1, uint256 b0, uint256 b1, uint256 n0, uint256 n1) 
    public pure  returns (uint256 r0, uint256 r1) {
        (r0, r1) = sub512x512(a0, a1, b0, b1);
		if (gt512x512(r0, r1, a0, a1)) {
			(r0, r1) = sub512x512(n0, n1, r0, r1);
		}
    }


	// a(512-bit) mod n(256-bit)
	function mod256(uint256 x0, uint256 x1, uint256 n) 
	public pure  returns (uint256 rem) {
		assembly {
			rem := mulmod(x1, not(0), n)
			rem := addmod(rem, x1, n)
			rem := addmod(rem, x0, n)
		}
	}





// ------------------------------------------------------------------------------------------------


    function mod512(uint256 x0, uint256 x1, uint256 n0, uint256 n1) 
	public pure returns(uint256 rem0, uint256 rem1) {
        // Check special cases
        if (isZero512(n0, n1))  // Modulus is zero
            revert();
        if (isZero512(x0, x1))  // Dividend is zero
            return (x0, x1);
        if (eq512x512(x0, x1, n0, n1))       // If dividend equal modulus
            return (0, 0);
        if (gt512x512(n0, n1, x0, x1))       // If modulus greater than dividend
            return (x0, x1);
        if (n1 == 0) {  						 // If modulus < 2**256
            return (mod256(x0, x1, n0), 0);
		}

		(rem0, rem1) = (x0, x1);
		uint256 top = 2**255;

		uint256[2] memory m = [n0, n1]; // copy of modulus
        // Align most significant bit
        while (gt512x512(x0, x1, m[0], m[1]) && m[m.length-1] & top != top) {
			(m[0], m[1]) = lshift512(m[0], m[1], 1);
		}

        if (gt512x512(m[0], m[1], x0, x1)) {  // If modulus copy is now greater
            (m[0], m[1]) = rshift512(m[0], m[1], 1);
		}

        // Subtract repeatedly until result is less than modulus
        while (!lt512x512(rem0, rem1, n0, n1)) {
            if (!lt512x512(rem0, rem1, m[0], m[1]))  // Subtract if modulus copy is less than
                (rem0, rem1) = sub512x512(rem0, rem1, m[0], m[1]);
            (m[0], m[1]) = rshift512(m[0], m[1], 1); // Bitshift modulus copy
        }
    }




	function divmod512(uint256 x0, uint256 x1, uint256 n0, uint256 n1) 
	public pure returns(uint256 res0, uint256 res1, uint256 rem0, uint256 rem1) {
        // Check special cases
        if (isZero512(n0, n1))  // Modulus is zero
            revert();
        if (isZero512(x0, x1))  // Dividend is zero
            return (0, 0, x0, x1);
        if (eq512x512(x0, x1, n0, n1))       // If dividend equal modulus
            return (1, 0, 0, 0);
        if (gt512x512(n0, n1, x0, x1))       // If modulus greater than dividend
            return (0, 0, x0, x1);
        if (n1 == 0) {  						 // If modulus < 2**256
			(res0, rem0) = div512x256(x0, x1, n0);
            return (res0, 0, rem0, 0);
		}

		(rem0, rem1) = (x0, x1);
		uint256 top = 2**255;

		uint256[2] memory m = [n0, n1]; // copy of modulus
        // Align most significant bit
        while (gt512x512(x0, x1, m[0], m[1]) && m[m.length-1] & top != top) {
			(m[0], m[1]) = lshift512(m[0], m[1], 1);
		}

        if (gt512x512(m[0], m[1], x0, x1)) {  // If modulus copy is now greater
            (m[0], m[1]) = rshift512(m[0], m[1], 1);
		}

		(res0, res1) = (0, 0);

        // Subtract repeatedly until result is less than modulus
        while (!lt512x512(rem0, rem1, n0, n1)) {
			(res0, res1) = lshift512(res0, res1, 1);
            if (!lt512x512(rem0, rem1, m[0], m[1])) {  // Subtract if modulus copy is less than
                (rem0, rem1) = sub512x512(rem0, rem1, m[0], m[1]);
				res0 = res0 | 0x1;
			}
            (m[0], m[1]) = rshift512(m[0], m[1], 1); // Bitshift modulus copy
        }
    }


	// Computes the index of the highest bit set in 'self'.
    // Returns the highest bit set as an 'uint8'.
    // Requires that 'self != 0'.
    function highestBitSet256(uint self) 
	internal pure  returns (uint256 highest) {
        require(self != 0);
        uint val = self;
        for (uint8 i = 128; i >= 1; i >>= 1) {
            if (val & (ONE << i) - 1 << i != 0) {
                highest += i;
                val >>= i;
            }
        }
    }


//-------------------------------------------------------


	// реализация "в лоб"
	function mul512x512res1024(uint256 a0, uint256 a1, uint256 b0, uint256 b1) 
	public returns(uint256[4] memory res) {
		uint256 temp0; uint256 temp1;
		uint256 old; 
		uint256 overflow = 0;
		(res[0], res[1]) = mul256x256(a0, b0);
		(temp0, res[2]) = mul256x256(a1, b0);
		old = res[1];
		unchecked { res[1] += temp0; }
		if(res[1] < old) overflow++;
		(temp0, temp1) = mul256x256(a0, b1);
		old = res[1];
		unchecked { res[1] += temp0;}
		if(res[1] < old) overflow++;
		old = res[2];
		unchecked { res[2] += overflow; }
		if(res[2] < overflow) overflow = 1;
		else overflow = 0;
		old = res[2];
		unchecked { res[2] += temp1; } 
		if(res[2] < old) overflow ++;
		(temp0, res[3]) = mul256x256(a1, b1);
		old = res[2];
		unchecked { res[2] += temp0; }
		if(res[2] < old) overflow ++;
		unchecked { res[3] += overflow; }		
	}



	// a (1024) mod n(512) = res(512)
	function mod512from1024(uint256[4] memory a, uint256 n0, uint256 n1) 
	public returns(uint256 res0, uint256 res1) {
		(res0, res1) = mod512(MAX_INT, MAX_INT, n0, n1);
		(res0, res1) = add512x512(res0, res1, 1, 0);
		(uint256 t0, uint256 t1) = mod512(a[2], a[3], n0, n1);
		(t0, t1) = mul512x256(res0, res1, t0);
		(res0, res1) = add512x512(res0, res1, t0, t1);
		(t0, t1) =  mod512(a[0], a[1], n0, n1);
		(res0, res1) = add512x512(res0, res1, t0, t1);
		(res0, res1) = mod512(res0, res1, n0, n1);
	}


	function mulmod512x512(uint256 a0, uint256 a1, uint256 b0, uint256 b1, uint256 n0, uint256 n1) 
	public returns(uint256 res0, uint256 res1) {
		uint256[4] memory mul = mul512x512res1024(a0, a1, b0, b1);
		return mod512from1024(mul, n0, n1);	
	}



//-------------------------------------------------------


	/// @notice Calculates the product of two uint256
	/// @dev Used the chinese remainder theoreme
	/// @param a A uint256 representing the first factor.
	/// @param b A uint256 representing the second factor.
	/// @return r0 The result as an uint512. r0 contains the lower bits.
	/// @return r1 The higher bits of the result.
	function mul256x256(uint256 a, uint256 b) 
	public pure  returns (uint256 r0, uint256 r1) {
		assembly {
			let mm := mulmod(a, b, not(0))
			r0 := mul(a, b)
			r1 := sub(sub(mm, r0), lt(mm, r0))
		}
	}



	/// @notice Calculates the product of two uint512 and uint256
	/// @dev Used the chinese remainder theoreme
	/// @param a0 A uint256 representing lower bits of the first factor.
	/// @param a1 A uint256 representing higher bits of the first factor.
	/// @param b A uint256 representing the second factor.
	/// @return r0 The result as an uint512. r0 contains the lower bits.
	/// @return r1 The higher bits of the result.
	function mul512x256(uint256 a0, uint256 a1, uint256 b) 
	public pure  returns (uint256 r0, uint256 r1) {
		assembly {
			let mm := mulmod(a0, b, not(0))
			r0 := mul(a0, b)
			r1 := sub(sub(mm, r0), lt(mm, r0))
			r1 := add(r1, mul(a1, b))
		}
	}




	// /// @notice Calculates the product of two uint512 and uint256
	// /// @dev Used the chinese remainder theoreme
	// /// @param a0 A uint256 representing lower bits of the first factor.
	// /// @param a1 A uint256 representing higher bits of the first factor.
	// /// @param b A uint256 representing the second factor.
	// /// @return r0 The result is 3 uint256. r0 contains the lower bits.
	// /// @return r1 The middle bits of the result.
	// /// @return r2 The higher bits of the result.
	// function mul512x256res768(uint256 a0, uint256 a1, uint256 b) public pure  returns (uint256 r0, uint256 r1, uint256 r2) {
	// 	assembly {
	// 		let mm := mulmod(a0, b, not(0))
	// 		r0 := mul(a0, b)
	// 		r1 := sub(sub(mm, r0), lt(mm, r0))
	// 		r1 := add(r1, mul(a1, b))
	// 	}
	// }




	/// @notice Calculates the product and remainder of two uint256
	/// @dev Used the chinese remainder theoreme
	/// @param a A uint256 representing the first factor.
	/// @param b A uint256 representing the second factor.
	/// @return r0 The result as an uint512. r0 contains the lower bits.
	/// @return r1 The higher bits of the result.
	/// @return r2 The remainder.
	function mulMod256x256(uint256 a, uint256 b, uint256 c) 
	public pure  returns (uint256 r0, uint256 r1, uint256 r2) {
		assembly {
			let mm := mulmod(a, b, not(0))
			r0 := mul(a, b)
			r1 := sub(sub(mm, r0), lt(mm, r0))
			r2 := mulmod(a, b, c)
		}
	}



	/// @notice Calculates the difference of two uint512
	/// @param a0 A uint256 representing the lower bits of the first addend.
	/// @param a1 A uint256 representing the higher bits of the first addend.
	/// @param b0 A uint256 representing the lower bits of the seccond addend.
	/// @param b1 A uint256 representing the higher bits of the seccond addend.
	/// @return r0 The result as an uint512. r0 contains the lower bits.
	/// @return r1 The higher bits of the result.
	function add512x512(uint256 a0, uint256 a1, uint256 b0, uint256 b1) 
	public pure returns (uint256 r0, uint256 r1) {
		assembly {
			r0 := add(a0, b0)
			r1 := add(add(a1, b1), lt(r0, a0))
		}
	}



	/// @notice Calculates the difference of two uint512
	/// @param a0 A uint256 representing the lower bits of the minuend.
	/// @param a1 A uint256 representing the higher bits of the minuend.
	/// @param b0 A uint256 representing the lower bits of the subtrahend.
	/// @param b1 A uint256 representing the higher bits of the subtrahend.
	/// @return r0 The result as an uint512. r0 contains the lower bits.
	/// @return r1 The higher bits of the result.
	function sub512x512(uint256 a0, uint256 a1, uint256 b0, uint256 b1) 
	public pure returns (uint256 r0, uint256 r1) {
		assembly {
			r0 := sub(a0, b0)
			r1 := sub(sub(a1, b1), lt(a0, b0))
		}
	}



	/// @notice Calculates the division of a 512 bit unsigned integer by a 256 bit integer. It 
	/// requires the remainder to be known and the result must fit in a 256 bit integer. 
	/// @dev For a detailed explaination see:  
	/// https://www.researchgate.net/public pureation/235765881_Efficient_long_division_via_Montgomery_multiply.
	/// @param a0 A uint256 representing the low bits of the nominator.
	/// @param a1 A uint256 representing the high bits of the nominator.
	/// @param b A uint256 representing the denominator.
	/// @param rem A uint256 representing the remainder of the devision. The algorithm is cheaper to compute if the remainder is known. The remainder often be retreived cheaply using the mulmod and addmod operations.
	/// @return r The result as an uint256. Result must have at most 256 bit.
	function divRem512x256(uint256 a0, uint256 a1, uint256 b, uint256 rem) 
	public pure  returns (uint256 r) {
		assembly {
			// subtract the remainder
			a1 := sub(a1, lt(a0, rem))
			a0 := sub(a0, rem)

			// The integer space mod 2**256 is not an abilian group on the multiplication operation. In fact the
			// multiplicative inserve only exists for odd numbers. The denominator gets shifted right until the
			// least significant bit is 1. To do this we find the biggest power of 2 that devides the denominator.
            let pow := and(sub(0, b), b)
            b := div(b, pow)

            // Also shift the nominator. We only shift a0 and the lower bits of a1 which are transfered into a0
			// by the shift operation. a1 no longer required for the calculation. This might sound odd, but in
			// fact under the conditions that r < 2**255 and a / b = (r * a) + rem with rem = 0 the value of a1
			// is uniquely identified. Thus the value is not needed for the calculation.
            a0 := div(a0, pow)
            pow := add(div(sub(0, pow), pow), 1)
            a0 := or(a0, mul(a1, pow))
		}


		// if a1 is zero after the shifting, a single word division is sufficient
		if (a1 == 0) return a0 / b;

		assembly {
			// Calculate the multiplicative inverse mod 2**256 of b. See the paper for details.
            let inv := xor(mul(3, b), 2)
            inv := mul(inv, sub(2, mul(b, inv)))
            inv := mul(inv, sub(2, mul(b, inv)))
            inv := mul(inv, sub(2, mul(b, inv)))
            inv := mul(inv, sub(2, mul(b, inv)))
            inv := mul(inv, sub(2, mul(b, inv)))
            inv := mul(inv, sub(2, mul(b, inv)))

            r := mul(a0, inv)
		}
	}



	/// @notice Calculates the division of a 512 bit unsigned integer by a 256 bit integer. It 
	/// requires the result to fit in a 256 bit integer. 
	/// @dev For a detailed explaination see:  
	/// https://www.researchgate.net/public pureation/235765881_Efficient_long_division_via_Montgomery_multiply.
	/// @param a0 A uint256 representing the low bits of the nominator.
	/// @param a1 A uint256 representing the high bits of the nominator.
	/// @param b A uint256 representing the denominator.
	/// @return r The result as an uint256. Result must have at most 256 bit.
	function div512x256(uint256 a0, uint256 a1, uint256 b) 
	public pure  returns (uint256 r, uint256 rem) {
		assembly {
			// calculate the remainder
			rem := mulmod(a1, not(0), b)
			rem := addmod(rem, a1, b)
			rem := addmod(rem, a0, b)

			// subtract the remainder
			a1 := sub(a1, lt(a0, rem))
			a0 := sub(a0, rem)

			// The integer space mod 2**256 is not an abilian group on the multiplication operation. In fact the
			// multiplicative inserve only exists for odd numbers. The denominator gets shifted right until the
			// least significant bit is 1. To do this we find the biggest power of 2 that devides the denominator.
            let pow := and(sub(0, b), b)
            b := div(b, pow)

            // Also shift the nominator. We only shift a0 and the lower bits of a1 which are transfered into a0
			// by the shift operation. a1 no longer required for the calculation. This might sound odd, but in
			// fact under the conditions that r < 2**255 and a / b = (r * a) + rem with rem = 0 the value of a1
			// is uniquely identified. Thus the value is not needed for the calculation.
            a0 := div(a0, pow)
            pow := add(div(sub(0, pow), pow), 1)
            a0 := or(a0, mul(a1, pow))
		}

		// if a1 is zero after the shifting, a single word division is sufficient
		if (a1 == 0) return (a0 / b, rem);

		assembly {
			// Calculate the multiplicative inverse mod 2**256 of b. See the paper for details.
            let inv := xor(mul(3, b), 2)
            inv := mul(inv, sub(2, mul(b, inv)))
            inv := mul(inv, sub(2, mul(b, inv)))
            inv := mul(inv, sub(2, mul(b, inv)))
            inv := mul(inv, sub(2, mul(b, inv)))
            inv := mul(inv, sub(2, mul(b, inv)))
            inv := mul(inv, sub(2, mul(b, inv)))

            r := mul(a0, inv)
		}
	}


	// left shift a << n
	function lshift512(uint256 a0, uint256 a1, uint256 n) 
	public pure  returns (uint256 r0, uint256 r1) {
		assembly {
				let sh := shr(sub(256, n), a0)
				r1 := add(shl(n, a1),  sh)
				r0 := shl(n, a0)
		}
	}


	// todo: n > 2^256
	// left shift a << n
	function rshift512(uint256 a0, uint256 a1, uint256 n) 
	public pure  returns (uint256 r0, uint256 r1) {
		assembly {
			let sh := shl(sub(256, n), a1)
			r0 := add(shr(n, a0),  sh)
			r1 := shr(n, a1)
		}
	}



	function bytes_to_uint512(bytes memory data) 
    public pure  returns(uint256 m0, uint256 m1) {
        (m1, m0) = abi.decode(data, (uint256, uint256));
    }



    function uint512_to_bytes(uint256 m0, uint256 m1) 
    public pure  returns(bytes memory) {
        return abi.encode(m1, m0);
    }


	// function foo(uint256[2] calldata arr) public pure  returns (uint256) {
	// 	return arr.length;
	// }


	


 
}