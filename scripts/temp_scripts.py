import helpful_scripts as s
from openssl import crypto


crypto.get_elliptic_curves()

# n = 0x4531acd1fe0023c7550d267b6b2fee80922b14b2ffb90f04d4eb7c09b5d2d15da82f2d7ecb1dbac719905c5eecc423f1d86e25edbe23c595d644aaf187e6e6df
# a, b = s.rand(2)
# print(hex(a))
# print(hex(b))
# print(hex(a*b % n))


n = 0x4531acd1fe0023c7550d267b6b2fee80922b14b2ffb90f04d4eb7c09b5d2d15da82f2d7ecb1dbac719905c5eecc423f1d86e25edbe23c595d644aaf187e6e6df
a = 0xb6a1584a3d7164bbd40d6a967bb72563761c11402abdeea1d8ecb7602597e122e3289712a8baaf690a148b607d74e20c94e0737c407da8177f8257d353431286
b = 0x6abbee6b346429e597ff9b05d11cc1800a296dd711de3ea8c49b31616e2f70e06d8ce9521bd3ab1becfea568dcc7e2205175aa4f2faea0272220573f3fa0f4a8
res = 0x1e2febbdba28b3d33594ed724ef98a7ba28962fdfc69da7cdba92fb12805dbeb9fcae126b4992432eed8cdd0a2c4f71f29cb180f215bcb58c1d35d91749b4923
