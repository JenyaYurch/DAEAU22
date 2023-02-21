from typing import List, Dict

def combine_dicts(*args:List[Dict[str, int]]) -> Dict[str, int]:
    pass
    dict_total = {}
    for x in args:
        for key, value in x.items():
            if key in dict_total:
                dict_total[key] = x.get(key) + dict_total.get(key)
            else:
                dict_total[key] = value

    return dict_total
