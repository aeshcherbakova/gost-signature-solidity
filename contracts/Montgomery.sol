// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "contracts/Uint512.sol";

    /*
    theory and formules
    _a = a * R mod N = MontgomeryMulMod(a, R^2) _____> Montgomery form
    a = _a * R^(_1) mod N = MontgomeryMulMod(_a, 1) _____> back to normal form
    T = _a * _b mod N = a * b * R^2 mod N _____> double_width intermediate product 
    _z = T * R^(_1) mod N _____> Mont reduction
    res = a * b = _z = (_a * _b * R^(_1)) mod N    ___> final result
    */

    /*
    Reduction:
    R*Rp + N*Np = 1 ____> find Rp1 and Np1 with python script of eucledian algo
    N*Np1 = _1 mod R
    if T mod R = x, then T*N*Np1 = _x mod R ____> T + T*N*Np1 = 0 mod R
    have to find m = T*Np1, then T + m*N will be divided by R (right shift)
    */

contract Montgomery {

    Uint512 public uint512;

    uint256 constant MAX_INT = 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff;

    struct Curve {
        uint256[5] params;
        bool flag;
    }
    mapping(bytes => Curve) public curves;

    // structure: abi.encode(n0, n1) => uint256 array [R_power(256 or 512), R_sq_0, R_sq_1, Np_0, Np_1]
    // data from this website: https://neuromancer.sk/std/gost/id-GostR3410-2001-CryptoPro-C-ParamSet#
    uint256[5] gost256 = [
        256,
        0x6e749e5b503b112ac0db8b05c83ad16a4af1f8ac73c6c555ecaed44677f7f28d,
        0x0,
        0x67d7afac65649e8268bfc2dc2297e1496da5b0aba16fb01066ff43a234713e85,
        0x1
    ];
    uint256[5] gost512 = [
        512,
        0xe23c04dc39c8c930929e0924887fab48561500cb39a9b66bb03174e56db6ba90,
        0x3057350e3201bb3680bc9d923a08f9a9d70dfcccc3dd062f0cc44723bcc36979,
        0x3d86f5322949b920af0456575d456e174c82666f7bb16c1e50bc7d084a21aae1,
        0xc291fbb5ae9c1e83f29f69d34ae1cb8a6d70de8fa5e5a4cb7f17bf1c5533cda9
    ];
    uint256[5] id_tc26_gost_3410_12_512_paramSet = [
        512,
        0xa06b76a2bae6fc8680b08b27e9cebbc7b55cd33800ab10e6546775b92106e979,
        0xb66ae6c00bebd6c3ee028bf9d8ed3314bab8be5dd7b1651dc7433579e382956f,
        0xccff552d202458521f1d429025bb495fb37706a5a530c4bc02ccc1665d51f223,
        0x25169b543b2963edaee66a23e4cd5a9526e51f000112cd25a4cf4d9022aa989
    ];
    uint256[5] id_tc26_gost_3410_12_512_paramSetB = [
        512,
        0xb1532b08f1e25e5cc55538cf997acac4267d56905313f38b3163da9749d3cb8b,
        0x21c65cda4cadccc0f96232d7a52b18fe9f96043308eeb401c385980eb887a3f9,
        0x9297f6e5632c895c82d4c0daebb2fb229987c4851656f7d3c07d62492cbac26b,
        0x7a2fb684ff4de946896af19d2ea094e16cb6299541678cea2c3067b7148187c7
    ];
    uint256[5] id_tc26_gost_3410_2012_256_paramSetA = [
        256,
        0xfb1fbc48b0f0eb4d0593365f9384bcd7556091c4805caa457cb446240dd1710,
        0x0,
        0x5260f9d578e2604002f9ff5f350498dfaa48059b4f8d1109035bdd1aeafdb0a9,
        0x1
    ];
    uint256[5] id_tc26_gost_3410_2012_512_paramSetC = [
        512,
        0x542f8f3fa490666ad016086ec2d4f903e79280282d956fcae58fa18ee6ca4eb6,
        0x394c72054d8503be8910352f3bea2192314e0a57f445b20e04f77045db49adc9,
        0xa741bfb17f50bc09f931fcfca507f4363767eb6752418a840ed9d8e0b6624e1b,
        0xe5ca44e2a518d364dfdea839b87a0debdfef40d8420f3680a2e06451b9269fcc
    ];
    uint256[5] id_GostR3410_2001_CryptoPro_A_ParamSet = [
        256,
        0x551fe9cb451179dbf74885d08a3714c6fb07f8222e76dd529ac2d7858e79a469,
        0x0,
        0xc04b107ff7e9db33bccb5ba48253457bc84a073d7cf985b09ee6ea0b57c7da65,
        0x0
    ];
    uint256[5] id_GostR3410_2001_CryptoPro_B_ParamSet = [
        256,
        0x9d1d2c4e50824664a2e7e2f6882cf102a3104a7ea43e85529b721f4e6cd7823,
        0x0,
        0x72a15d7fcb9bae40ee0e6fd42c6930fa4b51be0a5c35b7edca89614990611a91,
        0x1
    ];
    uint256[5] id_GostR3410_2001_CryptoPro_C_ParamSet = [
        256,
        0x7aa61b49a49d4759c67e5d0ee96e8ed304fda8694afda24be94faab66aba180e,
        0x0,
        0x74f56b1c98a76d0c091e6cb4728e451e500f146f349d7d87a1c6af0a552f7577,
        0x1
    ];


    

    function set_curves() public {
        curves[abi.encode(
            0x8000000000000000000000000000000150fe8a1892976154c59cfc193accf5b3,
            0x0
        )] = Curve(gost256, true);
        curves[abi.encode(
            0xa82f2d7ecb1dbac719905c5eecc423f1d86e25edbe23c595d644aaf187e6e6df,
            0x4531acd1fe0023c7550d267b6b2fee80922b14b2ffb90f04d4eb7c09b5d2d15d
        )] = Curve(gost512, true);
        curves[abi.encode(
            0x27e69532f48d89116ff22b8d4e0560609b4b38abfad2b85dcacdb1411f10b275,
            0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
        )] = Curve(id_tc26_gost_3410_12_512_paramSet, true);
        curves[abi.encode(
            0x49a1ec142565a545acfdb77bd9d40cfa8b996712101bea0ec6346c54374f25bd,
            0x8000000000000000000000000000000000000000000000000000000000000001
        )] = Curve(id_tc26_gost_3410_12_512_paramSetB, true);
        curves[abi.encode(
            0x400000000000000000000000000000000fd8cddfc87b6635c115af556c360c67,
            0x0
        )] = Curve(id_tc26_gost_3410_2012_256_paramSetA, true);
        curves[abi.encode(
            0xc98cdba46506ab004c33a9ff5147502cc8eda9e7a769a12694623cef47f023ed,
            0x3fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
        )] = Curve(id_tc26_gost_3410_2012_512_paramSetC, true);
        curves[abi.encode(
            0xffffffffffffffffffffffffffffffff6c611070995ad10045841b09b761b893,
            0x0
        )] = Curve(id_GostR3410_2001_CryptoPro_A_ParamSet, true);
        curves[abi.encode(
            0x800000000000000000000000000000015f700cfff1a624e5e497161bcc8a198f,
            0x0
        )] = Curve(id_GostR3410_2001_CryptoPro_B_ParamSet, true);
        curves[abi.encode(
            0x9b9f605f5a858107ab1ec85e6b41c8aa582ca3511eddfb74f02f3a6598980bb9,
            0x0
        )] = Curve(id_GostR3410_2001_CryptoPro_C_ParamSet, true);
    }


    // use only once, when need several operations with same modulo
    function find_curve(uint256 n0, uint256 n1) 
    public returns (uint256[5] memory curve) {
        Curve memory c = curves[abi.encode(n0, n1)];
        if(c.flag == false) {
            c = calc_new_curve(n0, n1);
        }
        // n0, n1, R_sq0, R_sq1, n_prime0 
        curve = [n0, n1, c.params[1], c.params[2], c.params[3]];
    }



    function mont_mulmod(uint256 a0, uint256 a1, uint256 b0, uint256 b1, uint256[5] memory curve) 
    public returns (uint256, uint256) {
        // uint256[2] memory R_sq = [curve[2], curve[3]];
        // uint256[2] memory n = [curve[0], curve[1]];

        // (a, b) -> to mont form
        // uint256 n_prime = curve.params[3];
        uint256[2] memory _a = to_mont([a0, a1], curve);
        uint256[2] memory _b = to_mont([b0, b1], curve);
        // Mon(_a, _b)
        uint256[2] memory _res = Mon(_a, _b, curve);
        // _res -> to norm form
        uint256[2] memory res = to_norm(_res, curve);
        return (res[0], res[1]);
    }
 

    function to_mont(uint256[2] memory a, uint256[5] memory curve) 
    public  returns (uint256[2] memory) {
        return Mon(a, [curve[2], curve[3]], curve);
    }

    function to_norm(uint256[2] memory a, uint256[5] memory curve) 
    public  returns (uint256[2] memory) {
        return Mon(a, [uint256 (1), uint256 (0)], curve);
    }


    function calc_new_curve(uint256 n0, uint256 n1) 
    public returns (Curve memory) {
        // переписать код с питона и сравнить газ
        uint256[5] memory params;
        if (n1 == 0) params[0] = 256;
        else params[0] = 512;
        params[1] = uint256(0);
        params[2] = uint256(0);
        params[3] = uint256(0);
        params[4] = uint256(0);

        return(Curve(params, true));


        // extended eucledian algorythm (R, n)
        (uint256 prev_x0, uint256 prev_x1) = (1, 0);
        (uint256 x0, uint256 x1) = (0, 0);
        (uint256 prev_y0, uint256 prev_y1) = (0, 0);
        (uint256 y0, uint256 y1) = (1, 0);

    // сложно, потому что R = 2**512 выходит за пределы

    // def extended_euclidean(R, n):
//     previous_x, x = 1, 0
//     previous_y, y = 0, 1
//     while b:
//         q = R//n
//         x, previous_x = previous_x - q*x, x
//         y, previous_y = previous_y - q*y, y
//         R, n = n, R % n
//     return R, previous_x, previous_y
// returning R is only for checking if function ended correctly (R == 1)


        curves[abi.encode(n0, n1)] = Curve(params, true);
    }




    // Mon(_a, _b) = _c; to_norm(_c) = c = ab mod n - final result
    // Mon(a, R^2) = _a
    // Mon(_a, 1) = a
    function Mon(uint256[2] memory a, uint256[2] memory b, uint256[5] memory curve) 
    public  returns(uint256[2] memory r) 
    {
        // _temp = a*b (1024_bit) 3 _ highest, 0 _ lowest bits
        uint256[2] memory n = [curve[0], curve[1]];
        uint256[4] memory temp;
        uint256 hi; uint256 lo;
        uint i; uint j; uint carry;

        for(i = 0; i !=2; ++i) {
            carry = 0;
            for(j = 0; j != 2; ++j) {
                (lo, hi) = uint512.mul256x256(a[j], b[i]);
                (lo, hi) = uint512.add512x512(lo, hi, temp[i+j], 0);
                (lo, hi) = uint512.add512x512(lo, hi, carry, 0);
                // powers: (2**256-1)*(2**256-1) + (2**256-1) + (2**256-1) = 2**512-1 => no overflow
                temp[i+j] = lo;
                carry = hi;
            }
            temp[i+2] += carry;
            uint256 m = temp[i] * curve[4];
            // (uint256 m, ) = uint512.mul256x256(temp[i], n_prime);  // dealing with overflow
            // uint256 m = temp[i]*n_prime;
            carry = 0;
            for(j = 0; j != 2; ++j) {
                (lo, hi) = uint512.mul256x256(m, n[j]);
                (lo, hi) = uint512.add512x512(lo, hi, temp[i+j], 0);
                (lo, hi) = uint512.add512x512(lo, hi, carry, 0);
                // powers: (2**256-1)*(2**256-1) + (2**256-1) + (2**256-1) = 2**512-1 => no overflow
                temp[i+j] = lo;
                carry = hi;
            }
            temp[i+2] += carry;
        }
        uint256[2] memory dec;
        uint256 borrow = 0; uint256 diff; 
        bool borrow_t0;
        for(j = 0; j != 2; ++j) {
            if (temp[j] > n[j] + borrow) {
                borrow_t0 = false;
            }
            else {
                borrow_t0 = true;
            }
            unchecked { diff = temp[j] - n[j] - borrow; }
            dec[j] = diff;
            borrow = borrow_t0 ? 1 : 0;
        }
        // wrapping_neg() in Rust
        // google VirtualMachineError: revert: Integer overflow and how to use unchecked {} in solidity
        uint256[2] memory select_temp = [0, MAX_INT];
        if(borrow == 0) {
            select_temp = [0, MAX_INT];
        } else {  // if borrow == 1
            select_temp = [MAX_INT, 0];
        }
        for(j = 0; j != 2; ++j) {
            r[j] = (select_temp[0] & temp[j+2]) | (select_temp[1] & dec[j]);
        }
        return r;
    }




}
