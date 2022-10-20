! Text Shell for HUSIS
! Humberto Costa dos Santos Junior, 2022
! 3-Clause BSD license
! Text user interface for HUSIS


const VERSION = 0;
const SUB_VERSION = 1;
const REVISION = 0;


! ==========================================================================
! Main
! ==========================================================================

split_cmd(line, len, cmd, cmd_len, args, args_len) do
    var i, step, pos;
    cmd::0 := 0;
    args::0 := 0;
    step := 0;
    pos := 0;
    for(i=0,len) do
        if (line::i = 0) leave;
        ie (step = 0) do
            if (pos >= cmd_len) leave;
            if (line::i = ' ') do
                step := 1;
                pos := 0;
                loop;
            end
            cmd::pos := line::i;
            pos := pos + 1;
            cmd::pos := 0;
        end
        else do
            if (pos = 0) if(line::i = ' ') loop;
            if (pos >= args_len) leave;
            args::pos := line::i;
            pos := pos + 1;
            args::pos := 0;
        end
    end
end

banner(cls)do
    t.int86ax(0x79, 1,cls,0,0 ,0,0); ! Clear screen and print banner
end

cmd_ver(args)do
    banner(TRUE);
    io_print("\ef03HUSIS Shell\ef04 v");
    io_printnum(VERSION);
    io_print(".");
    io_printnum(SUB_VERSION);
    io_print(" R");
    io_printnum(REVISION);
    io_println("\ef07");
    io_println("Copyright (c) 2022, Humberto Costa dos Santos Junior");
    io_println("License: 3-Clause BSD");
end

cmd_mem(args)do
    banner(TRUE);
    io_print("Avail. memory: ");
    io_printnum(t.int86ax(0x79, 30,0,0,0, 0,0));
    io_print("KiB");
end

cmd_type(args)do
    var stream[OBJ_STREAM], buffer::512, tmp::128, i;
    ie(open_file(args, stream)) do
        stream_buffer_init(buffer, 512);
        i := 1;
        while(i \= FALSE)do
            i := stream_readln(stream, buffer, tmp, 128);
            io_printfixed(tmp, i);
            io_printenter();
        end
        stream_close(stream);
    end
    else do
        io_errorln("File not found");
    end
end

cmd_shutdown(args)do
    t.int86ax(0x79, 2,0,0,0 ,0,0);
end

cmd_help(args)do
    banner(TRUE);
    io_println("Commands.....:");
    io_println("");
    io_println("  help       : Show this screen");
    io_println("  cls        : Clear screen");
    io_println("  ver        : Show version");
    io_println("  shutdown   : Shutdown HUSIS");
    io_println("  echo       : Print text on screen");
    io_println("  mem        : Print current memory status on screen");
    io_println("  type       : Print file contents on screen");
end

exec_cmd(cmd, args)do
    var file::128, ret, dirs, i;
    dirs := ["/System/", "/Programs/", %1];
    if(str_len(cmd) > 0)do
        ie(str_equal(cmd, "cls")) do
            t.writeln(T3X.SYSOUT, "\ec");
        end
        else ie(str_equal(cmd, "echo")) do
            t.writes(T3X.SYSOUT, "\el");
            t.writeln(T3X.SYSOUT, args);
        end
        else ie(str_equal(cmd, "help")) cmd_help(args);
        else ie(str_equal(cmd, "ver")) cmd_ver(args);
        else ie(str_equal(cmd, "mem")) cmd_mem(args);
        else ie(str_equal(cmd, "shutdown")) cmd_shutdown(args);
        else ie(str_equal(cmd, "type")) cmd_type(args);
        else ie(str_equal(cmd, "exit")) halt 0;
        else ie(str_equal(cmd, "?")) cmd_help(args);
        else do 
            i := 0;
            banner(TRUE);
            while(dirs[i] \= %1)do
                str_copy(file, dirs[i]);
                str_concat(file, cmd);
                str_concat(file, ".com");
                ret := t.int86ax(0x79, 3,file,args,0, 0,0);
                ie(ret = %1)do end
                else ie(ret = %2)do
                    t.writes(T3X.SYSERR, "Out of memory");
                    leave;
                end
                else ie(ret \= 0) do
                    t.writes(T3X.SYSOUT, "\r\nReturn.......: ");
                    t.writenum(T3X.SYSOUT, ret);
                    leave;
                end
                else leave;
                i := i + 1;
            end
            if(ret = %1)do
                t.writes(T3X.SYSERR, "Command \q");
                t.writes(T3X.SYSERR, cmd);
                t.writeln(T3X.SYSERR, "\q not found");
            end
        end
    end
end

! ==========================================================================
! Main
! ==========================================================================

do
    var line::128, cmd::20, args::128;
    banner(TRUE); ! Clear screen and print banner
    if(t.getarg(1, line, 128))do
        t.writes(T3X.SYSOUT, line);
    end
    while(%1) do
        banner(FALSE); ! Print banner
        t.writes(T3X.SYSOUT, 
            "\ex00\ey03\er80 \ex00\ey03\ef03Command......: \ef07");
        t.read(T3X.SYSIN, line, 80-16);
        t.writes(T3X.SYSOUT, "\ex00\ey05");
        split_cmd(line, 128, cmd, 20, args, 128);
        exec_cmd(cmd, args);
    end
end