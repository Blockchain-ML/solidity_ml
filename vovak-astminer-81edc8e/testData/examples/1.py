x = 1
y = 2
z = 3
if x == 1:
    print(x, y, z)
    print("ololo")
if y==2:
    print("Manish")
    print("Kumar")
    print("Tiwari")
if z==3:
    print("solidity")
    print("parser")
my_str = 'aIbohPhoBiA'

# make it suitable for caseless comparison
my_str = my_str.casefold()

# reverse the string
rev_str = reversed(my_str)

# check if the string is equal to its reverse
if list(my_str) == list(rev_str):
    print("The string is a palindrome.")
else:
    print("The string is not a palindrome.")


