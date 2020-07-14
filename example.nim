import mininim_compat
var
   n : int
echo "This is a FizzBuzz Program."
echo "Enter number upto which to play FizzBuzz:"
readInt n
echo 1.0 + 1
for i in 1..n:
    if (i mod 15 == 0):
        echo "FizzBuzz"
    elif (i mod 3 == 0):
        echo "Fizz"
    elif (i mod 5 == 0):
        echo "Buzz"
    else:
        echo i