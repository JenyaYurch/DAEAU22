class FiniteRepeat:
    def __init__(self, msg, max_count):
        self.msg = msg
        self.max_count = max_count
        self.count = 0

    def __iter__(self):
        return self

    def __next__(self):
        if self.count >= self.max_count:
            raise StopIteration
        self.count += 1
        return self.msg

a=FiniteRepeat()