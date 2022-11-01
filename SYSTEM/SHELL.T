!
! DONT EDIT THIS FILE
!
! DONT EDIT THIS FILE
!
! DONT EDIT THIS FILE
!
! DONT EDIT THIS FILE
!
! DONT EDIT THIS FILE
!
! DONT EDIT THIS FILE
!




! HUSIS Library
! Humberto Costa dos Santos Junior, 2022
! License: 0BSD or Public Domain


const TRUE = %1;
const FALSE = 0;

! ==========================================================================
! Memory Management
! ==========================================================================

mem_calc_free_kib() return t.int86ax(0x79, 400,0,0,0, 0,0);
mem_calc_free() return t.int86ax(0x79, 401,0,0,0, 0,0);
mem_size(segment) return t.int86ax(0x79, 402,segment,0,0, 0,0);

! ==========================================================================
! Video API
! ==========================================================================

video_can_show_colors() 
    return t.int86ax(0x82, 2,0,0,0, 0,0);
video_can_customize() 
    return t.int86ax(0x82, 1,0,0,0, 0,0);
video_cls() 
    return t.int86ax(0x82, 3,0,0,0, 0,0);
video_write_char(char) 
    return t.int86ax(0x82, 4,char,0,0, 0,0);
video_write_string(str) 
    return t.int86ax(0x82, 5,str,0,0, 0,0);
video_goto(x, y) 
    return t.int86ax(0x82, 6,x,y,0, 0,0);
video_set_font8x8(font) 
    return t.int86ax(0x82, 7,font,0,0, 0,0);
video_get_height() 
    return t.int86ax(0x82, 8,0,0,0, 0,0);
video_get_width() 
    return t.int86ax(0x82, 9,0,0,0, 0,0);
video_write_char_color(char) 
    return t.int86ax(0x82, 10,char,0,0, 0,0);

! ==========================================================================
! Kernel I/O
! ==========================================================================

kernel_print(str) t.int86ax(0x79, 101,str,0,0, 0,0);
kernel_println(str) t.int86ax(0x79, 102,str,0,0, 0,0);
kernel_printenter() t.int86ax(0x79, 105,0,0,0, 0,0);
kernel_printnum(str) t.int86ax(0x79, 103,str,0,0, 0,0);
kernel_printfixed(str, len) t.int86ax(0x79, 100,str,len,0, 0,0);
kernel_printchar(char) t.int86ax(0x79, 106,char,0,0, 0,0);


! ==========================================================================
! Standard I/O
! ==========================================================================

io_cls() t.int86ax(0x81, 100,0,0,0, 0,0);
io_print(str) t.int86ax(0x81, 102,str,0,0, 0,0);
io_error(str) t.int86ax(0x81, 105,str,0,4, 0,0);
io_println(str) t.int86ax(0x81, 103,str,0,0, 0,0);
io_errorln(str) t.int86ax(0x81, 106,str,0,4, 0,0);
io_printenter() t.int86ax(0x81, 109,0,0,0, 0,0);
io_errorenter() t.int86ax(0x81, 109,0,0,0, 0,0);
io_printnum(str) t.int86ax(0x81, 107,str,0,0, 0,0);
io_errornum(str) t.int86ax(0x81, 108,str,0,0, 0,0);
io_printfixed(str, len) t.int86ax(0x81, 101,str,len,0, 0,0);
io_errorfixed(str, len) t.int86ax(0x81, 104,str,len,4, 0,0);
io_printchar(char) t.int86ax(0x81, 110,char,0,0, 0,0);
io_errorchar(char) t.int86ax(0x81, 111,char,0,4, 0,0);
io_avail() return t.int86ax(0x81, 112,0,0,0, 0,0);
io_readchar() return t.int86ax(0x81, 113,0,0,0, 0,0);
io_readln(dest, len) return t.int86ax(0x81, 114,dest,len,0, 0,0);

! ==========================================================================
! User Interface API
! ==========================================================================

ui_new(control, type) t.int86ax(0x81, 200,control,type,0, 0,0);
ui_render(control) t.int86ax(0x81, 201,control,0,0, 0,0);
ui_destroy(control) t.int86ax(0x81, 202,control,0,0, 0,0);
ui_attach(control, parent) t.int86ax(0x81, 203,control,0,0, 0,0);
ui_attach_window(control) t.int86ax(0x81, 204,control,0,0, 0,0);
ui_show(control) t.int86ax(0x81, 205,control,0,0, 0,0);
ui_hide(control) t.int86ax(0x81, 205,control,0,0, 0,0);

ui_new_type(type,ptr_render,ptr_focus,ptr_key,ptr_mouse)
    t.int86ax(0x81, 300,type,ptr_render,ptr_focus, ptr_key,ptr_mouse);

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

const OBJ_ITEM = OBJ_ITEM_HEADER + 16; ! 16 Words/32 Bytes to name

open_file(address, stream) return t.int86ax(0x79, 504,address,stream,0, 0,0);
open_dir(address, item) return t.int86ax(0x79, 503,address,item,0, 0,0);
item_first(dir_item, item) return t.int86ax(0x79, 505,dir_item,item,0, 0,0);
item_next(item) return t.int86ax(0x79, 506,item,0,0, 0,0);
item_open(item, stream) return t.int86ax(0x79, 502,item,stream,0, 0,0);
item_copy(item_dest, item_orig) return t.int86ax(0x79, 507,item_orig,item_dest,0, 0,0);
path_get(dest, len) return t.int86ax(0x79, 509,dest,len,0, 0,0);
path_set(path) return t.int86ax(0x79, 508,path,0,0, 0,0);


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

stream_readfixed(stream, dest, len) return t.int86ax(0x79, 205,stream,dest,len, 0,0);
stream_writefixed(stream, orig, len) return t.int86ax(0x79, 206,stream,orig,len, 0,0);
stream_close(stream) return t.int86ax(0x79, 204,stream,0,0, 0,0);
stream_buffer_init(buffer, total_len) do
    if(total_len < 10) return FALSE;
    buffer[0] := total_len - 6;
    buffer[1] := 0;
    buffer[2] := 0;
    buffer[3] := 0;
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
    for(i=0,dest_len-1) do
        if(j >= buffer[1]) do
            ie(buffer[1] = buffer[0])do
                buffer[1] := stream_readfixed(stream, @buffer[3], buffer[0]);
                if(buffer[1] = 0)do
                    ie(i > 0)
                        return TRUE;
                    else
                        return FALSE;
                end
                buffer[2] := 0;
                j := 0;
            end
            else return (i > 0);
        end
        if(contents::j = 0) ie(i > 0) leave; else return FALSE;
        if(contents::j = '\n')do
            buffer[2] := j + 1;
            leave;
        end
        ie(contents::j \= '\r') do
            dest::i := contents::j;
            dest::(i+1) := 0;
        end
	    else i := i - 1;
        j := j + 1;
        buffer[2] := j;
    end
    return TRUE;
end

! ==========================================================================
! Process info
! ==========================================================================

husis_process_id() return t.int86ax(0x79, 302,0,0,0, 0,0);
husis_parent_id() return t.int86ax(0x79, 309,0,0,0, 0,0);
husis_other_parent_id(id) return t.int86ax(0x79, 308,id,0,0, 0,0);
husis_other_seg(id) return t.int86ax(0x79, 304,id,0,0, 0,0);
husis_other_ip(id) return t.int86ax(0x79, 305,id,0,0, 0,0);
husis_other_sp(id) return t.int86ax(0x79, 306,id,0,0, 0,0);
husis_other_bp(id) return t.int86ax(0x79, 307,id,0,0, 0,0);
husis_other_status(id) return t.int86ax(0x79, 303,id,0,0, 0,0);
husis_exit(status) return t.int86ax(0x79, 0,status,0,0, 0,0);
husis_exit_main() return t.int86ax(0x79, 2,0,0,0, 0,0);
husis_shutdown() return t.int86ax(0x79, 1,0,0,0, 0,0);
husis_exec_com(file_name, args) return t.int86ax(0x79, 300,file_name,args,0, 0,0);
husis_exec_prg(file_name, args) return t.int86ax(0x79, 301,file_name,args,0, 0,0);
husis_int_set(old_seg_ptr, int, function) 
    return t.int86ax(0x79, 3,old_seg_ptr,t.local(),int, function,0);
husis_int_restore(old_seg_ptr, int) 
    return t.int86ax(0x79, 4,old_seg_ptr,int,0, 0,0);

! ==========================================================================
! String/Character
! ==========================================================================

char_is_num(c) return (c >= '0') & (c <= '9');
char_is_upper(c) return (c >= 'A') & (c <= 'Z');
char_is_lower(c) return (c >= 'a') & (c <= 'z');
char_is_alpha(c) return char_is_lower(c) | char_is_upper(c);
char_is_alphanum(c) return char_is_alpha(c) | char_is_num(c);
char_to_upper(c) do
    if(char_is_lower(c)) return c - 'a' + 'A';
    return c; 
end
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

str_from_num(str, len, num) do
! Convert number to string
    var i, j;
    ie(num > 9999) i := 5;
    else ie(num > 999) i := 4;
    else ie(num > 99) i := 3;
    else ie(num > 9) i := 2;
    else i:= 1;
    str::0 := 0;
    if((i+1) > len) return FALSE;
    if(num < 0) do
        i := i + 1;
        str::0 := '-';
        str::1 := 0;
    end
    for(j=0,i) do
        str::(i-j) := (num mod 10) + '0';
        str::(i-j+1) := 0;
        num := num / 10;
        if(num = 0) leave;
    end
    return TRUE;
end

str_from_num_fixed(str, len, num) do
! Convert number to string
    var i, j;
    i := len;
    for(j=0,len) do
        str::j := '0';
        str::(j+1) := 0;
    end
    if(num < 0) do
        str::0 := '-';
    end
    for(j=0,i) do
        str::(i-j-1) := (num mod 10) + '0';
        num := num / 10;
        if(num = 0) leave;
    end
    return TRUE;
end

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

str_to_hex2(str, num) do
! Convert string to number with initial value
    var ret, c;
    ret := num;
    c := str::0;
    ie(char_is_num(c)) do
        ret := (ret * 10) + (c - '0');
        ret := str_to_hex2(@str::1, ret);
    end
    else ie((c >= 'a') &(c <= 'f')) do
        ret := (ret * 10) + (c - 'a' + 10);
        ret := str_to_hex2(@str::1, ret);
    end
    else if((c >= 'A') &(c <= 'F')) do
        ret := (ret * 10) + (c - 'A' + 10);
        ret := str_to_hex2(@str::1, ret);
    end
    return ret;
end

str_to_hex(str) return str_to_hex2(str, 0);
! Convert string to number

str_to_binary2(str, num) do
! Convert string to number with initial value
    var ret, c;
    ret := num;
    c := str::0;
    ie(c = '0') do
        ret := (ret << 1);
        ret := str_to_binary2(@str::1, ret);
    end
    else if(c = 1) do
        ret := (ret << 1) + 1;
        ret := str_to_binary2(@str::1, ret);
    end
    return ret;
end

str_to_binary(str) return str_to_binary2(str, 0);
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

str_endswith(str, search) return str_equal(str+str_len(str)-str_len(search), search);

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

! Text Shell for HUSIS
! Humberto Costa dos Santos Junior, 2022
! 3-Clause BSD license
! Text user interface for HUSIS


const VERSION = 0;
const SUB_VERSION = 1;
const REVISION = 0;

! ==========================================================================
! Terminal I/O
! ==========================================================================
struct COLORS = BLACK, DARK_BLUE, DARK_GREEN, DARK_CYAN, DARK_RED,
                DARK_MAGENTA, BROWN, DARK_GRAY, LIGHT_GRAY,
                LIGHT_BLUE, LIGHT_GREEN, LIGHT_CYAN, LIGHT_RED, LIGHT_MAGENTA, 
                LIGHT_YELLOW, WHITE;


var TermSeg, TermPtr, TermX, TermY, TermColors, TermCmd, TermCmdPos, 
    TermValueA, TermValueB, TermFont8x8::2048, TermFont8x14::4096, TermHeight,
    TermWidth, TermUtf8Pos, TermUtf8_0, TermUtf8_1, TermUtf8_2, TermUtf8_3;



term_cls() do
! Clear screen
    var i;
    t.farsetw(t.local(), @TermCmdPos, 0);
    t.farsetw(t.local(), @TermX, 0);
    t.farsetw(t.local(), @TermY, 0);
    t.farsetw(t.local(), @TermCmd, 0);
    t.farsetw(t.local(), @TermPtr, 0);
    t.farfillw(t.fargetw(t.local(), @TermSeg), 0, t.fargetw(t.local(), 
        @TermColors)|' ', 80*25);
end

term_calc_pos(x, y) do
! Calculate new position
    var max_y, max_x, total_x;
    max_x := t.fargetw(t.local(), @TermWidth);
    max_y := t.fargetw(t.local(), @TermHeight);
    if((x >= max_x)|(y >= max_y))do
        while(x >= max_x) do
            x := x - max_x;
            y := y + 1;
        end
        if(y > max_y) y := 0;
    end
    t.farsetw(t.local(), @TermX, x);
    t.farsetw(t.local(), @TermY, y);
    !video_goto(x, y);
    t.farsetw(t.local(), @TermPtr, (y * 80 + x) << 1);
end

term_get_height() return t.fargetw(t.local(), @TermHeight);
term_get_width() return t.fargetw(t.local(), @TermWidth);

term_colors_set(fore, back) do
! Set new colors to output
    t.farsetw(t.local(), @TermColors, (back << 12) | (fore << 8));
end

term_color_fore(fore) do
! Set fore color
    t.farsetw(t.local(), @TermColors, 
        (t.fargetw(t.local(), @TermColors) & 0xf000) | (fore << 8));
end

term_color_back(back) do
! Set back color
    t.farsetw(t.local(), @TermColors, 
        (t.fargetw(t.local(), @TermColors) & 0x0f00) | (back << 12));
end


term_write_char(c) do
! Write char to screen
!
! Special escape commands:
! \ec       = Clear screen
! \el       = Clear current line and set x = 0
! \ex00     = Set X position (00-80)
! \ey00     = Set Y position (00-25)
! \ef00     = Set fore color (00-15)
! \eb00     = Set back color (00-15)
! \er00C    = Repeat C character 00 times (00-99)
! \eR00HH   = Repeat HH(Hex) character 00 times (00-FF)
!
    var i, y, cmd, cmd_pos, value_a, value_b, utf_pos, utf_0, utf_1, utf_2, utf_3;
    if(c = '\e') do
        t.farsetw(t.local(), @TermCmdPos, 1);
        return;
    end
    cmd := t.fargetw(t.local(), @TermCmd);
    cmd_pos := t.fargetw(t.local(), @TermCmdPos);
    value_a := t.fargetw(t.local(), @TermValueA);
    value_b := t.fargetw(t.local(), @TermValueB);
    utf_pos := t.fargetw(t.local(), @TermUtf8Pos);
    utf_0 := t.fargetw(t.local(), @TermUtf8_0);
    utf_1 := t.fargetw(t.local(), @TermUtf8_1);
    utf_2 := t.fargetw(t.local(), @TermUtf8_2);
    utf_3 := t.fargetw(t.local(), @TermUtf8_3);
    if(cmd_pos > 0) do
        ie(cmd_pos = 1) do
            value_a := 0;
            cmd_pos := 0;
            cmd := c;
            ie(c = 'c') term_cls();
            else ie(c = 'l') do
                t.farsetw(t.local(), @TermCmdPos, cmd_pos);
                y := t.fargetw(t.local(), @TermY);
                term_calc_pos(0, y);
                for(i=0,80) term_write_char(' ');
                term_calc_pos(0, y);
            end            
            else ie(c = 'f') cmd_pos := 2;
            else ie(c = 'b') cmd_pos := 2;
            else ie(c = 'x') cmd_pos := 2;
            else ie(c = 'y') cmd_pos := 2;
            else ie(c = 'r') cmd_pos := 2;
            else ie(c = 'R') cmd_pos := 2;
            else cmd_pos := 0;
            t.farsetw(t.local(), @TermCmdPos, cmd_pos);
        end 
        else ie(cmd_pos = 2) do
            cmd_pos := 3;
            if(\char_is_num(c)) cmd_pos := 0;
            value_a := (c - '0') * 10;
            t.farsetw(t.local(), @TermCmdPos, cmd_pos);
        end
        else ie(cmd_pos = 3) do
            cmd_pos := 0;
            t.farsetw(t.local(), @TermCmdPos, cmd_pos);
            if(\char_is_num(c)) return;
            value_a := (c - '0') + value_a;
            ie(cmd = 'x') 
                term_calc_pos(value_a, t.fargetw(t.local(), @TermY));
            else ie(cmd = 'y') 
                term_calc_pos(t.fargetw(t.local(), @TermX), value_a);
            else ie(cmd = 'r') 
                cmd_pos := 4;
            else ie(cmd = 'R') 
                cmd_pos := 4;
            else ie(cmd = 'f') 
                term_color_fore(value_a);
            else ie(cmd = 'b') 
                term_color_back(value_a);
            else cmd_pos := 0;
            t.farsetw(t.local(), @TermCmdPos, cmd_pos);
        end
        else ie(cmd_pos = 4) do
            cmd_pos := 0;
            t.farsetw(t.local(), @TermCmdPos, cmd_pos);
            ie(cmd = 'r') 
                for(i=0,value_a) term_write_char(c);
            else if(cmd = 'R') do
                value_b := char_from_hex(c) << 4;
                cmd_pos := 5;
            end 
        end
        else ie(cmd_pos = 5) do
            cmd_pos := 0;
            t.farsetw(t.local(), @TermCmdPos, cmd_pos);
            if(cmd = 'R') do
                value_b := value_b|char_from_hex(c);
                for(i=0,value_a) 
                    term_write_char(value_b);
            end 
        end
        else cmd_pos := 0;
        t.farsetw(t.local(), @TermCmdPos, cmd_pos);
        t.farsetw(t.local(), @TermCmd, cmd);
        t.farsetw(t.local(), @TermValueA, value_a);
        t.farsetw(t.local(), @TermValueB, value_b);
        return;
    end
    if(c = 13) do
        term_calc_pos(0, t.fargetw(t.local(), @TermY));
        return;
    end
    if(c = 10) do
        term_calc_pos(0, t.fargetw(t.local(), @TermY) + 1);
        return;
    end
    if(c = 8) do
        ie(t.fargetw(t.local(), @TermX) = 0)
            term_calc_pos(79, t.fargetw(t.local(), @TermY) - 1);
        else
            term_calc_pos(t.fargetw(t.local(), @TermX) - 1, t.fargetw(t.local(), @TermY));
        return;
    end
    if(c = 9) do
        c := ' ';
    end
    if(char_is_lower(c)) c := char_to_upper(c);
    ie((c = 0xc3) & (utf_pos = 0)) do
        t.farsetw(t.local(), @TermUtf8Pos, 1);
        t.farsetw(t.local(), @TermUtf8_0, c);
    end
    else if(utf_pos > 0) do
        t.farsetw(t.local(), @TermUtf8Pos, 0);
        if(utf_pos = 1)do
            if(utf_0 = 0xc3) do
                ie(c = 0x87) c := 0x6a;
                else ie(c = 0xa7) c := 0x6a;
                else c := '?';
            end
        end 
    end
    t.farsetw(
            t.fargetw(t.local(), @TermSeg), 
            t.fargetw(t.local(), @TermPtr), 
            c | t.fargetw(t.local(), @TermColors));
!    video_write_char_color(c | t.fargetw(t.local(), @TermColors));
    term_calc_pos(t.fargetw(t.local(), @TermX) + 1, t.fargetw(t.local(), @TermY));
end

term_writef(orig, len) do
! Write formating
    var i, escape, c;
    escape := FALSE;
    for(i=0,len) do
        c := orig::i;
        ie(escape)do
            escape := FALSE;
            ie(c = 'e') term_write_char('\e');
            else ie(c = 'n') term_write_char('\n');
            else ie(c = 'b') term_write_char('\b');
            else ie(c = 't') term_write_char('\t');
            else ie(c = 'q') term_write_char('\q');
            else ie(c = 'r') term_write_char('\r');
            else term_write_char(c);
        end
        else ie(c = '\\') do
            escape := TRUE;
        end
        else do
            term_write_char(c);
        end
    end
end

term_write(orig, len) do
! Write to screen
    var i;
    for(i=0,len) do
        term_write_char(orig::i);
    end
end 

term_rwrite(seg, orig, len) do
! Write to screen
    var i;
    for(i=0,len) do
        term_write_char(t.fargetb(seg, orig + i));
    end
end 

term_kwrite(orig, len) do
! Write to screen
    var i;
    for(i=0,len) do
        term_write_char(t.fargetb(t.local(), orig + i));
    end
end 

term_writes(orig) 
! Write string on screen
    term_write(orig, str_len(orig));

term_writefs(orig) 
! Write string on screen
    term_writef(orig, str_len(orig));

term_rwrites(seg, orig) 
! Write string on screen
    term_rwrite(seg, orig, rstr_len(seg, orig));

term_kwrites(orig) 
! Write string on screen
    term_kwrite(orig, rstr_len(t.local(),orig));

term_writeln(orig) do
! Write string on screen
    term_writes(orig);
    term_write_char(13);
    term_write_char(10);
end

term_writefln(orig) do
! Write string on screen
    term_writefs(orig);
    term_write_char(13);
    term_write_char(10);
end

term_rwriteln(seg, orig) do
! Write string on screen
    term_rwrites(seg, orig);
    term_write_char(13);
    term_write_char(10);
end

term_kwriteln(orig) do
! Write string on screen
    term_kwrites(orig);
    term_write_char(13);
    term_write_char(10);
end


term_writenum(value) do
! Write number to stream
    var tmp, tmp2;
    if(value < 0) do
        term_write_char('-');
        value := -value;
    end
    tmp := value mod 10;
    tmp2 := value / 10;
    if (tmp2 > 0) term_writenum(tmp2);
    term_write_char(tmp + '0'); 
end

term_writehex(value) do
! Write Hexadecimal to stream
    var tmp, tmp2;
    tmp := value & 15;
    tmp2 := value >> 4;
    if (tmp2 > 0) term_writehex(tmp2);
    ie (tmp < 10) term_write_char(tmp + '0'); 
    else term_write_char(tmp + 'a' - 10);
end

term_read_char() do
! Read key from keyboard using BIOS
    return t.int86ax(0x16, 0,0,0,0, 0,0) & 0xff;
end

term_avail() do
! Check if has key avail
    return (t.int86z(0x16, 0x100,0,0,0, 0,0) = 1) -> FALSE : TRUE;
end

term_read(dest, len) do
! Read line string from keyboard showing on screen
    var pos, c;
    pos := 0;
    dest::pos := 0;
    term_write_char('_');
    while(%1) do
        c := term_read_char();
        if (c = 0xd) leave;
        if (c = 0xa) leave;
        ie (c = 0x8) do
            if (pos = 0) loop;
            term_write_char(c);
            term_write_char(c);
            term_write_char('_');
            term_write_char(' ');
            term_write_char(c);
            pos := pos - 1;
        end
        else do
            if ((pos + 2) > len) loop;
            dest::pos := c;
            term_write_char(8);
            term_write_char(c);
            term_write_char('_');
            pos := pos + 1;
        end
        dest::pos := 0;
    end
    term_write_char(8);
    term_write_char(' ');
    term_write_char(13);
    term_write_char(10);
    return pos;
end 

term_init() do
    ! Initialize Standard I/O
    TermSeg := 0xb800;
    TermCmd := 0;
    TermCmdPos := 0;
    TermUtf8Pos := 0;
    TermValueA := 0;
    TermValueB := 0;
    TermHeight := video_get_height();
    TermWidth := video_get_width();
    term_calc_pos(0, 0);
    term_colors_set(DARK_GRAY, BLACK);
end

! ==========================================================================
! Shell/User Interface API
! ==========================================================================

var Int81Old::T3X.PTRSIZE;

int_debug(int,ax,bx,cx,dx,ds,si,es,di) do
! Show calling args on screen
    term_kwrites("[INT 0x");
    term_writehex(int);
    term_kwrites(" AX ");
    term_writenum(ax);
    term_kwrites(" AH 0x");
    term_writehex(ax >> 8);
    term_kwrites(" BX ");
    term_writenum(bx);
    term_kwrites(" CX ");
    term_writenum(cx);
    term_kwrites(" DX ");
    term_writenum(dx);
    term_kwrites(" DS ");
    term_writenum(es);
    term_kwrites(" SI ");
    term_writenum(si);
    term_kwrites(" ES ");
    term_writenum(es);
    term_kwrites(" DI ");
    term_writenum(di);
    term_kwrites("]\r\n");
end

int81(ax,bx,cx,dx,ds,si,es,di,ss,sp) farint do
    var color;
    !
    ! 0xx Shell API
    !
    ie(ax < 100) do
        int_debug(0x79, ax,bx,cx,dx,ds,si,es,di);
    end
    !
    ! 1xx Terminal API
    !
    else ie(ax < 200) do
        ie(ax = 100) do ! Clear screen
            term_cls();
        end
        else ie(ax = 101) do ! Write String on Screen(bx=string | cx=len)
            term_write(bx, cx);
        end
        else ie(ax = 102) do ! Write String on Screen(bx=string)
            term_writes(bx);
        end
        else ie(ax = 103) do ! Write String on Screen(bx=string)
            term_writeln(bx);
        end
        else ie(ax = 104) do ! Write String on Screen(bx=string|cx=len|dx=colors)
            color := t.fargetw(t.local(), @TermColors);
            t.farsetw(t.local(), @TermColors, dx << 8);
            term_write(bx, cx);
            t.farsetw(t.local(), @TermColors, color);
        end
        else ie(ax = 105) do ! Write String on Screen(bx=string | dx=colors)
            color := t.fargetw(t.local(), @TermColors);
            t.farsetw(t.local(), @TermColors, dx << 8);
            term_writes(bx);
            t.farsetw(t.local(), @TermColors, color);
        end
        else ie(ax = 106) do ! Write String on Screen(bx=string | dx=colors)
            color := t.fargetw(t.local(), @TermColors);
            t.farsetw(t.local(), @TermColors, dx << 8);
            term_writeln(bx);
            t.farsetw(t.local(), @TermColors, color);
        end
        else ie(ax = 107) do ! Write number on Screen(bx=string)
            term_writenum(bx);
        end
        else ie(ax = 108) do ! Write hex on Screen(bx=string)
            term_writehex(bx);
        end
        else ie(ax = 109) do ! New line
            term_kwriteln("");
        end
        else ie(ax = 110) do ! Write char on Screen(bx=char)
            term_write_char(bx);
        end
        else ie(ax = 111) do ! Write char on Screen(bx=char | dx=colors)
            color := t.fargetw(t.local(), @TermColors);
            t.farsetw(t.local(), @TermColors, dx << 8);
            term_write_char(bx);
            t.farsetw(t.local(), @TermColors, color);
        end
        else ie(ax = 112) do ! Return input data avail
            ax := term_avail();
        end
        else ie(ax = 113) do ! Wait and Get char from input
            ax := term_read_char();
        end
        else ie(ax = 114) do ! Read line from input
            ax := term_read(bx, cx);
        end
        else int_debug(0x79, ax,bx,cx,dx,ds,si,es,di);
    end
    else int_debug(0x79, ax,bx,cx,dx,ds,si,es,di);
end


! ==========================================================================
! Main
! ==========================================================================

var Font8x8::4096;

load_font(font_file)do
    var buffer::512, tmp::256, stream[OBJ_STREAM], type, stage,
        i, x, y, ptr, ret, value;
    ie(open_file(font_file, stream)) do
        stream_buffer_init(buffer, 512);
        stage := 0;
        type := 0;
        ret := 0;
        while(stream_readln(stream, buffer, tmp, 256)) do
            ie(str_equal(tmp, "END")) do
                leave;
            end
            else ie(stage = 0) do ! Detect type
                ie(str_equal(tmp, "FONTBASE")) do
                    stage := 1;
                    type := 1;
                end
                else ie(str_equal(tmp, "FONTUTF8")) do
                    stage := 1;
                    type := 2;
                end
                else ie(str_equal(tmp, "FONTCUSTOM")) do
                    stage := 1;
                    type := 3;
                end
                else return 0;
            end
            else ie(stage = 1) do ! Read width
                x := str_to_num(tmp);
                stage := 2;
                if(x \= 8) return 0;
            end
            else ie(stage = 2) do ! Read height
                y := str_to_num(tmp);
                stage := 3;
                if((y < 6) | (y > 32)) return 0;
            end
            else ie(type = 1) do ! Read FONTBASE
                ie(stage = 3) do ! Read Position
                    ptr := str_to_hex(tmp) * y;
                    if(ptr > 4096) return 0;
                    stage := 4;
                    i := 0;
                end
                else ie(stage = 4) do ! Read Character line
                    value := str_to_binary(tmp);
                    Font8x8::ptr := value;
                    i := i + 1;
                    if(i = y) stage := 3;
                end
                else return 0;
            end
            else return 0;
        end
        stream_close(stream);
        return ret;
    end
    else do
        return 0;
    end
end

splash_screen() do
    var buffer::512, tmp::256, stream[OBJ_STREAM];
    ie(open_file("/System/Splash.txt", stream)) do
        stream_buffer_init(buffer, 512);
        while(stream_readln(stream, buffer, tmp, 256)) do
            term_writefln(tmp);
        end
        stream_close(stream);
    end
    else do
        term_kwriteln("\eb00\ec\ef04SPLASHSCREEN NOT FOUND\ef07");
    end
end

progress(perc, text) do
    var txt::20;
    if(perc > 100) perc := 100;
    if(perc < 0) perc := 0;
    term_writes("\ex15\ey");
    str_from_num_fixed(txt, 2, term_get_height() - 5);
    term_writes(txt);
    str_from_num_fixed(txt, 2, perc >> 1);
    term_writes("\ef03\eR");
    term_writes(txt);
    term_writes("FE");
    str_from_num_fixed(txt, 2, 50 - (perc >> 1));
    term_writes("\ef07\eR");
    term_writes(txt);
    term_writes("FE");
    term_writes("\n\ex15");
    str_from_num_fixed(txt, 2, (50 - str_len(text)) / 2);
    term_writes("\eb00\ef07\er");
    term_writes(txt);
    term_writes(" ");
    term_writes(text);
end

do
    var i;
    term_init();
    term_cls();
    husis_int_set(Int81Old, 0x81, @int81);
    splash_screen();
    progress(10, "Loading Fonts");
    load_font("/System/Default.fon");
    video_set_font8x8(Font8x8);
    progress(20, "Loading User Interface");
    i := 0;
    while(TRUE) do
        io_print("\r");
        io_printnum(i);
        i := i + 1;
    end
end