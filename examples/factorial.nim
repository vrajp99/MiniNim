var  
   n : int
   j : int = 1
   i : int = 1
echo "Program to print factorial of all numbers <= n"
echo "Enter value of n:"
readInt n

while n>0:
    j = i*j
    echo i,"! = ", j
    i = i+1
    n = n-1