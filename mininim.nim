var r2: array[2,array[3,float]]
var pi: float = 3.14159265
for i in 0..1:
    readFloat r2[i][0]
    echo pi * r2[i][0] * r2[i][0]
    break
    continue