
def decorator_apply(lambda_func):
    def wrapper(f):
        def wrapped(x):
            return f(lambda_func(x))
        return wrapped
    return wrapper


@decorator_apply(lambda user_id: user_id + 1)
def return_user_id(num: int) ->int:
    return num