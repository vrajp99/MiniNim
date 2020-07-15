# 10 2 2
# 10 9 6 7 8 3 2 1 4 5

# 10 2 3
# 10 9 6 7 8 3 2 1 4 5

# 5 5 5
# 100000 10000 1000 100 10
var 
    n: int
    x: int
    y: int
    l: array[100,int]
echo "This program solves https://codeforces.com/contest/1199/problem/A"
echo "Enter Number of Days:"
readInt n
echo "Enter x:"
readInt x
echo "Enter y:"
readInt y

for i in 0..n-1:
    echo "Enter Amount of Rain on Day ", i+1, ":"
    readInt l[i]

for i in 0..n-1:
    var 
        flag1: int  = 1
        flag2: int  = 1
    for j in 0..x-1:
        if i-j-1 >= 0 and l[i] < l[i-j-1]:
            continue
        elif i-j-1 < 0:
            break
        else:
            flag1 = 0
            break
    for j in 0..y-1:
        if i+j+1 < n and l[i] < l[i+j+1]:
            continue
        elif i+j+1 >= n:
            break
        else:
            flag2 = 0
            break
    if flag1==1 and flag2==1:
        echo "\nEarliest 'not-so-rainy' day is Day ", i+1
        break