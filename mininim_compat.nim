from strutils import parseInt, parseFloat
proc readInt*[T](i: var T) = 
    var input = readLine(stdin)
    i = parseInt(input)

proc readFloat*[T](i: var T) = 
    var input = readLine(stdin)
    i = parseFloat(input)