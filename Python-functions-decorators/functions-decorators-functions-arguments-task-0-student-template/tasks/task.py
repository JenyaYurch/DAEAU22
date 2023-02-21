from typing import Dict

def generate_squares(num: int)-> Dict[int, int]:
    tmp={}
    a = [i for i in range(1,num+1)]
    #return tuple(tmp)
    for i in range(len(a)):
        tmp[a[i]]=(i+1)**2
    return tmp
