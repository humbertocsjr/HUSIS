! HUSIS Library
! Humberto Costa dos Santos Junior, 2022
! License: 0BSD or Public Domain


const TRUE = %1;
const FALSE = 0;

! ==========================================================================
! Standard I/O
! ==========================================================================

io_print(str) t.int86ax(0x79, 10,str,0,0, 0,0);
io_error(str) t.int86ax(0x79, 11,str,0,0, 0,0);
io_println(str) t.int86ax(0x79, 14,str,0,0, 0,0);
io_errorln(str) t.int86ax(0x79, 15,str,0,0, 0,0);
io_printenter() t.int86ax(0x79, 14,"",0,0, 0,0);
io_errorenter() t.int86ax(0x79, 15,"",0,0, 0,0);
io_printnum(str) t.int86ax(0x79, 12,str,0,0, 0,0);
io_errornum(str) t.int86ax(0x79, 13,str,0,0, 0,0);
io_printfixed(str, len) t.int86ax(0x79, 16,str,len,0, 0,0);
io_errorfixed(str, len) t.int86ax(0x79, 17,str,len,0, 0,0);
io_printchar(char) t.int86ax(0x79, 18,char,0,0, 0,0);
io_errorchar(char) t.int86ax(0x79, 19,char,0,0, 0,0);
io_readln(dest, len) return t.int86ax(0x79, 20,dest,len,0, 0,0);

! ==========================================================================
! File
! ==========================================================================


const STATUS_FS_AVAIL = 0;
const STATUS_FS_MOUNTED = 1;


struct OBJ_FS = 
! File System Object
    FS_STATUS,
    FS_ID,
    FS_DISK,
    FS_SEG,
    FS_PTR_FIRST_ITEM,
    FS_PTR_NEXT_ITEM,
    FS_PTR_UMOUNT,
    FS_AUX1,
    FS_AUX2,
    FS_AUX3,
    FS_AUX4,
    FS_AUX5,
    FS_AUX6,
    FS_AUX7,
    FS_AUX8,
    FS_AUX9,
    FS_AUX10;

const TYPE_UNKNOWN = 0;
const TYPE_FILE = 1;
const TYPE_DIRECTORY = 2;

struct OBJ_ITEM_HEADER =
! File System Item Object
    ITEM_TYPE,
    ITEM_PARENT_ID,
    ITEM_ID,
    ITEM_POS_ON_PARENT,
    ITEM_SEG_OPEN,
    ITEM_PTR_OPEN,
    ITEM_FS,
    ITEM_NAME;

open_file(address, stream) return t.int86ax(0x79, 44,address,stream,0, 0,0);
open_dir(address, item) return t.int86ax(0x79, 40,address,item,0, 0,0);
item_first(dir_item, item) return t.int86ax(0x79, 41,dir_item,item,0, 0,0);
item_next(dir_item, item) return t.int86ax(0x79, 42,dir_item,item,0, 0,0);
item_open(item, stream) return t.int86ax(0x79, 43,item,stream,0, 0,0);
item_copy(item_dest, item_orig) return t.int86ax(0x79, 43,item_orig,item_dest,0, 0,0);

! ==========================================================================
! Stream I/O
! ==========================================================================

const STATUS_UNKNOWN = 0;
const STATUS_OPEN = 1;
const STATUS_CLOSE = 2;

struct OBJ_RET =
! Return Object
    RET_OK,
    RET_VALUE,
    RET_AUX;

struct OBJ_STREAM = 
! String Object
    STREAM_STATUS,
    STREAM_SEG, 
    STREAM_PTR_AVAIL,
    STREAM_PTR_SEEK,
    STREAM_PTR_CAN_READ, 
    STREAM_PTR_READ, 
    STREAM_PTR_CAN_WRITE,
    STREAM_PTR_WRITE,
    STREAM_PTR_CLOSE,
    STREAM_SEG_BUFFER,
    STREAM_SIZE_BUFFER,
    STREAM_PTR_BUFFER,
    STREAM_POS_BUFFER,
    STREAM_POS,
    STREAM_POS_HIGH,
    STREAM_AUX1,
    STREAM_AUX2,
    STREAM_AUX3,
    STREAM_AUX4,
    STREAM_AUX5,
    STREAM_AUX6,
    STREAM_AUX7,
    STREAM_AUX8,
    STREAM_AUX9,
    STREAM_AUX10;

stream_readfixed(stream, dest, len) return t.int86ax(0x79, 50,stream,dest,len, 0,0);
stream_writefixed(stream, orig, len) return t.int86ax(0x79, 51,stream,orig,len, 0,0);
stream_close(stream) return t.int86ax(0x79, 52,stream,0,0, 0,0);
stream_buffer_init(buffer, total_len) do
    if(total_len < 10) return FALSE;
    buffer[0] := total_len - 6;
    buffer[1] := 0;
    buffer[2] := 0;
    return TRUE;
end
stream_readln(stream, buffer, dest, dest_len) do
    var i, j, contents;
    if(buffer[1] = 0) do
        buffer[1] := stream_readfixed(stream, @buffer[3], buffer[0]);
        if(buffer[1] = 0) return FALSE;
        buffer[2] := 0;
    end
    dest::0 := 0;
    contents := @buffer[3];
    j := buffer[2];
    for(i=0,dest_len) do
        if(j = buffer[1]) do
            buffer[1] := stream_readfixed(stream, @buffer[3], buffer[0]);
            if(buffer[1] = 0) return i;
            buffer[2] := 0;
            j := 0;
        end
        if(contents::j = 0) leave;
        if(contents::j = '\n') leave;
        if(contents::j \= '\r') do
            dest::i := contents::j;
            i := i + 1;
            dest::i := 0;
        end
        j := j + 1;
        buffer[2] := j;
    end
    return i;
end

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