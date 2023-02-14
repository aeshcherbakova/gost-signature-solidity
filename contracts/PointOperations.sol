// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "contracts/Uint512.sol";
import "contracts/Montgomery.sol";
// import "interfaces/Montgomery_int.sol";


contract PointOperations {

    Uint512 public uint512;
    Montgomery public Mont;

    // Multiply point P(_x, _y) times _d in affine coordinates.
    // (qx, qy) = d*P in affine coordinates
    function affineScalarMul(
        uint256 _d0, uint256 _d1,
        uint256 _x0, uint256 _x1,
        uint256 _y0, uint256 _y1,
        uint256 _a0, uint256 _a1,
        uint256[5] memory curve)
    public returns(uint256[4] memory xy)
    {
        // xyz = [x0, x1, y0, y1, z0, z1] - coordinates of P(_x,_y) in projective 
        // multiplication in projective (z = 1)
        uint256[6] memory xyz = projectiveScalarMul(_d0, _d1, [_x0, _x1, _y0, _y1, 1, 0], _a0, _a1, curve);
        // Get back to affine
        xy = toAffine(xyz, curve);
    }



    // from standard projective to affine
    // (x/z, y/z) ~ (x, y, z)
    // x/z mod p = x * zInv mod p
    // xyz = [x0, x1, y0, y1, z0, z1] - coordinates of P(_x,_y) in projective 
    // _xy = [_x0, _x1, _y0, _y1] - coordinates of P(_x,_y) in Affine
    function toAffine(uint256[6] memory xyz, uint256[5] memory curve)
    public returns (uint256[4] memory _xy)
    {
        (uint256 zInv0, uint256 zInv1) = invMod(xyz[4], xyz[5], curve);
        (_xy[0], _xy[1]) = Mont.mont_mulmod(xyz[0], xyz[1], zInv0, zInv1, curve);
        (_xy[2], _xy[3]) = Mont.mont_mulmod(xyz[2], xyz[3], zInv0, zInv1, curve);
    }




    function invMod(uint256 _x0, uint256 _x1, uint256[5] memory curve) 
    public returns (uint256, uint256) 
    {
        require(!uint512.isZero512(_x0, _x1) && 
                !uint512.eq512x512(_x0, _x1, curve[0], curve[1]) && 
                !uint512.isZero512(curve[0], curve[1]),     // curve[0], curve[1] = modulo
                "Invalid number");
        uint256[2] memory q = [uint256(0), uint256(0)];
        uint256[2] memory newT = [uint256(1), uint256(0)];
        uint256[2] memory r = [curve[0], curve[1]];
        uint256[2] memory t;
        uint256[6] memory temp; // 0,1 -add, 2,3 - sub, 4,5 - mul 


        while (!uint512.isZero512(_x0, _x1)) {
                // t = r / _x;
            (t[0], t[1], , ) = uint512.divmod512(r[0], r[1], _x0, _x1);

                // (q, newT) = (newT, addmod(q, (_pp - mulmod(t, newT, _pp)), _pp));
            (temp[4], temp[5]) = Mont.mont_mulmod(t[0], t[1], newT[0], newT[1], curve);
            (temp[2], temp[3]) = uint512.sub512x512(curve[0], curve[1], temp[4], temp[5]);
            (temp[0], temp[1]) = uint512.add512x512mod(q[0], q[1], temp[2], temp[3], curve[0], curve[1]);
            (q[0], q[1], newT[0], newT[1]) = (newT[0], newT[1], temp[0], temp[1]);

                // (r, _x) = (_x, r - t * _x);
            (temp[4], temp[5]) = Mont.mont_mulmod(t[0], t[1], _x0, _x1, curve);  // todo: mul or mulmod?
            (temp[2], temp[3]) = uint512.sub512x512(r[0], r[1], temp[4], temp[5]);
            (r[0], r[1], _x0, _x1) = (_x0, _x1, temp[2], temp[3]);

            // eucledian:
            // while (_x != 0) {
            //     t = r / _x;
            //     (q, newT) = (newT, addmod(q, (_pp - mulmod(t, newT, _pp)), _pp));
            //     (r, _x) = (_x, r - t * _x);
            //     }
        }
        return (q[0], q[1]);
    }




    // Multiply point (x, y, z) times d in projective
    function projectiveScalarMul(
        uint256 _d0, uint256 _d1,
        uint256[6] memory xyz,
        uint256 _a0, uint256 _a1,
        uint256[5] memory curve)
    internal returns (uint256[6] memory res_xyz)
    {
        // Early return in case that `_d == 0`
        if (uint512.isZero512(_d0, _d1)) {
            return (xyz);
        }

        // remaining
        (uint256 rem0, uint256 rem1) = (_d0, _d1);
        // res_xyz = [0, 0, 0, 0, 1, 0];
        res_xyz = [uint256(0), uint256(0), uint256(0), uint256(0), uint256(1), uint256(0)];

        // Double and add algorithm
        while (!uint512.isZero512(rem0, rem1)) {
            if ((rem0 & 1) != 0) {
                res_xyz = projectiveAdd(
                res_xyz,
                xyz,
                _a0, _a1,
                curve);
            }
            (rem0, rem1) = uint512.rshift512(rem0, rem1, 1);
            xyz = projectiveDouble(
                xyz,
                _a0, _a1,
                curve);
        }
    }




    //  P1(_x, _y, _z) + P2(x, y, z) = Q(qx, qy, qz)
    // E = Y1*Z2, F = Y2*Z1, I = X1*Z2, J = X2*Z1
    // B = E+F, A = I+J, C = Z1*Z2, D = C*B 
    // Z3 = B^2 * D
    // X3 = (A^2+A*B)*D + a*Z3 + B^4
    // Y3 = B^2*(F*I+E*J) + X3*(A+B)
    function projectiveAdd(
        uint256[6] memory xyz1,
        uint256[6] memory xyz2,
        uint256 _a0, uint256 _a1,
        uint256[5] memory curve)
    internal returns (uint256[6] memory res_xyz) {

        for (uint256 i = 0; i < 20; i ++)
            Mont.mont_mulmod(xyz1[0], xyz1[2], xyz1[2], xyz1[3], curve);
        return ([uint256(0), uint256(0), uint256(0), uint256(0), uint256(0), uint256(0)]);



        if(uint512.isZero512(xyz1[0], xyz1[1]) && uint512.isZero512(xyz1[2], xyz1[3])) 
            return(xyz1);
        if(uint512.isZero512(xyz2[0], xyz2[1]) && uint512.isZero512(xyz2[2], xyz2[3])) 
            return(xyz2);

        uint256[2] memory A;
        uint256[2] memory B;
        uint256[2] memory C;
        uint256[2] memory D;
        uint256[2] memory E;
        uint256[2] memory F;
        uint256[2] memory J;
        uint256[2] memory I;
        uint256[2] memory Bsq; // Bsq = B*B = B^2
        uint256[2] memory temp;

        // E = Y1*Z2, F = Y2*Z1, I = X1*Z2, J = X2*Z1
        // B = E+F, A = I+J, C = Z1*Z2, D = C*B 
        (E[0], E[1]) = Mont.mont_mulmod(xyz1[2], xyz1[3], xyz2[4], xyz2[5], curve);
        (F[0], F[1]) = Mont.mont_mulmod(xyz2[2], xyz2[3], xyz1[4], xyz1[5], curve);
        (I[0], I[1]) = Mont.mont_mulmod(xyz1[0], xyz1[1], xyz2[4], xyz2[5], curve);  
        (J[0], J[1]) = Mont.mont_mulmod(xyz2[0], xyz2[1], xyz1[4], xyz1[5], curve); 
        (B[0], B[1]) = uint512.add512x512mod(E[0], E[1], F[0], F[1], curve[0], curve[1]);
        (A[0], A[1]) = uint512.add512x512mod(I[0], I[1], J[0], J[1], curve[0], curve[1]);
        (C[0], C[1]) = Mont.mont_mulmod(xyz1[4], xyz1[5], xyz2[4], xyz2[5], curve);
        (D[0], D[1]) = Mont.mont_mulmod(C[0], C[1], B[0], B[1], curve);
        (Bsq[0], Bsq[1]) = Mont.mont_mulmod(B[0], B[1], B[0], B[1], curve);


        // Z3 = B^2 * D
        (res_xyz[4], res_xyz[5]) = Mont.mont_mulmod(Bsq[0], Bsq[1], D[0], D[1], curve);


        // X3 = (A^2+A*B)*D + a*Z3 + B^4
        (res_xyz[0], res_xyz[1]) = Mont.mont_mulmod(A[0], A[1], A[0], A[1], curve);
        // temp = A*B
        (temp[0], temp[1]) = Mont.mont_mulmod(A[0], A[1], B[0], B[1], curve);  
        (res_xyz[0], res_xyz[1]) = uint512.add512x512mod(res_xyz[0], res_xyz[1], temp[0], temp[1], curve[0], curve[1]);
        (res_xyz[0], res_xyz[1]) = Mont.mont_mulmod(res_xyz[0], res_xyz[1], D[0], D[1], curve);
        // temp = a*Z3
        (temp[0], temp[1]) = Mont.mont_mulmod(_a0, _a1, res_xyz[4], res_xyz[5], curve);
        (res_xyz[0], res_xyz[1]) = uint512.add512x512mod(res_xyz[0], res_xyz[1], temp[0], temp[1], curve[0], curve[1]);
        // temp = B^4
        (temp[0], temp[1]) = Mont.mont_mulmod(Bsq[0], Bsq[1], Bsq[0], Bsq[1], curve);
        (res_xyz[0], res_xyz[1]) = uint512.add512x512mod(res_xyz[0], res_xyz[1], temp[0], temp[1], curve[0], curve[1]);


        // Y3 = B^2*(F*I+E*J) + X3*(A+B)
        (res_xyz[2], res_xyz[3]) = Mont.mont_mulmod(F[0], F[1], I[0], I[1], curve);
        // temp = E*J
        (temp[0], temp[1]) = Mont.mont_mulmod(E[0], E[1], J[0], J[1], curve);
        (res_xyz[2], res_xyz[3]) = uint512.add512x512mod(res_xyz[2], res_xyz[3], temp[0], temp[1], curve[0], curve[1]);
        (res_xyz[2], res_xyz[3]) = Mont.mont_mulmod(res_xyz[2], res_xyz[3], Bsq[0], Bsq[1], curve);
        // temp = A+B
        (temp[0], temp[1]) = uint512.add512x512mod(A[0], A[1], B[0], B[1], curve[0], curve[1]);
        // temp = X3*(A+B)
        (temp[0], temp[1]) = Mont.mont_mulmod(temp[0], temp[1], res_xyz[0], res_xyz[1], curve);
        (res_xyz[2], res_xyz[3]) = uint512.add512x512mod(res_xyz[2], res_xyz[3], temp[0], temp[1], curve[0], curve[1]);
    }




    // point doubling: P3(res_xyz) = P1(xyz) + P1(xyz)
    // A = Y1*Z1+C, B = X1*Z1, C = X1^2
    // Z3 = B^2*B
    // X3 = A*B*(A+B)+a*Z3
    // Y3 = X3*(A+B)+C*X1
    function projectiveDouble(
        uint256[6] memory xyz,
        uint256 _a0, uint256 _a1,
        uint256[5] memory curve)
    internal returns (uint256[6] memory res_xyz) {
        if (uint512.isZero512(xyz[4], xyz[5]))
            return (xyz);

        uint256[2] memory A;
        uint256[2] memory B;
        uint256[2] memory C;
        uint256[2] memory D;
        uint256[2] memory temp;

        (C[0], C[1]) = Mont.mont_mulmod(xyz[0], xyz[1], xyz[0], xyz[1], curve);
        (B[0], B[1]) = Mont.mont_mulmod(xyz[0], xyz[1], xyz[4], xyz[5], curve);
        (A[0], A[1]) = Mont.mont_mulmod(xyz[2], xyz[3], xyz[4], xyz[5], curve);  
        (A[0], A[1]) = uint512.add512x512mod(A[0], A[1], C[0], C[1], curve[0], curve[1]);
        // D = A+B
        (D[0], D[1]) = uint512.add512x512mod(A[0], A[1], B[0], B[1], curve[0], curve[1]);


        // Z3 = B^2 * B
        (res_xyz[4], res_xyz[5]) = Mont.mont_mulmod(B[0], B[1], B[0], B[1], curve);
        (res_xyz[4], res_xyz[5]) = Mont.mont_mulmod(res_xyz[4], res_xyz[5], B[0], B[1], curve);

        // X3 = A*B*(A+B) + a*Z3
        (res_xyz[0], res_xyz[1]) = Mont.mont_mulmod(A[0], A[1], B[0], B[1], curve);
        (res_xyz[0], res_xyz[1]) = Mont.mont_mulmod(res_xyz[0], res_xyz[1], D[0], D[1], curve);
        // temp = a*Z3
        (temp[0], temp[1]) = Mont.mont_mulmod(_a0, _a1, res_xyz[4], res_xyz[5], curve);
        (res_xyz[0], res_xyz[1]) = uint512.add512x512mod(res_xyz[0], res_xyz[1], temp[0], temp[1], curve[0], curve[1]);

        // Y3 = X3*(A+B)+C*X1
        (res_xyz[2], res_xyz[3]) = Mont.mont_mulmod(res_xyz[0], res_xyz[1], D[0], D[1], curve);
        // temp = C*X1
        (temp[0], temp[1]) = Mont.mont_mulmod(C[0], C[1], xyz[0], xyz[1], curve);
        (res_xyz[2], res_xyz[3]) = uint512.add512x512mod(res_xyz[2], res_xyz[3], temp[0], temp[1], curve[0], curve[1]);
    }



    /// dev Calculate inverse (x, -y) of point (x, y).
    /// return (x, -y)
    function ecInv(
        uint256[4] memory xy,
        uint256 _p0, uint256 _p1)
    internal  returns (uint256[4] memory x_y) {
        (x_y[0], x_y[1]) = (xy[0], xy[1]);
        (x_y[2], x_y[3]) = uint512.sub512x512(_p0, _p1, x_y[2], x_y[3]);
        (x_y[2], x_y[3]) = uint512.mod512(x_y[2], x_y[3], _p0, _p1);
        // return (_x, (_pp - _y) % _pp);
    }



    // subtract two points
    // (res_xy) = P1(xy1) - P2(xy2) in affine coordinates
    function ecSub(
        uint256[4] memory xy1,
        uint256[4] memory xy2,
        uint256 _a0, uint256 _a1,
        uint256[5] memory curve
    ) public returns(uint256[4] memory res_xy) {
        // invert P2
        uint256[4] memory _xy2 = ecInv(xy2, curve[0], curve[1]);
        // P1 + (-P2)
        return affineAdd(
            xy1,
            _xy2,
            _a0, _a1,
            curve);
    }


    function affineAdd(
        uint256[4] memory xy1,
        uint256[4] memory xy2,
        uint256 _a0, uint256 _a1,
        uint256[5] memory curve) 
    public returns(uint256[4] memory) {
        uint256[6] memory result = [uint256(0), uint256(0), uint256(0), uint256(0), uint256(0), uint256(0)];

        // Double if x1==x2 else add
        if (uint512.eq512x512(xy1[0], xy1[1], xy2[0], xy2[1])) {
            // y1 = -y2 mod p
            (uint256 temp0, uint256 temp1) = uint512.add512x512mod(xy1[2], xy1[3], xy2[2], xy2[3], curve[0], curve[1]);
            if (uint512.isZero512(temp0, temp1)) {
                return([uint256(0), uint256(0), uint256(0), uint256(0)]);
            } else {
                // P1 = P2
                result = projectiveDouble( 
                    [xy1[0], xy1[1], xy1[2], xy1[3], 1, 0],
                    _a0, _a1,
                    curve
                );
            } 
        } else {
            result = projectiveAdd( 
                [xy1[0], xy1[1], xy1[2], xy1[3], 1, 0],
                [xy2[0], xy2[1], xy2[2], xy2[3], 1, 0],
                _a0, _a1,
                curve
            );
        }
        // Get back to affine
        return toAffine( result, curve);
    }



    function notProjectiveScalarMul(
        uint256 _d0, uint256 _d1,
        uint256 _x0, uint256 _x1,
        uint256 _y0, uint256 _y1,
        uint256 _a0, uint256 _a1,
        uint256[5] memory curve)
    public returns(uint256[4] memory res) {

        // Early return in case that `_d == 0`
        if (uint512.isZero512(_d0, _d1)) {
            return ([_x0, _x1, _y0, _y1]);
        }

        // remaining
        uint256[2] memory rem = [_d0, _d1];
        uint256[2] memory l; // lambda
        uint256[2] memory t;
        uint256[2] memory temp;
        res = [uint256(0), uint256(0), uint256(0), uint256(0)]; 

        // Double and add algorithm
        while (!uint512.isZero512(rem[0], rem[1])) {
            if ((rem[0] & 1) != 0) {
                // add
                (t[0], t[1]) = uint512.add512x512mod(res[2], res[3], _y0, _y1, curve[0], curve[1]);
                (temp[0], temp[1]) = uint512.add512x512mod(res[0], res[1], _x0, _x1, curve[0], curve[1]);
                (l[0], l[1]) = invMod(temp[0], temp[1], curve);
                (l[0], l[1]) = Mont.mont_mulmod(l[0], l[1], t[0], t[1], curve);
                (res[2], res[3]) = uint512.add512x512mod(res[2], res[3], l[0], l[1], curve[0], curve[1]);
                (res[0], res[1]) = uint512.add512x512mod(l[0], l[1], _y0, _y1, curve[0], curve[1]);
            }
            (rem[0], rem[1]) = uint512.rshift512(rem[0], rem[1], 1);
            // double
            (l[0], l[1]) = invMod(temp[0], temp[1], curve);
            (l[0], l[1]) = Mont.mont_mulmod(l[0], l[1], _y0, _y1, curve);
            (l[0], l[1]) = uint512.add512x512mod(l[0], l[1], _x0, _x1, curve[0], curve[1]);
            (res[2], res[3]) = uint512.add512x512mod(res[2], res[3], l[0], l[1], curve[0], curve[1]);
            (res[0], res[1]) = uint512.add512x512mod(l[0], l[1], _y0, _y1, curve[0], curve[1]);  
        }
    }

}