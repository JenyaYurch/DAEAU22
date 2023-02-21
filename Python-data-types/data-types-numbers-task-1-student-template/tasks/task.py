def get_fractions(a_b: str, c_b: str) -> str:
    c1 = a_b.split('/')[0]
    c2 = c_b.split('/')[0]
    d = a_b.split('/')[1]

    return f'{a_b} + {c_b} = {int(c1) + int(c2)}/{d}'

if __name__ == '__main__':
    a_b = '1/3'
    c_b = '5/3'
    assert (get_fractions(a_b, c_b) == '1/3 + 5/3 = 6/3')