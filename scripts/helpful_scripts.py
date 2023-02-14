import random

CONST_256 = 2 ** 256
CONST_512 = 2 ** 512


# get n random 512-bit values
def rand(n):
    return [random.getrandbits(512) for _ in range(n)]

# returns 512-bit uint divided in two 256-bit parts: r0 (right=lower), r1 (left=higher bytes)
def parse(x):
    x_mod = x % CONST_512
    return (x_mod % CONST_256, x_mod // CONST_256)

# same but result in hex
def parse_hex(x):
    x_mod = x % CONST_512
    return (hex(x_mod % CONST_256), hex(x_mod // CONST_256))


# returns 512-bit sum a + b 
def add512x512(a, b):
    return parse((a + b) % CONST_512) 


# returns 512-bit subtraction a + b 
def sub512x512(a, b):
    return parse((a - b) % CONST_512) 


# returns 512-bit sum a + b mod n
def add512x512mod(a, b, n):
    return parse((a + b) % n)


# returns 512-bit subtraction a - b mod n
def sub512x512mod(a, b, n):
    return parse((a - b) % n)


# returns 512-bit mul (a * b) mod n
def mul512x512mod(a, b, n):
    return parse((a * b) % n)


# returns 512-bit mul (a * b) resulting 1024
def mul512x512res1024(a, b):
    return (*parse((a * b) % CONST_512), *parse((a*b) // CONST_512))









# returns randomly generated 512-bit uint divided in two 256-bit parts: r0 (right=lower), r1 (left=higher bytes)
# def generate_512_value():
#     return parse(random.getrandbits(512))