from typing import Any, Dict, List, Set

def check(lst: List[Dict[Any, Any]]) -> Set[Any]:
    che = set(
        value for i in lst
        for value in i.values()
    )
    return che
    pass
