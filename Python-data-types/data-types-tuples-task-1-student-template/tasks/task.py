from typing import Tuple

def get_tuple(num: int) -> Tuple[int]:
    # TODO: Add your code here
    lis = [int(char) for char in str(num)]
    return tuple(lis)

print(get_tuple('5'))
