from strutils import parseInt, parseInt
proc readInt*(i: var int) = 
    var input = readLine(stdin)
    i = input.parseInt()