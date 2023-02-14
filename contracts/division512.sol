
	// // 1 means >, 0 means =, -1 means <
    // function compa(uint[2] calldata x, uint[2] calldata y) private pure returns(int8)
    // {
    //     uint len = x.length;
    //     // Compare the most significant bits first
    //     for (uint k = 0; k < len; ++k)
    //     {
    //         if (x[len-k-1] > y[len-k-1])
    //             return 1;
    //         else if (x[len-k-1] < y[len-k-1])
    //             return -1;
    //     }
    //     return 0;
    // }

	// uint[2] zero = [0, 0];             // bigInt zero
	// uint radix =    256;                // Size of uint
    // uint half =     2**(radix/2);       // Half bitwidth
	// uint low =      half - 1;           // Low mask
    // uint high =     low << (radix/2);   // High mask
	// uint max =      high | low;         // Max value



	// // Modulo for small, 2**(radix/2), modulus
    // function modSmall(uint[2] calldata x, uint m) private pure returns(uint)
    // {
    //     if (m > half)       // Check Assumption
    //         revert();
    //     if (m == 0)                 // Modulus is zero
    //         revert();
    //     if (compa(x, zero) == 0)    // Dividend is zero
    //         return 0;

    //     uint a =       ((max % m) + 1) % m;    // (2**radix) % m
    //     uint r =       1;
    //     uint result =  0;

    //     for (uint i = 0; i < x.length; ++i)
    //     {
    //         result =    (result + ((x[i] % m) * r) % m) % m;
    //         r =         (r * a) % m;
    //     }
    //     return result;
    // }


	// // Same effect as multipling by 2
    // function leftShift(uint[2] calldata x) private pure returns(uint[2] calldata)
    // {
    //     if (compa(x, zero) == 0)  // Return if zero
    //         return x;

    //     uint[2] memory r;
    //     uint carry;

    //     for (uint i = 0; i < x.length; ++i)
    //     {
    //         r[i] =  (x[i] << 1) + carry;
    //         carry = x[i] >> (radix - 1);
    //     }

    //     return r;
    // }

    // // Same effect as dividing by 2
    // function rightShift(uint[2] calldata x) private pure returns(uint[2] calldata)
    // {
    //     if (compa(x, zero) == 0)  // Return if zero
    //         return x;

    //     uint[2] memory r;
    //     uint carry;

    //     for (uint i = x.length-1; i < max ; --i)
    //     {
    //         r[i] =  (x[i] >> 1) + carry;
    //         carry = x[i] << (radix - 1);
    //     }

    //     return r;
    // }


	// // Result in Diff, Borrow is 1 if underflow
    // function sub(uint[2] calldata x, uint[2] calldata y) private returns(uint[2] calldata, uint)
    // {
    //     uint[2] memory diff;
    //     uint borrow;

    //     // Start from the least significant bits
    //     for (uint i = 0; i < x.length; ++i)
    //     {
    //         diff[i] =   x[i] - y[i] - borrow;
    //         if (x[i] < y[i] + borrow || (y[i] == max && borrow == 1))   // Check for underflow
    //             borrow = 1;
    //         else
    //             borrow = 0;
    //     }

    //     return (diff, borrow);
    // }


	// // https://github.com/Metaception/ethereum-thesis/blob/master/Solidity/paillierTally.sol
	// // Take the modulo using bitshift and subtraction
    // function mod512(uint[2] calldata x, uint[2] calldata m) 
	// private pure returns(uint[2] calldata) {
    //     // Check some special cases
    //     if (compa(m, zero) == 0)  // Modulus is zero
    //         revert();
    //     if (compa(x, zero) == 0)  // Dividend is zero
    //         return x;
    //     if (compa(m, x) == 0)       // If dividend equal modulus
    //         return zero;
    //     if (compa(m, x) == 1)       // If modulus greater than dividend
    //         return x;
    //     if (m[1] == 0 && m[0] <= half)   // If modulus greater than dividend
    //         return [modSmall(x, m[0]), 0];

    //     uint[2] memory r = x;      // Remainder
    //     uint[2] memory n = m;      // Copy of modulus
    //     uint top = 2**(radix - 1);  // Highest bit

    //     // Align most significant bit
    //     while (compa(x, n) == 1 && n[n.length-1] & top != top)
    //         n = leftShift(n);
    //     if (compa(n, x) == 1)   // If modulus copy is now greater
    //         n = rightShift(n);

    //     // Subtract repeatedly until result is less than modulus
    //     while (compa(r, m) != -1)
    //     {
    //         if (compa(r, n) != -1)  // Subtract if modulus copy is less than
    //             (r,) =  sub(r, n);
    //         n =     rightShift(n);  // Bitshift modulus copy
    //     }
    //     return r;
    // }

