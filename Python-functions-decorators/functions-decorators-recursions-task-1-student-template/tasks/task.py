from typing import List, Tuple, Union


def seq_sum(sequence: Union[List, Tuple]) -> int:
    sum = 0
    for i in sequence:
        if type(i) == int:
            sum += i
        elif type(i) in [list, tuple]:
            sum += seq_sum(i)
    return sum
    pass