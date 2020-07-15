var 
    left: float
    right: float
    n: float
    mid: float
    tol: float
echo "Program to find the square root of a number n."
echo "Enter n:"
readFloat n
echo "Enter Tolerance:"
readFloat tol
left = 0.0
right = n
mid = (left + right)/2
while ((mid * mid - n) >= tol) or ((mid * mid - n) <= -tol):
    if mid*mid - n > 0:
        right = mid
    else:
        left = mid
    mid = (left + right)/2
echo mid