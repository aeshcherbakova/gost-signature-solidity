import pytest
from brownie import accounts, Hash512
import random
from scripts.helpful_scripts import *


def test_all_for_gas():
    lib = Hash512.deploy({'from': accounts[0]})
    lib.hashKeccak256()
    lib.hashGost_optimized()
    lib.hashGost_not_optimized()


# промежуточные итерации - дебажить в brownie console!!!
# тестовые файлики - чекать через openssl engine: https://github.com/gost-engine/engine
# ./openssl  dgst -md_gost12_256 text_for_hashing.bin
# ./openssl  dgst -md_gost12_512 text_for_hashing.bin


# from GOST control example #1 - 512 bit
mes1 = "323130393837363534333231303938373635343332313039383736353433323130393837363534333231303938373635343332313039383736353433323130"
res1 = "486f64c1917879417fef082b3381a4e211c324f074654c38823a7b76f830ad00fa1fbae42b1285c0352f227524bc9ab16254288dd6863dccd5b9f54a1ad0541b"

# example #2 - 256 bit
mes2 = "01323130393837363534333231303938373635343332313039383736353433323130393837363534333231303938373635343332313039383736353433323130"
res2 = "01323130393837363534333231303938373635343332313039383736353433323130393837363534333231303938373635343332313039383736353433323130"

# example #3 - 256 bit
mes3 = "fbeafaebef20fffbf0e1e0f0f520e0ed20e8ece0ebe5f0f2f120fff0eeec20f120faf2fee5e2202ce8f6f3ede220e8e6eee1e8f0f2d1202ce8f0f2e5e220e5d1"
res3 = "508f7e553c06501d749a66fc28c6cac0b005746d97537fa85d9e40904efed29d"

def test_examples():
    assert mes1 == res1
    assert mes2 == res2
    assert mes3 == res3



