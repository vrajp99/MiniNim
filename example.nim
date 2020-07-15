var  
   A : array[10,int]
   res : int = 0
   n: int
echo "Alice and Bob play the nim game. Alice starts first."
echo "Enter Number of piles (<= 10):"
readInt n
for i in 0..n-1:
    echo "Enter size of pile ",i+1, ":"
    readInt A[i]
    res = res xor A[i]

if (res == 0):
    echo "The winner is Bob"
else:
    echo "The winner is Alice"