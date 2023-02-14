import pytest
from brownie import accounts, Uint512, Montgomery, PointOperations, Hash512

def test_examples():
    # from GOST control example #1
    p = 0x8000000000000000000000000000000000000000000000000000000000000431
    b = 0x5FBFF498AA938CE739B8E022FBAFEF40563F6E6A3472FC2A514C0CE9DAE23B7E
    a = 0x7
    m = 0x8000000000000000000000000000000150FE8A1892976154C59CFC193ACCF5B3
    q = m
    xp = 0x2
    yp = 0x8E2A8A0E65147D4BD6316030E16D19C85C97F0A9CA267122B96ABBCEA7E8FC8
    d = 0x7A929ADE789BB9BE10ED359DD39A72C11B60961F49397EEE1D19CE9891EC3B28
    xq = 0x7F2B49E270DB6D90D8595BEC458B50C58585BA1D4E9B788F6689DBD8E56FD80B
    yq = 0x26F1B489D6701DD185C8413A977B3CBBAF64D1C593D26627DFFB101A87FF77DA
    r = 0x41AA28D2F1AB148280CD9ED56FEDA41974053554A42767B83AD043FD39DC0493
    s = 0x1456С64ВА4642А1653C235A98A60249BCD6D3F746B631DF928014F6C5BF9C40
    R = 0x41AA28D2F1AB148280CD9ED56FEDA41974053554A42767B83AD043FD39DC0493
    # result: true

    assert sign([*parse(p), *parse(a), *parse(b), *parse(m), *parse(xp), *parse(yp), *parse(xq), *parse(yq)], d) == True


    # from GOST control example #2
    p = 0x4531ACD1FE0023C7550D267B6B2FEE80922B14B2FFB90F04D4EB7C09B5D2D15DF1D852741AF4704A0458047E80E4546D35B8336FAC224DD81664BBF528BE6373
    b = 0x1CFF0806A31116DA29D8CFA54E57EB748BC5F377E49400FDD788B649ECA1AC4361834013B2AD7322480A89CA58E0CF74BC9E540C2ADD6897FAD0A3084F302ADC
    a = 0x7
    m = 0x4531ACD1FE0023C7550D267B6B2FEE80922B14B2FFB90F04D4EB7C09B5D2D15DA82F2D7ECB1DBAC719905C5EECC423F1D86E25EDBE23C595D644AAF187E6E6DF
    q = m
    xp = 0x24D19CC64572EE30F396BF6EBBFD7A6C5213B3B3D7057CC825F91093A68CD762FD60611262CD838DC6B60AA7EEE804E28BC849977FAC33B4B530F1B120248A9A
    yp = 0x2BB312A43BD2CE6E0D020613C857ACDDCFBF061E91E5F2C3F32447C259F39B2С83АВ156D77F1496BF7EB3351Е1EE4E43DC1A18В91B24640B6DBB92CB1ADD371Е
    d = 0xBA6048AADAE241BA40936D47756D7C93091A0E8514669700EE7508E508B102072E8123B2200A0563322DAD2827E2714A2636B7BFD18AADFC62967821FA18DD4
    xq = 0x115DC5BC96760C7B48598D8AB9E740D4C4A85A65BE33C1815В5С320С854621DD5A515856D13314AF69BC5B924C8B4DDFF75C45415C1D9DD9DD33612CD530EFE1
    yq = 0x37C7C90CD40B0F5621DC3AC1В751CFA0E2634FA0503B3D52639F5D7FB72AFD61ЕА199441D943FFE7F0C70A2759A3CDB84C114Е1F9339FDF27F35ECA93677BEEC
    r = 0x2F86FA60A081091A23DD795E1E3C689EE512A3C82EE0DCC2643C78EEA8FCACD35492558486B20F1С9ЕС197C90699850260C93BCBCD9C5C3317Е19344Е173АЕ36
    s = 0x1081B394696FFE8E6585E7A9362D26B6325F56778AADBC081C0BFBE933D52FF5823CE288E8C4F362526080DF7F70CE406A6EEB1F56919CB92A9853BDE73E5B4A
    R = 0x2F86FA60A081091A23DD795E1E3C689EE512A3C82EE0DCC2643C78EEA8FCACD35492558486B20F1C9EC197C90699850260C93BCBCD9C5C3317E19344E173AE36
    # result: true

    assert sign([*parse(p), *parse(a), *parse(b), *parse(m), *parse(xp), *parse(yp), *parse(xq), *parse(yq)], d) == True








# промежуточные итерации - дебажить в brownie console!!!
# остальное - в файлике openssl.py

