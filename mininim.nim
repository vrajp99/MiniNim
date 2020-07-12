var a: int = 0
var b: int = 1
var n: int
readInt n
for i in 1..n:
    var t:int = b
    b = a + b
    a = t
    echo a