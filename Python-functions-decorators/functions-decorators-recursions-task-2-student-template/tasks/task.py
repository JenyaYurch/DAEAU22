from typing import Any, List

def linear_seq(sequence: List[Any]) -> List[Any]:
    sum = []
    for i in sequence:
        if type(i) == int:
            sum.append(i)
        elif type(i) in [list, tuple]:
            sum += linear_seq(i)
    return sum
    pass
