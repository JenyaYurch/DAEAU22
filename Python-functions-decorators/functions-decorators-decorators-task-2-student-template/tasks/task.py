import time
import inspect
def log(fn):
    params = inspect.signature(fn).parameters.keys()
    logmsg = fn.__name__ + "; args: {}; kwargs: {}; execution time: {} sec.\n"
    def wrapper(*args, **kwargs):
        start_time = time.perf_counter()
        fn(*args, **kwargs)
        extime = time.perf_counter() - start_time
        with open("log.txt", "a+") as file:
            args = ", ".join(f"{name}={value}" for name, value in zip(params, args))
            kwargs = ", ".join(f"{name}={value}" for name, value in kwargs.items())
            file.write(logmsg.format(args, kwargs, extime))

        #f = open("log.txt", "r")
        #print(f.read())
    return wrapper


