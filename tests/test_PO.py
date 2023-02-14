import pytest
from brownie import accounts, Montgomery, Uint512, PointOperations
import random
from scripts.helpful_scripts import *

CONST_a = 0xbef38558980cc4c4be07c6416b854f6eede590a86520c659f8a23d543c0d6fb7022279e7e3295ce6bc4f4cca50951ef42d6d6472c9a89d8e03989ec052bd8440
CONST_b = 0x59bd0fb9a19bf11a8c6b50df95ed0bae5ce6560591d25f6b09087b0aaf149ef17e56e04d3aae0c056c70690ca838a82fe1945a4df59baf657b4e36ca2e2105b8
# gost512
CONST_n = 0x4531acd1fe0023c7550d267b6b2fee80922b14b2ffb90f04d4eb7c09b5d2d15da82f2d7ecb1dbac719905c5eecc423f1d86e25edbe23c595d644aaf187e6e6df
CONST_c = 0x1491d33f74b7fff949be7b2a19ca1f7ef7ab17bcbba5939ea99b16e7d16248387c3466655784af1eb0211c4257a3893bb426f5db2bf311d777b59809db7657ff

CONST_p = 0x8000000000000000000000000000000000000000000000000000000000000431
CONST_d = 0x7A929ADE789BB9BE10ED359DD39A72C11B60961F49397EEE1D19CE9891EC3B28
CONST_m = 0x8000000000000000000000000000000150FE8A1892976154C59CFC193ACCF5B3
CONST_q = 0x8000000000000000000000000000000150FE8A1892976154C59CFC193ACCF5B3

random.seed()


def test_all_for_gas():
    uint512 = Uint512.deploy({'from': accounts[0]})
    mont = Montgomery.deploy({'from': accounts[0]})
    PO = PointOperations.deploy({'from': accounts[0]})
    a = 0x7
    # point from gost examples
    x = 0x24D19CC64572EE30F396BF6EBBFD7A6C5213B3B3D7057CC825F91093A68CD762FD60611262CD838DC6B60AA7EEE804E28BC849977FAC33B4B530F1B120248A9A
    y = 0x2BB312A43BD2CE6E0D020613C857ACDDCFBF061E91E5F2C3F32447C259F39B2C83AB156D77F1496BF7EB3351E1EE4E43DC1A18B91B24640B6DBB92CB1ADD371E
    d = 0xBA6048AADAE241BA40936D47756D7C93091A0E8514669700EE7508E508B102072E8123B2200A0563322DAD2827E2714A2636B7BFD18AADFC62967821FA18DD4
    curve = [*parse(CONST_n), 0xe23c04dc39c8c930929e0924887fab48561500cb39a9b66bb03174e56db6ba90, 
    0x3057350e3201bb3680bc9d923a08f9a9d70dfcccc3dd062f0cc44723bcc36979, 
    0x3d86f5322949b920af0456575d456e174c82666f7bb16c1e50bc7d084a21aae1]
    
    PO.affineScalarMul(*parse(d), *parse(x), *parse(y), *parse(a), curve)
    PO.notProjectiveScalarMul(*parse(d), *parse(x), *parse(y), *parse(a), curve)




def test_affineScalarMul():
    uint512 = Uint512.deploy({'from': accounts[0]})
    mont = Montgomery.deploy({'from': accounts[0]})
    lib = PointOperations.deploy({'from': accounts[0]})
    for _ in range(10):
        a, b, n = rand(3)
        assert lib.affineScalarMul(*parse(a % n), *parse(b % n), *parse(n)) == affineScalarMul(a, b, n)

    n = 0x4531acd1fe0023c7550d267b6b2fee80922b14b2ffb90f04d4eb7c09b5d2d15da82f2d7ecb1dbac719905c5eecc423f1d86e25edbe23c595d644aaf187e6e6df
    a = 0xb6a1584a3d7164bbd40d6a967bb72563761c11402abdeea1d8ecb7602597e122e3289712a8baaf690a148b607d74e20c94e0737c407da8177f8257d353431286
    b = 0x6abbee6b346429e597ff9b05d11cc1800a296dd711de3ea8c49b31616e2f70e06d8ce9521bd3ab1becfea568dcc7e2205175aa4f2faea0272220573f3fa0f4a8
    res = 0x1e2febbdba28b3d33594ed724ef98a7ba28962fdfc69da7cdba92fb12805dbeb9fcae126b4992432eed8cdd0a2c4f71f29cb180f215bcb58c1d35d91749b4923

    r = lib.affineScalarMul(*parse(a % n), *parse(b % n), *parse(n)) == affineScalarMul(a, b, n)
    print(r)
    assert res == r

    a = 0x8000000000000000000000000000000000000000000000000000000000000431
    b = 0x7A929ADE789BB9BE10ED359DD39A72C11B60961F49397EEE1D19CE9891EC3B28
    n = 0x8000000000000000000000000000000150FE8A1892976154C59CFC193ACCF5B3
    res = 0xe3289712a8baaf690a148b607d74e20c94e0737c407da8177f8257d353431286

    r = lib.affineScalarMul(*parse(a % n), *parse(b % n), *parse(n)) == affineScalarMul(a, b, n)
    print(r)
    assert res == r



def test_notProjectiveScalarMul():
    uint512 = Uint512.deploy({'from': accounts[0]})
    mont = Montgomery.deploy({'from': accounts[0]})
    lib = PointOperations.deploy({'from': accounts[0]})
    for _ in range(10):
        a, b, n = rand(3)
        assert lib.notProjectiveScalarMul(*parse(a % n), *parse(b % n), *parse(n)) == notProjectiveScalarMul(a, b, n)

    n = 0x4531acd1fe0023c7550d267b6b2fee80922b14b2ffb90f04d4eb7c09b5d2d15da82f2d7ecb1dbac719905c5eecc423f1d86e25edbe23c595d644aaf187e6e6df
    a = 0xb6a1584a3d7164bbd40d6a967bb72563761c11402abdeea1d8ecb7602597e122e3289712a8baaf690a148b607d74e20c94e0737c407da8177f8257d353431286
    b = 0x6abbee6b346429e597ff9b05d11cc1800a296dd711de3ea8c49b31616e2f70e06d8ce9521bd3ab1becfea568dcc7e2205175aa4f2faea0272220573f3fa0f4a8
    res = 0x1e2febbdba28b3d33594ed724ef98a7ba28962fdfc69da7cdba92fb12805dbeb9fcae126b4992432eed8cdd0a2c4f71f29cb180f215bcb58c1d35d91749b4923

    r = lib.notProjectiveScalarMul(*parse(a % n), *parse(b % n), *parse(n)) == notProjectiveScalarMul(a, b, n)
    print(r)
    assert res == r

    a = 0x8000000000000000000000000000000000000000000000000000000000000431
    b = 0x7A929ADE789BB9BE10ED359DD39A72C11B60961F49397EEE1D19CE9891EC3B28
    n = 0x8000000000000000000000000000000150FE8A1892976154C59CFC193ACCF5B3
    res = 0xe3289712a8baaf690a148b607d74e20c94e0737c407da8177f8257d353431286

    r = lib.notProjectiveScalarMul(*parse(a % n), *parse(b % n), *parse(n)) == notProjectiveScalarMul(a, b, n)
    print(r)
    assert res == r



def test_affineScalarMul():
    uint512 = Uint512.deploy({'from': accounts[0]})
    mont = Montgomery.deploy({'from': accounts[0]})
    lib = PointOperations.deploy({'from': accounts[0]})
    for _ in range(10):
        a, b, n = rand(3)
        assert lib.affineScalarMul(*parse(a % n), *parse(b % n), *parse(n)) == affineScalarMul(a, b, n)

    n = 0x4531acd1fe0023c7550d267b6b2fee80922b14b2ffb90f04d4eb7c09b5d2d15da82f2d7ecb1dbac719905c5eecc423f1d86e25edbe23c595d644aaf187e6e6df
    a = 0xb6a1584a3d7164bbd40d6a967bb72563761c11402abdeea1d8ecb7602597e122e3289712a8baaf690a148b607d74e20c94e0737c407da8177f8257d353431286
    b = 0x6abbee6b346429e597ff9b05d11cc1800a296dd711de3ea8c49b31616e2f70e06d8ce9521bd3ab1becfea568dcc7e2205175aa4f2faea0272220573f3fa0f4a8
    res = 0x1e2febbdba28b3d33594ed724ef98a7ba28962fdfc69da7cdba92fb12805dbeb9fcae126b4992432eed8cdd0a2c4f71f29cb180f215bcb58c1d35d91749b4923

    r = lib.affineScalarMul(*parse(a % n), *parse(b % n), *parse(n)) == affineScalarMul(a, b, n)
    print(r)
    assert res == r

    a = 0x8000000000000000000000000000000000000000000000000000000000000431
    b = 0x7A929ADE789BB9BE10ED359DD39A72C11B60961F49397EEE1D19CE9891EC3B28
    n = 0x8000000000000000000000000000000150FE8A1892976154C59CFC193ACCF5B3
    res = 0xe3289712a8baaf690a148b607d74e20c94e0737c407da8177f8257d353431286

    r = lib.affineScalarMul(*parse(a % n), *parse(b % n), *parse(n)) == affineScalarMul(a, b, n)
    print(r)
    assert res == r





def test_affineAdd():
    uint512 = Uint512.deploy({'from': accounts[0]})
    mont = Montgomery.deploy({'from': accounts[0]})
    lib = PointOperations.deploy({'from': accounts[0]})
    for _ in range(10):
        a, b, n = rand(3)
        assert lib.affineAdd(*parse(a % n), *parse(b % n), *parse(a % n), *parse(b % n), *parse(n)) == affineAdd(a, b, a, b, n)



def test_projectiveDouble():
    uint512 = Uint512.deploy({'from': accounts[0]})
    mont = Montgomery.deploy({'from': accounts[0]})
    lib = PointOperations.deploy({'from': accounts[0]})
    for _ in range(10):
        a, b, c, n = rand(4)
        assert lib.projectiveDouble(*parse(a % n), *parse(b % n), *parse(c % n), *parse(n)) == projectiveDouble(a, b, c, n)



def test_projectiveAdd():
    uint512 = Uint512.deploy({'from': accounts[0]})
    mont = Montgomery.deploy({'from': accounts[0]})
    lib = PointOperations.deploy({'from': accounts[0]})
    for _ in range(10):
        a, b, c, d, n = rand(5)
        assert lib.projectiveAdd(*parse(a % n), *parse(b % n), *parse(c % n), *parse(d % n), *parse(n)) == projectiveAdd(a, b, c, d, n)





def test_projectiveScalarMul():
    uint512 = Uint512.deploy({'from': accounts[0]})
    mont = Montgomery.deploy({'from': accounts[0]})
    lib = PointOperations.deploy({'from': accounts[0]})
    for _ in range(10):
        a, b, n = rand(3)
        assert lib.projectiveScalarMul(*parse(a % n), *parse(b % n), *parse(n)) == projectiveScalarMul(a, b, n)

    n = 0x4531acd1fe0023c7550d267b6b2fee80922b14b2ffb90f04d4eb7c09b5d2d15da82f2d7ecb1dbac719905c5eecc423f1d86e25edbe23c595d644aaf187e6e6df
    a = 0xb6a1584a3d7164bbd40d6a967bb72563761c11402abdeea1d8ecb7602597e122e3289712a8baaf690a148b607d74e20c94e0737c407da8177f8257d353431286
    b = 0x6abbee6b346429e597ff9b05d11cc1800a296dd711de3ea8c49b31616e2f70e06d8ce9521bd3ab1becfea568dcc7e2205175aa4f2faea0272220573f3fa0f4a8

    r = lib.projectiveScalarMul(*parse(a % n), *parse(b % n), *parse(n)) == projectiveScalarMul(a, b, n)
