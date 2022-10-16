! Text Shell for HUSIS
! Humberto Costa dos Santos Junior, 2022
! 3-Clause BSD license
! Text user interface for HUSIS


const VERSION = 0;
const SUB_VERSION = 1;
const REVISION = 0;

const TRUE = %1;
const FALSE = 0;

! ==========================================================================
! String/Character
! ==========================================================================

char_is_num(c) return (c >= '0') & (c <= '9');
char_is_upper(c) return (c >= 'A') & (c <= 'Z');
char_is_lower(c) return (c >= 'a') & (c <= 'z');
char_is_alpha(c) return char_is_lower(c) | char_is_upper(c);
char_is_alphanum(c) return char_is_alpha(c) | char_is_num(c);

str_len(txt) 
! Get ASCIZ string length
    return t.memscan(txt, 0, 2048);

str_copy(orig, dest) 
! Copy string contents to another
    t.memcopy(dest, orig, str_len(orig)+1);

str_concat(orig, dest)
! Concat string
    t.memcopy(@dest::str_len(dest), orig, str_len(orig)+1);

str_equal(txt1, txt2)
! Compare strings returning true if equals
    return t.memcomp(txt1, txt2, str_len(txt1)+1) = 0;

str_to_num2(str, num) do
! Convert string to number with initial value
    var ret, c;
    ret := num;
    c := str::0;
    if(char_is_num(c)) do 
        ret := (ret * 10) + (c - '0');
        ret := str_to_num2(@str::1, ret);
    end;
    return ret;
end

str_to_num(str) return str_to_num2(str, 0);
! Convert string to number

rstr_len(seg, txt) 
! Get ASCIZ string length from remote string
    return t.farscan(seg, txt, 0, 2048);

rstr_copy(sego, orig, segd, dest) 
! Copy retmote string contents to another remote string 
    t.farcopy(segd, dest, sego, orig, rstr_len(sego, orig)+1);

rstr_concat(sego, orig, segd, dest)
! Concat remote strings
    t.farcopy(
        segd, 
        @dest::rstr_len(segd, dest), 
        sego,
        orig, 
        rstr_len(sego, orig)+1);

rstr_equal(seg1, txt1, seg2, txt2)
! Compare remote strings returning true if equals
    return t.farcomp(seg1, txt1, seg2, txt2, rstr_len(seg1, txt1)+1) = 0;

rstr_to_num2(seg, str, num) do
! Convert remote string to number with initial value
    var ret, c;
    ret := num;
    c := t.fargetb(seg, str);
    if(char_is_num(c)) do 
        ret := (ret * 10) + (c - '0');
        ret := rstr_to_num2(seg, @str::1, ret);
    end;
    return ret;
end

rstr_to_num(seg, str) return rstr_to_num2(seg, str, 0);
! Convert remote string to number

! ==========================================================================
! Generic functions
! ==========================================================================

t.writes(file, str) t.write(file, str, str_len(str));
! Write string to file

t.writeln(file, str) do
! Write line string to file
    t.write(file, str, str_len(str));
    t.write(file, "\r\n", 2);
end

t.writec(file, c) do
! Write char to file
    var str::2;
    str::0 := c;
    str::1 := 0;
    t.write(file, str, 1);
end

t.writenum(file, value) do
! Write number to file
    var tmp, tmp2;
    if(value < 0) do
        t.writec(file, '-');
        value := -value;
    end
    tmp := value mod 10;
    tmp2 := value / 10;
    if (tmp2 > 0) t.writenum(file, tmp2);
    t.writec(file, tmp + '0'); 
end

print(str) t.writes(T3X.SYSOUT, str);
println(str) t.writeln(T3X.SYSOUT, str);
printnum(value) t.writenum(T3X.SYSOUT, value);

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
    print("\ef03HUSIS Shell\ef04 v");
    printnum(VERSION);
    print(".");
    printnum(SUB_VERSION);
    print(" R");
    printnum(REVISION);
    println("\ef07");
    println("Copyright (c) 2022, Humberto Costa dos Santos Junior");
    println("License: 3-Clause BSD");
end

cmd_shutdown(args)do
    t.int86ax(0x79, 2,0,0,0 ,0,0);
end

cmd_help(args)do
    banner(TRUE);
    println("Commands:");
    println("");
    println("  help         = Show this screen");
    println("  cls          = Clear screen");
    println("  ver          = Show version");
    println("  shutdown     = Shutdown HUSIS");
    println("  echo         = Print text on screen");
end

exec_cmd(cmd, args)do
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
        else ie(str_equal(cmd, "shutdown")) cmd_shutdown(args);
        else ie(str_equal(cmd, "?")) cmd_help(args);
        else do 
            t.writes(T3X.SYSERR, "Command \q");
            t.writes(T3X.SYSERR, cmd);
            t.writeln(T3X.SYSERR, "\q not found");
        end
    end
end

! ==========================================================================
! Main
! ==========================================================================

do
    var line::128, cmd::20, args::128;
    banner(TRUE); ! Clear screen and print banner
    while(%1) do
        banner(FALSE); ! Print banner
        t.writes(T3X.SYSOUT, 
            "\ex00\ey03\er80 \ex00\ey03\ef03Command......: \ef07");
        t.read(T3X.SYSIN, line, 80-16);
        t.writes(T3X.SYSOUT, "\ex00\ey05");
        split_cmd(line, 128, cmd, 20, args, 128);
        t.writes(T3X.SYSOUT, 
            "\ef03Executed.....: \ef07");
        t.writeln(T3X.SYSOUT, 
            line);
        exec_cmd(cmd, args);
    end
end