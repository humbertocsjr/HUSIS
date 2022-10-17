! HUSIS Library
! Humberto Costa dos Santos Junior, 2022
! License: 0BSD or Public Domain


! ==========================================================================
! Standard I/O
! ==========================================================================

print(str) t.int86ax(0x79, 10,str,0,0, 0,0);
error(str) t.int86ax(0x79, 11,str,0,0, 0,0);
println(str) t.int86ax(0x79, 14,str,0,0, 0,0);
errorln(str) t.int86ax(0x79, 15,str,0,0, 0,0);
printenter() t.int86ax(0x79, 14,"",0,0, 0,0);
errorenter() t.int86ax(0x79, 15,"",0,0, 0,0);
printnum(str) t.int86ax(0x79, 12,str,0,0, 0,0);
errornum(str) t.int86ax(0x79, 13,str,0,0, 0,0);
readln(dest, len) return t.int86ax(0x79, 20,dest,len,0, 0,0);

! ==========================================================================
! Process info
! ==========================================================================

husis_process_id() return t.int86ax(0x79, 4,0,0,0, 0,0);
husis_parent_id() return t.int86ax(0x79, 5,0,0,0, 0,0);
husis_other_parent_id(id) return t.int86ax(0x79, 6,0,0,0, 0,0);
husis_other_seg(id) return t.int86ax(0x79, 6,1,id,0, 0,0);
husis_other_ip(id) return t.int86ax(0x79, 6,2,id,0, 0,0);
husis_other_sp(id) return t.int86ax(0x79, 6,3,id,0, 0,0);
husis_other_bp(id) return t.int86ax(0x79, 6,4,id,0, 0,0);
husis_other_status(id) return t.int86ax(0x79, 6,5,0,0, 0,0);
husis_exit(status) return t.int86ax(0x79, 0,status,0,0, 0,0);
husis_shutdown() return t.int86ax(0x79, 2,0,0,0, 0,0);
husis_banner(clear_screen) return t.int86ax(0x79, 1,clear_screen,0,0, 0,0);
husis_exec(file_name, args) return t.int86ax(0x79, 3,file_name,args,0, 0,0);

! ==========================================================================
! String/Character
! ==========================================================================

char_is_num(c) return (c >= '0') & (c <= '9');
char_is_upper(c) return (c >= 'A') & (c <= 'Z');
char_is_lower(c) return (c >= 'a') & (c <= 'z');
char_is_alpha(c) return char_is_lower(c) | char_is_upper(c);
char_is_alphanum(c) return char_is_alpha(c) | char_is_num(c);
char_from_hex(c) do
    ie(char_is_lower(c)) return c - 'a' + 10;
    else ie(char_is_upper(c)) return c - 'A' + 10;
    else if(char_is_num(c)) return c - '0';
    return 0;
end

str_len(txt) 
! Get ASCIZ string length
    return t.memscan(txt, 0, 2048);

str_copy(dest, orig) 
! Copy string contents to another
    t.memcopy(dest, orig, str_len(orig)+1);

str_concat(dest, orig)
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

str_to_upper(str) do
! Convert to upper case
    var i;
    i := 0;
    while(str::i \= 0) do
        if(char_is_lower(str::i)) do
            str::i := str::i - 'a' + 'A';
        end
        i := i + 1;
    end
end

str_to_lower(str) do
! Convert to upper case
    var i;
    i := 0;
    while(str::i \= 0) do
        if(char_is_upper(str::i)) do
            str::i := str::i - 'A' + 'a';
        end
        i := i + 1;
    end
end

rstr_len(seg, txt) 
! Get ASCIZ string length from remote string
    return t.farscan(seg, txt, 0, 2048);

rstr_copy(segd, dest, sego, orig) 
! Copy retmote string contents to another remote string 
    t.farcopy(segd, dest, sego, orig, rstr_len(sego, orig)+1);

rstr_concat(segd, dest, sego, orig)
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

t.rwrites(file, seg, str) do
! Write string to file
    var tmp::128;
    t.farcopy(t.stack(), tmp, seg, str, 128);
    t.write(file, tmp, str_len(tmp));
end

t.writeln(file, str) do
! Write line string to file
    t.write(file, str, str_len(str));
    t.rwrites(file, t.local(), "\r\n");
end

t.rwriteln(file, seg, str) do
! Write line string to file
    t.rwrites(file, seg, str);
    t.rwrites(file, t.local(), "\r\n");
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