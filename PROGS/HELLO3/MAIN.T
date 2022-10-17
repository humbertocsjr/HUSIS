

do
    var tmp::10;
    println("Hello World from T3X/86 using HUSIS API!");

    print("Process ID........: ");
    printnum(husis_process_id());
    printenter();

    print("Parent ID.........: ");
    printnum(husis_parent_id());
    printenter();

    print("Segment...........: ");
    printnum(husis_other_seg(husis_process_id()));
    printenter();

    print("Parent Segment....: ");
    printnum(husis_other_seg(husis_parent_id()));
    printenter();

    
    readln(tmp, 10);

end