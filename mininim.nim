var r2: array[2,float]
var pi: float = 3.14159265
for i in 0..1:
    readFloat r2[i]
    echo pi * r2[i] * r2[i]
    break
    continue