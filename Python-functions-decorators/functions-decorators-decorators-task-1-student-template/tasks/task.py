from typing import Dict
import time

execution_time: Dict[str, float] = {}

def time_decorator(fn):
    """
    Create a decorator function `time_decorator`
    which has to calculate decorated function execution time
    and put this time value to `execution_time` dictionary where `key` is
    decorated function name and `value` is this function execution time.
    """
    def wrapper(*args, **kwargs):
        now = time.time()
        ret = fn(*args, **kwargs)
        difftime = time.time() - now
        global execution_time
        execution_time[fn.__name__] = difftime
        return ret
    return wrapper
@time_decorator
def func_add(a, b):
    time.sleep(0.2)
    return a + b

print(func_add(10, 20))

