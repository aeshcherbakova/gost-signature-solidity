from helpful_scripts import parse_hex


def extended_euclidean(a, b):
    previous_x, x = 1, 0
    previous_y, y = 0, 1
    while b:
        q = a//b
        x, previous_x = previous_x - q*x, x
        y, previous_y = previous_y - q*y, y
        a, b = b, a % b
    return a, previous_x, previous_y



curves = {
    'gost256': 0x8000000000000000000000000000000150fe8a1892976154c59cfc193accf5b3,
    'gost512': 0x4531acd1fe0023c7550d267b6b2fee80922b14b2ffb90f04d4eb7c09b5d2d15da82f2d7ecb1dbac719905c5eecc423f1d86e25edbe23c595d644aaf187e6e6df,
    'id-tc26-gost-3410-12-512-paramSet': 0x00FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF27E69532F48D89116FF22B8D4E0560609B4B38ABFAD2B85DCACDB1411F10B275,
    'id-tc26-gost-3410-12-512-paramSetB': 0x00800000000000000000000000000000000000000000000000000000000000000149A1EC142565A545ACFDB77BD9D40CFA8B996712101BEA0EC6346C54374F25BD,
    'id-tc26-gost-3410-2012-256-paramSetA': 0x400000000000000000000000000000000fd8cddfc87b6635c115af556c360c67,
    'id-tc26-gost-3410-2012-512-paramSetC': 0x3fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffc98cdba46506ab004c33a9ff5147502cc8eda9e7a769a12694623cef47f023ed,
    'id-GostR3410-2001-CryptoPro-A-ParamSet': 0xffffffffffffffffffffffffffffffff6c611070995ad10045841b09b761b893,
    'id-GostR3410-2001-CryptoPro-B-ParamSet': 0x800000000000000000000000000000015f700cfff1a624e5e497161bcc8a198f,
    'id-GostR3410-2001-CryptoPro-C-ParamSet': 0x9b9f605f5a858107ab1ec85e6b41c8aa582ca3511eddfb74f02f3a6598980bb9
}


for name, N in curves.items():
    print('uint256[5] {} = ['.format(name))
    # print('N0 = {}\nN1 = {}'.format(*parse_hex(N)))    
    if N < 2**256:
        R = 2**256
        print('    256,')
    else:
        R = 2**512
        print('    512,')
    # print('// R^2 mod n')
    a, Rp, Np = extended_euclidean(R, N)         # R*Rp + N*Np == 1
    Rp1 = Rp + N; Np1 = -1 * (Np - R)            # Rp1 and Np1 are positive
    
    # print(a == 1, 0 < Rp1 < N, 0 < Np1 < R, R*Rp1 - N*Np1 == 1)
    # print(f'Rp1 = {hex(Rp1)}\nNp1 = {hex(Np1)}')
    # print(N*Np1 == R*Rp1 - 1, N*Np1 % R == R-1)  # N*Np1 = -1 mod R

    print('    {},\n    {},'.format(*parse_hex(R**2 % N)))
    print('    {},\n    {}'.format(*parse_hex(Np1)))
    print('];')


for name, N in curves.items():
    print('curves[abi.encode(')
    print('    {},\n    {}'.format(*parse_hex(N)))
    print(')] = Curve({}, true);'.format(name))









