from typing import Dict


def get_dict(s: str) -> Dict[str, int]:
    # TODO: Add your code here
    tmp={}
    for i in range(len(s)):
        if s[i].lower() in tmp:
           tmp[s[i].lower()]+=1
        else:
            tmp[s[i].lower()]= 1
    return tmp
