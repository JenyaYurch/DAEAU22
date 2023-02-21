from typing import Any, Tuple, List

def get_pairs(lst: List[Any]) -> List[Tuple[Any, Any]]:
    # TODO: Add your code here
    res = []
    if len(lst) < 2:
        return []
    for ix in range(len(lst)):
        if ix > len(lst) - 2:
            return res
        t = (lst[ix], lst[ix + 1])
        res.append(t)
    return res