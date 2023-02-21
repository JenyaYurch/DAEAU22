def check_str(s: str):
    disallowed_characters = " .,_—?!"
    for character in disallowed_characters:
        s = s.lower().replace(character, "")
    return s == s[::-1]

print(check_str('12321'))


def check_str(s: str):
    disallowed_characters = " .,_—?!"
    for character in disallowed_characters:
        s = s.lower().replace(character, "")
    return s == s[::-1]

print(check_str('12321'))

