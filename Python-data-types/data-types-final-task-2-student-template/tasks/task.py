from typing import List

def check(row_start:int, row_end:int, column_start:int, column_end:int) -> List[List[int]]:
    result=[]
    tmp=[]
    last=0
    if row_start>row_end or column_start>column_end:
        return
    a=[i for i in range(row_start, row_end+1)]
    b=[l for l in range(column_start, column_end+1)]
    for x in range(abs(len(a))):
        for y in range(abs(len(b))):
            tmp.append(a[x]*b[y])
    while len(result) < abs(len(a)):
        result.append(tmp[int(last):int(abs(len(b))+last)])
        last+=abs(len(b))
    return result

print(check(2,4,3,6))
