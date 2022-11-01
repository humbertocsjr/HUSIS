

do
    var tmp::10;
    io_println("Hello World from T3X/86 using HUSIS API!");

    io_print("Process ID........: ");
    io_printnum(husis_process_id());
    io_printenter();

    io_print("Parent ID.........: ");
    io_printnum(husis_parent_id());
    io_printenter();

    io_print("Segment...........: ");
    io_printnum(husis_other_seg(husis_process_id()));
    io_printenter();

    io_print("Parent Segment....: ");
    io_printnum(husis_other_seg(husis_parent_id()));
    io_printenter();

    io_print("DOS API Test......: ");
    t.writes(T3X.SYSOUT, "[ SYSOUT OK ]");
    t.writes(T3X.SYSERR, "[ SYSERR OK ]");
    io_printenter();

    io_print("Press ENTER to continue");
    io_readln(tmp, 0);

end