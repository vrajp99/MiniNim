# Example from Geeksforgeeks
# Items = 3
# Capacity = 50
# Values: 60, 100, 120
# Weights: 10, 20, 30

var dp: array[1000, array[1000,int]]
var val: array[1000,int]
var wts: array[1000,int]
var capacity: int
var num_items: int
echo "Program to find the optimal output to the 0-1 Knapsack Problem"
echo "Enter number of items:"
readInt num_items
echo "Enter capacity of the Knapsack:"
readInt capacity
for i in 0..num_items - 1:
    echo "Enter Value of Item ",i+1,":"
    readInt val[i]

for i in 0..num_items - 1:
    echo "Enter Weight of Item ",i+1,":"
    readInt wts[i]


for i in 0..num_items:
    for w in 0..capacity:
        if (i==0 or w==0):
            dp[i][w] = 0
        else:
            if (wts[i-1] <= w):
                if val[i-1] + dp[i-1][w-wts[i-1]] < dp[i-1][w]:
                    dp[i][w] = dp[i-1][w]
                else:
                    dp[i][w] = val[i-1] + dp[i-1][w-wts[i-1]]
            else:
                dp[i][w] = dp[i-1][w]
echo "Optimal Selection Value: ", dp[num_items][capacity]