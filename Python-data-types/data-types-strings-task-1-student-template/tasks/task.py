def get_fractions(a_b: str, c_b: str) -> str:
    result = None
    result = str(int(a_b.split('/')[0])+int(c_b.split('/')[0]))+'/'+a_b.split('/')[1]

    print(result)
    return result
if __name__ == "__main__":
    get_fractions("23/65","11/65")
