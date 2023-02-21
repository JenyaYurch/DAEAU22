from typing import List


def foo(nums: List[int]) -> List[int]:
    # TODO: Add your code here
    res = []
    if len(nums) < 2:
        return []
    for ix in range(len(nums)):
        if ix > len(nums) - 2:
            return res
        t = (nums[ix], nums[ix + 1])
        res.append(t)
    return res
