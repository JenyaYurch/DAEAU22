def union(*args) -> set:
    res = set()
    for i in args:
        res.update(i)
    return res
    raise NotImplementedError("Implement me!")


def intersect(*args) -> set:
    res = set(args[0])
    for i in args:
        res.intersection_update(i)
    return res
    raise NotImplementedError("Implement me!")

