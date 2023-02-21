from typing import List, Tuple

def sort_unique_elements(str_list: Tuple[str]) -> List[str]:
    # TODO: Add your code here
    result = []
    for i in str_list:
        if i not in result:
            result.append(i)
            result.sort()
    return result

