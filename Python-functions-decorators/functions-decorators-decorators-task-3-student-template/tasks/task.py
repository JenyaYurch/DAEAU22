from itertools import chain
from _ctypes_test import func

def validate(func):
    def wrapper(*args, **kwargs):
        if all(arg >= 0 and arg <=256 for arg in chain(args, kwargs.values())if isinstance(arg, int)):
            return func(*args, **kwargs)
        return "Function call is not valid!"

    return wrapper

@validate
def set_pixel(x: int, y: int, z: int) -> str:
  return "Pixel created!"

#print(set_pixel(2,2,2))
