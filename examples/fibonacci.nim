var fib: array[40, int]
var n: int
echo "Program to find the first n Fibonacci numbers."
echo "Enter n:"
readInt n
fib[0] = 0
fib[1] = 1
for i in 2..n:
    fib[i] = fib[i-1] + fib[i-2]

for i in 0..n:
    echo "Fib(",i,") = ", fib[i]