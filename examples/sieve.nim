var 
    prime: array[2000,int]
    n: int
    p: int = 2

echo "Program to find all prime numbers <= n"
echo "Enter n:"
readInt n
for i in 0..n+1:
    prime[i] = 1

while p*p <= n:
    if (prime[p] == 1):
        var i:int = p*p
        while i <= n:
            prime[i] = 0
            i = i+p
    else:
        prime[p] = 0
    p = p+1
echo "The prime numbers <= ",n," are:"
for p in 2..n:
    if prime[p]==1:
        echo p
