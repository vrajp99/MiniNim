block outout:
    proc app(a:int,b:int,c:int,   ):int = return 0
    var a = app(1,2,3,)
    type k = enum appc bccc ccccc
    var (c,d) = (0,1)
    (d,c) = (1,0)
    var b = 1 div 2
    var ax = if 1==2 : 1
     else: 2 
    echo(1 and not 1)
    var x = (discard 1; 2);
    for i in 0..3:
        if i==2:
            break
        echo x
    echo 2
    # echo y