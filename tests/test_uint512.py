import pytest
from brownie import accounts, Uint512
import random
from scripts.helpful_scripts import *

CONST_a = 0xbef38558980cc4c4be07c6416b854f6eede590a86520c659f8a23d543c0d6fb7022279e7e3295ce6bc4f4cca50951ef42d6d6472c9a89d8e03989ec052bd8440
CONST_b = 0x59bd0fb9a19bf11a8c6b50df95ed0bae5ce6560591d25f6b09087b0aaf149ef17e56e04d3aae0c056c70690ca838a82fe1945a4df59baf657b4e36ca2e2105b8
CONST_n = 0xd38558980cc4c4be07c6416b854f6eede590a86520c659f8a23d543c0d6fb7ef7e56e04d3aae0c056c70690ca838a82fe1945a4df59baf657b4e36ca2e2105b8
CONST_c = 0x1491d33f74b7fff949be7b2a19ca1f7ef7ab17bcbba5939ea99b16e7d16248387c3466655784af1eb0211c4257a3893bb426f5db2bf311d777b59809db7657ff

CONST_p = 0x8000000000000000000000000000000000000000000000000000000000000431
CONST_d = 0x7A929ADE789BB9BE10ED359DD39A72C11B60961F49397EEE1D19CE9891EC3B28
CONST_m = 0x8000000000000000000000000000000150FE8A1892976154C59CFC193ACCF5B3
CONST_q = 0x8000000000000000000000000000000150FE8A1892976154C59CFC193ACCF5B3

CONST_hash = 0x134B3858B9B6A4982F828F6077750960F1269F859D994110B7FC979C4F8D330CEFFC9F0581D509D9612E0781FFE2F6BB4817EB1D9B856670DD0620CE21547158


random.seed()

def test_all_for_gas():
    lib = Uint512.deploy({'from': accounts[0]})
    a = parse(CONST_a)
    b = parse(CONST_b)
    d = CONST_d
    n = parse(CONST_n)

    lib.lt512x512(*a, *b)
    lib.gt512x512(*a, *b)
    lib.eq512x512(*a, *b)
    lib.isZero512(*a)
    lib.add512x512(*a, *b)
    lib.sub512x512(*a, *b)
    lib.add512x512mod(*a, *b, *n)
    lib.sub512x512mod(*a, *b, *n)
    lib.mulMod256x256(*a, d)
    lib.mul512x256(*a, d)
    lib.mul256x256(*a)
    lib.mul512x256(*a, d)
    lib.mulMod256x256(*a, d)
    lib.lshift512(*a, d)
    lib.rshift512(*a, d)
    lib.mod256(*a, d)
    lib.mod512(*a, *n)
    lib.divmod512(*a, *n)
    lib.div512x256(*a, d)
    lib.mulmod512x512(*a, *b, *n)
    lib.mul512x512res1024(*a, *b)
    lib.mod512from1024([*a, *b], *n)



def test_add512x512():
    lib = Uint512.deploy({'from': accounts[0]})
    for _ in range(10):
        a, b = rand(2)
        assert lib.add512x512(*parse(a), *parse(b)) == add512x512(a, b)
    # test with guaranteed overflow
    a, b = CONST_a, CONST_b
    assert lib.add512x512(*parse(a), *parse(b)) == add512x512(a, b)
    a, b = 0, 2**256-1
    assert lib.add512x512(*parse(a), *parse(b)) == add512x512(a, b)

        

def test_add512x512mod():
    lib = Uint512.deploy({'from': accounts[0]})
    for _ in range(10):
        a, b, n = rand(3)
        assert lib.add512x512mod(*parse(a % n), *parse(b % n), *parse(n)) == add512x512mod(a, b, n)
    # tests with guaranteed overflow 512-bit and without
    a, b, c, n = CONST_a, CONST_b, CONST_c, CONST_n
    assert lib.add512x512mod(*parse(a % n), *parse(b % n), *parse(n)) == add512x512mod(a, b, n)
    assert lib.add512x512mod(*parse(a % n), *parse(c % n), *parse(n)) == add512x512mod(a, c, n)
    a, b = 0, 2**256-1
    assert lib.add512x512mod(*parse(a % n), *parse(c % n), *parse(n)) == add512x512mod(a, c, n)




def test_sub512x512mod():
    lib = Uint512.deploy({'from': accounts[0]})
    for _ in range(10):
        a, b, n = rand(3)
        assert lib.add512x512mod(*parse(a % n), *parse(b % n), *parse(n)) == add512x512mod(a, b, n)
    # tests with guaranteed overflow 512-bit and without
    a, b, c, n = CONST_a, CONST_b, CONST_c, CONST_n
    assert lib.sub512x512mod(*parse(a % n), *parse(b % n), *parse(n)) == sub512x512mod(a, b, n)
    assert lib.sub512x512mod(*parse(a % n), *parse(c % n), *parse(n)) == sub512x512mod(a, c, n)
    a, b = 0, 2**256-1



def test_compa():
    lib = Uint512.deploy({'from': accounts[0]})
    assert 5 == lib.compa([70, 70], [70, 70])


def test_mul512x512res1024():
    lib = Uint512.deploy({'from': accounts[0]})
    for _ in range(10):
        a, b = rand(2)
        assert lib.mul512x512res1024(*parse(a), *parse(b)) == mul512x512res1024(a, b)
    a, b, c = 0, 2**256-1, CONST_c
    assert lib.mul512x512res1024(*parse(a), *parse(b)) == mul512x512res1024(a, b)
    assert lib.mul512x512res1024(*parse(c), *parse(b)) == mul512x512res1024(c, b)
    assert lib.mul512x512res1024(*parse(a), *parse(c)) == mul512x512res1024(a, c)



def test_rshift512():
    lib = Uint512.deploy({'from': accounts[0]})
    for _ in range(10):
        a, n = rand(2)
        n = n % 256
        assert lib.rshift512(*parse(a), n) == parse(a >> n) 
    # divide by two
    a = CONST_a
    n = 1
    assert lib.rshift512(*parse(a), n) == parse(a // 2) 
    a, b = 0, 2**256-1
    assert lib.rshift512(*parse(n), a) == parse(n // 2**a) 

    
def test_lshift512():
    lib = Uint512.deploy({'from': accounts[0]})
    for _ in range(10):
        a, n = rand(2)
        n = n % 256
        assert lib.lshift512(*parse(a), n) == parse(a >> n) 
    # divide by two
    a = CONST_a
    n = 1
    assert lib.lshift512(*parse(a), n) == parse(a * 2) 
    a, b = 0, 2**256-1
    assert lib.lshift512(*parse(n), a) == parse(n * 2**a) 



def test_mod256():
    lib = Uint512.deploy({'from': accounts[0]})
    for _ in range(10):
        a, n = rand(2)
        n = n % (2 ** 256)
        assert lib.mod256(*parse(a), n) == a % n
    # test for check curve
    some_hash = 0x134B3858B9B6A4982F828F6077750960F1269F859D994110B7FC979C4F8D330CEFFC9F0581D509D9612E0781FFE2F6BB4817EB1D9B856670DD0620CE21547158
    assert lib.mod256(*parse(some_hash), CONST_q) == some_hash % CONST_q
    a, b = 0, 2**256-1
    assert lib.mod256(*parse(some_hash), b) == some_hash % b




def test_mod512():
    lib = Uint512.deploy({'from': accounts[0]})
    tx = lib.mod512(*parse(CONST_a), *parse(CONST_b))
    for _ in range(1):
        a, n = rand(2)
        res = lib.mod512(*parse(a), *parse(n))
        assert res == parse(a % n)
    # test for check curve
    some_hash = 0x134B3858B9B6A4982F828F6077750960F1269F859D994110B7FC979C4F8D330CEFFC9F0581D509D9612E0781FFE2F6BB4817EB1D9B856670DD0620CE21547158
    assert lib.mod256(*parse(some_hash), CONST_q) == some_hash % CONST_q
    a, b = 0, 2**256-1
    assert lib.mod256(*parse(some_hash), b) == some_hash % b




def test_divmod512():
    lib = Uint512.deploy({'from': accounts[0]})
    for _ in range(10):
        a, n = rand(2)
        assert lib.divmod512(*parse(a), *parse(n)) == (*parse(a // n), *parse(a % n))
    # test for check curve
    some_hash = 0x134B3858B9B6A4982F828F6077750960F1269F859D994110B7FC979C4F8D330CEFFC9F0581D509D9612E0781FFE2F6BB4817EB1D9B856670DD0620CE21547158
    assert lib.mod256(*parse(some_hash), CONST_q) == some_hash % CONST_q
    a, b = 0, 2**256-1
    assert lib.mod256(*parse(some_hash), b) == some_hash % b


# solidity abi.encode() analog
# x, y - 256-bit 
# returns 32-bit hex with zeros without 0x prefix
def abi_encode(lo, hi):
    return "0x{0:0{1}x}".format(hi, 64) + "{0:0{1}x}".format(lo, 64)


def test_uint512_to_bytes():
    lib = Uint512.deploy({'from': accounts[0]})
    for _ in range(10):
        x_512 = rand(1)[0]
        assert lib.uint512_to_bytes(*parse(x_512)) == abi_encode(*parse(x_512))





def test_add512x512():
    lib = Uint512.deploy({'from': accounts[0]})
    for _ in range(10):
        a, b = rand(2)
        assert lib.add512x512(*parse(a), *parse(b)) == add512x512(a, b)
    # test with guaranteed overflow
    a, b = CONST_a, CONST_b
    assert lib.add512x512(*parse(a), *parse(b)) == add512x512(a, b)
    a, b = 0, 2**256-1
    assert lib.add512x512(*parse(a), *parse(b)) == add512x512(a, b)

        

def test_add512x512mod():
    lib = Uint512.deploy({'from': accounts[0]})
    for _ in range(10):
        a, b, n = rand(3)
        assert lib.add512x512mod(*parse(a % n), *parse(b % n), *parse(n)) == add512x512mod(a, b, n)
    # tests with guaranteed overflow 512-bit and without
    a, b, c, n = CONST_a, CONST_b, CONST_c, CONST_n
    assert lib.add512x512mod(*parse(a % n), *parse(b % n), *parse(n)) == add512x512mod(a, b, n)
    assert lib.add512x512mod(*parse(a % n), *parse(c % n), *parse(n)) == add512x512mod(a, c, n)
    a, b = 0, 2**256-1





def test_lt512x512():
    lib = Uint512.deploy({'from': accounts[0]})
    for _ in range(10):
        a, b = rand(2)
        assert lib.lt512x512(*parse(a), *parse(b)) == lt512x512(a, b)
    # test with guaranteed overflow
    a, b = CONST_a, CONST_b
    assert lib.lt512x512(*parse(a), *parse(b)) == lt512x512(a, b)
    a, b = 0, 2**256-1
    assert lib.lt512x512(*parse(a), *parse(b)) == lt512x512(a, b)

        

def test_gt512x512mod():
    lib = Uint512.deploy({'from': accounts[0]})
    for _ in range(10):
        a, b, n = rand(3)
        assert lib.gt512x512mod(*parse(a % n), *parse(b % n), *parse(n)) == gt512x512mod(a, b, n)
    # tests with guaranteed overflow 512-bit and without
    a, b, c, n = CONST_a, CONST_b, CONST_c, CONST_n
    assert lib.gt512x512mod(*parse(a % n), *parse(b % n), *parse(n)) == gt512x512mod(a, b, n)
    assert lib.gt512x512mod(*parse(a % n), *parse(c % n), *parse(n)) == gt512x512mod(a, c, n)
    a, b = 0, 2**256-1
    assert lib.gt512x512(*parse(a), *parse(b)) == gt512x512(a, b)

    
def test_eq512x512mod():
    lib = Uint512.deploy({'from': accounts[0]})
    for _ in range(10):
        a, b, n = rand(3)
        assert lib.eq512x512mod(*parse(a % n), *parse(b % n), *parse(n)) == eq512x512mod(a, b, n)
    # tests with guaranteed overflow 512-bit and without
    a, b, c, n = CONST_a, CONST_b, CONST_c, CONST_n
    assert lib.eq512x512mod(*parse(a % n), *parse(b % n), *parse(n)) == eq512x512mod(a, b, n)
    assert lib.eq512x512mod(*parse(a % n), *parse(c % n), *parse(n)) == eq512x512mod(a, c, n)
    a, b = 0, 2**256-1
    