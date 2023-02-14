SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


import "contracts/Uint512.sol";
import "contracts/PointOperations.sol";
import "contracts/Hash512.sol";
import "contracts/Montgomery.sol";


/*
Параметрами схемы цифровой подписи являются:
- простое число р — модуль эллиптической кривой;
- эллиптическая кривая Е, задаваемая коэффициентами a, b из F;
- целое число m — порядок группы точек эллиптической кривой Е;
- простое число q — порядок циклической подгруппы группы точек эллиптической кривой Е, для 
которого выполнены следующие условия:
m = nq, n из Z, n > 1
[2^254 < q < 2^256 или 2^508 < q < 2^512];

- точка Р != 0 эллиптической кривой Е, с координатами (хр, уp), удовлетворяющая равенству qP = 0
- хэш-функция V* —» Vl, отображающая сообщения, представленные в виде двоичных векторов произвольной конечной длины, в двоичные вектора длины l бит. 
Хэш-функция определена в ГОСТ Р 34.11—2012. Если 2254 < q < 2256, то l = 256. Если 2508 < q < 2512, то /= 512.

Каждый пользователь схемы цифровой подписи должен обладать личными ключами:
- (закрытым) ключом подписи — (случайным) целым числом d, удовлетворяющим неравенству 0 < d < q
- (открытым) ключом проверки подписи — точкой эллиптической кривой Q с координатами (xq, yq), удовлетворяющей равенству dP = Q.

К приведенным выше параметрам схемы цифровой подписи предъявляют следующие требования:
- должно быть выполнено условие р^t != 1(mod q), для всех целых t = 1,2, ... B, где В = 31, если 
2^254 < q < 2^256, и В = 131, если 2^508< q < 2^512;
- должно быть выполнено неравенство m != p
- инвариант кривой должен удовлетворять условию J(E) !+ 0 и J(E) != 1728
*/

import "contracts/Uint512.sol";
import "contracts/Hash512.sol";

contract GostSignature {

    PointOperations public PO;
    Montgomery public Mont;

    // pre-computed constants
    // 2 ** 255
    uint256 constant private U255 = 57896044618658097711785492504343953926634992332820282019728792003956564819968;
    // 2 ** 254 - only lower bits; higher bits = 0
    uint256 constant private U254_0 = 28948022309329048855892746252171976963317496166410141009864396001978282409984;
    // 2 ** 508 - only higher bits; lower bits = 0
    uint256 constant private U508_1 = 7237005577332262213973186563042994240829374041602535252466099000494570602496;




    d(private key) * P(generator point) = Q(public key)
    function getPublicKey(uint256 d0, uint256 d1, uint256 px0, uint256 px1, uint256 py0, uint256 py1) 
    public pure returns (uint256 qx0, uint256 qx1, uint256 qy0, uint256 qy1) {
        (qx0, qx1, qy0, qy1) = scalarMultPoint(d0, d1, px0, px1, py0, py1);
    }



    function hash_message(bytes memory message, uint256 q0, uint256 q1) 
    public pure returns (bytes memory) {
        // check arguments: if q < 2^256 or q > 2^256 - two variants
        if(Uint512.lt512x512(q0, q1, 0, 1) && Uint512.gt512x512(q0, q1, U254_0, 0)) {
            // using 256-bit hash
            return (Hash512.hash(message));
        }
        else if (Uint512.gt512x512(q0, q1, 0, U508_1)) {
            // using 512-bit hash
            return (Hash512.hash(message));
        }
        else return message; // todo: throw error
    }


    // args = [p0, p1, a0, a1, b0, b1, m0, m1, q0, q1, x0, x1, y0, y1, d0, d1]
    function sign(
        uint256[16] memory args,
        bytes memory message
    )
    public returns(bytes memory result) {
        uint256 alpha0; uint256 alpha1;
        uint256 e0; uint256 e1;
        uint256 k0; uint256 k1;
        uint256 cx0; uint256 cx1;
        uint256 r0; uint256 r1;
        uint256 s0; uint256 s1;
        uint256 t0; uint256 t1;

        bytes memory hashed_message = hash_message(message, args[8], args[9]);
        // 2. hash from bytes to uint512
        (alpha0, alpha1) = Uint512.bytes_to_uint512(hashed_message);

        // e = alpha mod q
        // if e = 0, then e := 1
        (e0, e1) = Uint512.mod512(alpha0, alpha1, args[8], args[9]);
        if(Uint512.isZero512(e0, e1)) 
            (e0, e1) = (1, 0);

        do {
            do {
                // 3. generate random k: 0 < k < q 
                // for tests: k = 0x77105C9B20BCD3122823C8CF6FCC7B956DE33814E95B7FE64FED924594DCEAB3
                (k0, k1) = (0x77105C9B20BCD3122823C8CF6FCC7B956DE33814E95B7FE64FED924594DCEAB3, 0);

                // calculate point C = kP
                // find r = xc mod q
                // if r = 0, then generate another k in step 3
                (cx0, cx1, , ) = PO.affineScalarMul(k0, k1, args[10], args[11], args[12], args[13], args[2], args[3], args[8], args[9]);
                (r0, r1) = Uint512.mod512(cx0, cx1, args[8], args[9]);
            } while(!Uint512.isZero512(r0, r1));

            // 5. calc s = (rd + ke) mod q
            (s0, s1) = Mont.mont_mulmod(r0, r1, args[14], args[15], args[8], args[9]);
            (t0, t1) = Mont.mont_mulmod(k0, k1, e0, e1, args[8], args[9]);
            (s0, s1) = Uint512.add512x512mod(s0, s1, t0, t1, args[8], args[9]);
        } while(!Uint512.isZero512(s0, s1));

        // 6. binary vectors r and s - concatenate 
        result = abi.encode(r1, r0, s1, s0); // encodes to bytes in width of 256 bit
    }



    // ключ проверки подписи - Q(x0, x1, y0, y1)
    // args = [p0, p1, a0, a1, b0, b1, m0, m1, q0, q1, x0, x1, y0, y1, d0, d1]
    function verify(
        uint256[16] memory args,
        bytes memory signature,
        bytes memory message
    ) public returns(bool) {
        uint256 alpha0; uint256 alpha1;
        uint256 e0; uint256 e1;
        uint256 v0; uint256 v1;
        uint256 r0; uint256 r1;
        uint256 s0; uint256 s1;

        // 1. derive r and s from signature
        (r1, r0, s1, s0) = abi.decode(signature, (uint256, uint256, uint256, uint256));
        // if(0<r<q && 0<s<q) - ok, else return false
        if(
            Uint512.isZero512(r0, r1) || 
            Uint512.isZero512(s0, s1) ||
            Uint512.lt512x512(args[9], args[9], r0, r1) || 
            Uint512.lt512x512(args[9], args[9], s0, s1) 
        ) return false;

        // 2. hash from message
        bytes memory hashed_message = hash_message(message, args[8], args[9]);
        // 3. alpha = uint(hash(message)), then e = alpha mod q
        (alpha0, alpha1) = Uint512.bytes_to_uint512(hashed_message);
        (e0, e1) = Uint512.mod512(alpha0, alpha1, args[8], args[9]);
        if(Uint512.isZero512(e0, e1)) 
            (e0, e1) = (1, 0);

        // 4. v = e^-1 mod q
        (v0, v1) = invMod512(e0, e1, args[8], args[9]);

        // 5. z1 = s*v mod q, z2 = r*v mod q
        uint256[2] memory z1;
        uint256[2] memory z2;
        (z1[0], z1[1]) = Mont.mont_mulmod(s0, s1, v0, v1, args[8], args[9]);
        (z2[0], z2[1]) = Mont.mont_mulmod(r0, r1, v0, v1, args[8], args[9]);

        // 6. point C(xc, yx) = z1 * P - z2 * Q 
        uint256[4] memory point1;
        uint256[4] memory point2;

        (point1[0], point1[1], point1[2], point1[3] = PO.affineScalarMul(z[0], z[1], _x0, _x1, _y0, _y1, _a0, _a1, _p0, _p1);)


        uint256[4] C = PO.ecSub(point1, point2, _a0, _a1, _p0, _p1);
        // derive R = xc mod q
        (uint256 R0, uint256 R1) = Uint512.mod512(C[0], C[1], args[8], args[9]);

        // 7. if R == r return true        
        if(uint512.eq512x512(R0, R1, r0, r1)) return true;
        else return false;
    }


    //  result = (gcd0, gcd1, x0, x1, y0, y1)
    // a * x + b * y == gcd - наибольший общий делитель a и b
    function extended_eucledian(uint256[2] memory a, uint256[2] memory b)
    public returns (uint256[6] memory result) {
        (uint256 s0, uint256 s1) = (0, 0);
        (uint256 old_s0, uint256 old_s1) = (1, 0);
        (uint256 t0, uint256 t1) = (1, 0);
        (uint256 old_t0, uint256 old_t1) = (0, 0);
        uint256[2] memory r = b;
        uint256[2] memory old_r = a;
        uint256[2] memory q; // quotinent
        uint256[2] memory rem; // remainder
        uint256[2] memory temp;


        while(!Uint512.isZero512(r[0], r[1])) {
            (q[0], q[1], rem[0], rem[1]) = Uint512.divmod512(old_r[0], old_r[1], r[0], r[1]);
            (old_r[0], old_r[1], r[0], r[1]) = (r[0], r[1], rem[0], rem[1]);  // copy, not using pointers

            temp = Uint512.mul512x256(a0, a1, b);
        }

        return ([old_r[0], old_r[1], old_s0, old_s1, old_t0, old_t1]);
 
    // while r != 0:
    //     quotient = old_r // r
    //     old_r, r = r, old_r - quotient * r
    //     old_s, s = s, old_s - quotient * s
    //     old_t, t = t, old_t - quotient * t

    // return old_r, old_s, old_t
    }





    /// @return x such that ax = 1 (mod p)
    function invmod(uint a, uint p) internal constant returns (uint) {
        int t1;
        int t2 = 1;
        uint r1 = p;
        uint r2 = a;
        uint q;
        while (r2 != 0) {
            q = r1 / r2;
            (t1, t2, r1, r2) = (t2, t1 - int(q) * t2, r2, r1 - q * r2);
        }
        if (t1 < 0)
            return (p - uint(-t1));
        return uint(t1);
    }


    // function invMod512(uint256 a0, uint256 a1, uint256 p0, uint256 p1) 
	// public returns(uint256 res0, uint256 res1) {
    //     if(Uint512.isZero512(a0, a1) || Uint512.isZero512(p0, p1) || Uint512.eq512x512(a0, a1, p0, p1)) 
    //         //throw;
    //     if(Uint512.gt512x512(a0, a1, p0, p1)) 
    //         (a0, a1) = Uint512.mod512(a0, a1, p0, p1);
    //     return (a0, a1);
    //     // todo
    // }


}
