import pytest
from brownie import accounts, Montgomery, Uint512
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
    lib = Montgomery.deploy({'from': accounts[0]})
    a = parse(CONST_a)
    b = parse(CONST_b)
    n = parse(CONST_n)
    # lib.set_curves()
    curve = lib.find_curve(*n)
    lib.mont_mulmod(*a, *b, [*n, 0xe23c04dc39c8c930929e0924887fab48561500cb39a9b66bb03174e56db6ba90, 
    0x3057350e3201bb3680bc9d923a08f9a9d70dfcccc3dd062f0cc44723bcc36979, 
    0x3d86f5322949b920af0456575d456e174c82666f7bb16c1e50bc7d084a21aae1])



def test_montgomery():
    uint512 = Uint512.deploy({'from': accounts[0]})
    lib = Montgomery.deploy({'from': accounts[0]})
    # lib.set_curves()
    lib.set_curves()
    n = 0x4531acd1fe0023c7550d267b6b2fee80922b14b2ffb90f04d4eb7c09b5d2d15da82f2d7ecb1dbac719905c5eecc423f1d86e25edbe23c595d644aaf187e6e6df
    a = 0xb6a1584a3d7164bbd40d6a967bb72563761c11402abdeea1d8ecb7602597e122e3289712a8baaf690a148b607d74e20c94e0737c407da8177f8257d353431286
    b = 0x6abbee6b346429e597ff9b05d11cc1800a296dd711de3ea8c49b31616e2f70e06d8ce9521bd3ab1becfea568dcc7e2205175aa4f2faea0272220573f3fa0f4a8
    res = 0x1e2febbdba28b3d33594ed724ef98a7ba28962fdfc69da7cdba92fb12805dbeb9fcae126b4992432eed8cdd0a2c4f71f29cb180f215bcb58c1d35d91749b4923

    r = lib.mont_mulmod(*parse(a), *parse(b), *parse(n))
    print(r)
    assert res == r

    r = lib.mont_mulmod(*parse(CONST_a), *parse(CONST_b), *parse(CONST_n))
    print(r)
    assert r == CONST_a * CONST_b % CONST_n

    for _ in range(10):
        a, b, c = rand(3)
        assert lib.montgomeryMulMod(*parse(a), *parse(b), *parse(n)) == a * b % n 
        r = lib.mont_mulmod(*parse(a), *parse(c), *parse(n))
        assert r == a * c % n



def test_to_mont():
    uint512 = Uint512.deploy({'from': accounts[0]})
    lib = Montgomery.deploy({'from': accounts[0]})
    # lib.set_curves()
    lib.set_curves()
    n = 0x4531acd1fe0023c7550d267b6b2fee80922b14b2ffb90f04d4eb7c09b5d2d15da82f2d7ecb1dbac719905c5eecc423f1d86e25edbe23c595d644aaf187e6e6df
    a = 0xb6a1584a3d7164bbd40d6a967bb72563761c11402abdeea1d8ecb7602597e122e3289712a8baaf690a148b607d74e20c94e0737c407da8177f8257d353431286
    b = 0x6abbee6b346429e597ff9b05d11cc1800a296dd711de3ea8c49b31616e2f70e06d8ce9521bd3ab1becfea568dcc7e2205175aa4f2faea0272220573f3fa0f4a8
    res1 = 0x1491d33f74b7fff949be7b2a19ca1f7ef7ab17bcbba5939ea99b16e7d16248387c3466655784af1eb0211c4257a3893bb426f5db2bf311d777b59809db7657ff
    res2 = 0x3057350e3201bb3680bc9d923a08f9a9d70dfcccc3dd062f0cc44723bcc36979

    r1 = lib.to_mont(*parse(a), *parse(n))
    r2 = lib.to_mont(*parse(a), *parse(n))
    assert res1 == r1
    assert res2 == r2

    for _ in range(10):
        a, b, c = rand(3)
        assert lib.to_mont(*parse(a), *parse(n)) == to_mont(a, n)
        assert lib.to_mont(*parse(b), *parse(CONST_n)) == to_mont(b, CONST_n)
        assert lib.to_mont(*parse(b), *parse(n)) == to_mont(b, n)
        assert lib.to_mont(*parse(a), *parse(CONST_n)) == to_mont(a, CONST_n)






def test_to_norm():
    uint512 = Uint512.deploy({'from': accounts[0]})
    lib = Montgomery.deploy({'from': accounts[0]})
    # lib.set_curves()
    lib.set_curves()
    n = 0x4531acd1fe0023c7550d267b6b2fee80922b14b2ffb90f04d4eb7c09b5d2d15da82f2d7ecb1dbac719905c5eecc423f1d86e25edbe23c595d644aaf187e6e6df
    a = 0xb6a1584a3d7164bbd40d6a967bb72563761c11402abdeea1d8ecb7602597e122e3289712a8baaf690a148b607d74e20c94e0737c407da8177f8257d353431286
    b = 0x6abbee6b346429e597ff9b05d11cc1800a296dd711de3ea8c49b31616e2f70e06d8ce9521bd3ab1becfea568dcc7e2205175aa4f2faea0272220573f3fa0f4a8
    res1 = 0x1491d33f74b7fff949be7b2a19ca1f7ef7ab17bcbba5939ea99b16e7d16248387c3466655784af1eb0211c4257a3893bb426f5db2bf311d777b59809db7657ff
    res2 = 0x3057350e3201bb3680bc9d923a08f9a9d70dfcccc3dd062f0cc44723bcc36979

    r1 = lib.to_norm(*parse(a), *parse(n))
    r2 = lib.to_norm(*parse(a), *parse(n))
    assert res1 == r1
    assert res2 == r2

    for _ in range(10):
        a, b, c = rand(3)
        assert lib.to_mont(*parse(a), *parse(n)) == to_norm(a, n)
        assert lib.to_mont(*parse(b), *parse(CONST_n)) == to_norm(b, CONST_n)
        assert lib.to_mont(*parse(b), *parse(n)) == to_norm(b, n)
        assert lib.to_mont(*parse(a), *parse(CONST_n)) == to_norm(a, CONST_n)






    



