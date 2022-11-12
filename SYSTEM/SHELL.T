
! DONT EDIT THIS FILE
! DONT EDIT THIS FILE
! DONT EDIT THIS FILE
! DONT EDIT THIS FILE
! DONT EDIT THIS FILE
! DONT EDIT THIS FILE
! DONT EDIT THIS FILE
! DONT EDIT THIS FILE
! DONT EDIT THIS FILE
! DONT EDIT THIS FILE
! DONT EDIT THIS FILE
! DONT EDIT THIS FILE
! DONT EDIT THIS FILE
! DONT EDIT THIS FILE
! DONT EDIT THIS FILE
! DONT EDIT THIS FILE

!#IMPORT ..\LIB\LIBBASE.T
! HUSIS Library
! Humberto Costa dos Santos Junior, 2022
! License: 0BSD or Public Domain

const TRUE = %1;
const FALSE = 0;


struct COLORS = BLACK, DARK_BLUE, DARK_GREEN, DARK_CYAN, DARK_RED,
                DARK_MAGENTA, BROWN, LIGHT_GRAY, DARK_GRAY,
                LIGHT_BLUE, LIGHT_GREEN, LIGHT_CYAN, LIGHT_RED, LIGHT_MAGENTA, 
                LIGHT_YELLOW, WHITE;
! DONT EDIT THIS FILE
! DONT EDIT THIS FILE
! DONT EDIT THIS FILE
! DONT EDIT THIS FILE
! DONT EDIT THIS FILE
! DONT EDIT THIS FILE
! DONT EDIT THIS FILE
! DONT EDIT THIS FILE
! DONT EDIT THIS FILE
! DONT EDIT THIS FILE
! DONT EDIT THIS FILE
! DONT EDIT THIS FILE
! DONT EDIT THIS FILE
! DONT EDIT THIS FILE
! DONT EDIT THIS FILE
! DONT EDIT THIS FILE

!#IMPORT ..\LIB\LIBHUSIS.T
! HUSIS Library
! Humberto Costa dos Santos Junior, 2022
! License: 0BSD or Public Domain

! ==========================================================================
! Memory Management
! ==========================================================================

mem_calc_free_kib() return t.int86ax(0x79, 400,0,0,0, 0,0);
mem_calc_free() return t.int86ax(0x79, 401,0,0,0, 0,0);
mem_size(segment) return t.int86ax(0x79, 402,segment,0,0, 0,0);

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
! Process info
! ==========================================================================

husis_get_version() return t.int86ax(0x79, 5,0,0,0, 0,0);
husis_get_sub_version() return t.int86ax(0x79, 6,0,0,0, 0,0);
husis_get_revision() return t.int86ax(0x79, 7,0,0,0, 0,0);
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


! DONT EDIT THIS FILE
! DONT EDIT THIS FILE
! DONT EDIT THIS FILE
! DONT EDIT THIS FILE
! DONT EDIT THIS FILE
! DONT EDIT THIS FILE
! DONT EDIT THIS FILE
! DONT EDIT THIS FILE
! DONT EDIT THIS FILE
! DONT EDIT THIS FILE
! DONT EDIT THIS FILE
! DONT EDIT THIS FILE
! DONT EDIT THIS FILE
! DONT EDIT THIS FILE
! DONT EDIT THIS FILE
! DONT EDIT THIS FILE

!#IMPORT ..\LIB\LIBFONT.T
! HUSIS Library
! Humberto Costa dos Santos Junior, 2022
! License: 0BSD or Public Domain

! ==========================================================================
! Font API
! ==========================================================================

font_load_base(file_name, font) 
    return t.int86ax(0x81, 200,file_name,font,0, 0,0);
font_load_extended(file_name, font, start_ptr) 
    return t.int86ax(0x81, 201,file_name,font,start_ptr, 0,0);
font_apply_base(font) 
    t.int86ax(0x81, 202,font,0,0, 0,0);
font_apply_extended(font) 
    t.int86ax(0x81, 203,font,0,0, 0,0);
font_get_extended_start_ptr() 
    return t.int86ax(0x81, 204,0,0,0, 0,0);
font_get_extended_start_char() 
    return t.int86ax(0x81, 205,0,0,0, 0,0);

! ==========================================================================
! Base Font - Special Characteres
! ==========================================================================

const OBJ_FONT = 2048;

const FONT_FRAME_UP_LEFT = 1;
const FONT_FRAME_UP = 2;
const FONT_FRAME_UP_RIGHT = 3;
const FONT_FRAME_LEFT = 4;
const FONT_FRAME_DOWN = 5;
const FONT_FRAME_RIGHT = 6;
const FONT_FRAME_DOWN_LEFT = 7;
const FONT_FRAME_DOWN_RIGHT = 8;
const FONT_MAXIMIZE = 9;
const FONT_MINIMIZE = 10;
const FONT_CLOSE = 11;
const FONT_UP = 12;
const FONT_DOWN = 13;
const FONT_FRAME_DOWN_RIGHT_RESIZABLE = 14;
const FONT_FRAME_UP_DOWN = 15;
const FONT_FRAME_LEFT_RIGHT = 16;
const FONT_BOX_PLUS = 17;
const FONT_BOX_MINUS = 18;
const FONT_BOX = 19;
const FONT_BOX_CHECKED = 20;
const FONT_GRAY = 21;
const FONT_MENU = 22;
const FONT_HORIZONTAL_LINES = 23;
const FONT_ARROW_LEFT = 24;
const FONT_ARROW_RIGHT = 25;
const FONT_ARROW_UP = 26;
const FONT_ARROW_DOWN = 27;
const FONT_MOUSE_CURSOR = 29;
const FONT_CIRCLE = 30;
const FONT_SEARCH = 31;

! DONT EDIT THIS FILE
! DONT EDIT THIS FILE
! DONT EDIT THIS FILE
! DONT EDIT THIS FILE
! DONT EDIT THIS FILE
! DONT EDIT THIS FILE
! DONT EDIT THIS FILE
! DONT EDIT THIS FILE
! DONT EDIT THIS FILE
! DONT EDIT THIS FILE
! DONT EDIT THIS FILE
! DONT EDIT THIS FILE
! DONT EDIT THIS FILE
! DONT EDIT THIS FILE
! DONT EDIT THIS FILE
! DONT EDIT THIS FILE

!#IMPORT ..\LIB\LIBVIDEO.T
! HUSIS Library
! Humberto Costa dos Santos Junior, 2022
! License: 0BSD or Public Domain

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

! DONT EDIT THIS FILE
! DONT EDIT THIS FILE
! DONT EDIT THIS FILE
! DONT EDIT THIS FILE
! DONT EDIT THIS FILE
! DONT EDIT THIS FILE
! DONT EDIT THIS FILE
! DONT EDIT THIS FILE
! DONT EDIT THIS FILE
! DONT EDIT THIS FILE
! DONT EDIT THIS FILE
! DONT EDIT THIS FILE
! DONT EDIT THIS FILE
! DONT EDIT THIS FILE
! DONT EDIT THIS FILE
! DONT EDIT THIS FILE

!#IMPORT ..\LIB\LIBSTR.T
! HUSIS Library
! Humberto Costa dos Santos Junior, 2022
! License: 0BSD or Public Domain

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

str_from_hex_fixed(str, len, num) do
! Convert number to string
    var i, j;
    i := len;
    for(j=0,len) do
        str::j := '0';
        str::(j+1) := 0;
    end
    for(j=0,i) do
        ie((num & 0xf)  < 10)
            str::(i-j-1) := (num & 0xf) + '0';
        else
            str::(i-j-1) := (num & 0xf) + 'A' - 10;
        num := num >> 4;
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
        ret := (ret << 4) + (c - '0');
        ret := str_to_hex2(@str::1, ret);
    end
    else ie((c >= 'a') &(c <= 'f')) do
        ret := (ret << 4) + (c - 'a' + 10);
        ret := str_to_hex2(@str::1, ret);
    end
    else if((c >= 'A') &(c <= 'F')) do
        ret := (ret << 4) + (c - 'A' + 10);
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
    else if(c = '1') do
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

! DONT EDIT THIS FILE
! DONT EDIT THIS FILE
! DONT EDIT THIS FILE
! DONT EDIT THIS FILE
! DONT EDIT THIS FILE
! DONT EDIT THIS FILE
! DONT EDIT THIS FILE
! DONT EDIT THIS FILE
! DONT EDIT THIS FILE
! DONT EDIT THIS FILE
! DONT EDIT THIS FILE
! DONT EDIT THIS FILE
! DONT EDIT THIS FILE
! DONT EDIT THIS FILE
! DONT EDIT THIS FILE
! DONT EDIT THIS FILE

!#IMPORT ..\LIB\LIBIO.T
! HUSIS Library
! Humberto Costa dos Santos Junior, 2022
! License: 0BSD or Public Domain

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

const BUFFER_SIZE = 1030;

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

! DONT EDIT THIS FILE
! DONT EDIT THIS FILE
! DONT EDIT THIS FILE
! DONT EDIT THIS FILE
! DONT EDIT THIS FILE
! DONT EDIT THIS FILE
! DONT EDIT THIS FILE
! DONT EDIT THIS FILE
! DONT EDIT THIS FILE
! DONT EDIT THIS FILE
! DONT EDIT THIS FILE
! DONT EDIT THIS FILE
! DONT EDIT THIS FILE
! DONT EDIT THIS FILE
! DONT EDIT THIS FILE
! DONT EDIT THIS FILE

!#IMPORT ..\LIB\LIBUI.T
! HUSIS Library
! Humberto Costa dos Santos Junior, 2022
! License: 0BSD or Public Domain

! ==========================================================================
! User Interface API
! ==========================================================================


const SCREEN_CONTROL = 0;

ui_new(control, uitype) t.int86ax(0x81, 300,control,uitype,0, 0,0);
ui_render(control) t.int86ax(0x81, 301,control,0,0, 0,0);
ui_destroy(control) t.int86ax(0x81, 302,control,0,0, 0,0);
ui_attach(control, parent) t.int86ax(0x81, 303,control,parent,0, 0,0);
ui_attach_window(control) t.int86ax(0x81, 304,control,0,0, 0,0);
ui_show(control) t.int86ax(0x81, 305,control,0,0, 0,0);
ui_hide(control) t.int86ax(0x81, 306,control,0,0, 0,0);

ui_new_uitype(uitype,ptr_render,ptr_focus,ptr_key,ptr_mouse)
    t.int86ax(0x81, 307,uitype,ptr_render,ptr_focus, ptr_key,ptr_mouse);

! ==========================================================================
! User Interface UIType API
! ==========================================================================


struct OBJ_CONTROL =  
    CONTROL_SEG,
    CONTROL_WINDOW_PTR,
    CONTROL_PARENT_PTR,
    CONTROL_TYPE_SEG,
    CONTROL_TYPE_PTR,
    CONTROL_TYPE_RENDER_PTR,
    CONTROL_TYPE_MOUSE_PTR,
    CONTROL_TYPE_KEYBOARD_PTR,
    CONTROL_TYPE_FOCUS_PTR,
    CONTROL_FOCUS,
    CONTROL_SHOW,
    CONTROL_CASCADE_HIDE,
    CONTROL_NEXT_PTR,
    CONTROL_CHILD_PTR,
    CONTROL_CONTENT_PTR,
    CONTROL_CONTENT_AUX_PTR,
    CONTROL_VALUE_1,
    CONTROL_VALUE_2,
    CONTROL_VALUE_3,
    CONTROL_VALUE_4,
    CONTROL_ACTION_PTR,
    CONTROL_ACTION_AUX_PTR,
    CONTROL_ACTION_ENTER_PTR,
    CONTROL_ACTION_EXIT_PTR,
    CONTROL_X,
    CONTROL_Y,
    CONTROL_WIDTH,
    CONTROL_HEIGHT,
    CONTROL_MARGIN_X,
    CONTROL_MARGIN_Y,
    CONTROL_MARGIN_WIDTH,
    CONTROL_MARGIN_HEIGHT,
    CONTROL_CALC_X,
    CONTROL_CALC_Y,
    CONTROL_CALC_WIDTH,
    CONTROL_CALC_HEIGHT;

const TEXTBOX_CURSOR_X = CONTROL_VALUE_1;
const TEXTBOX_POSITION = CONTROL_VALUE_2;
const TEXTBOX_LEN = CONTROL_VALUE_3;

struct OBJ_UITYPE = 
    UITYPE_SEG,
    UITYPE_RENDER_PTR,
    UITYPE_FOCUS_PTR,
    UITYPE_KEYBOARD_PTR,
    UITYPE_MOUSE_PTR;

uitype_window(uitype) t.int86ax(0x81, 400,uitype,0,0, 0,0);
uitype_label(uitype) t.int86ax(0x81, 401,uitype,0,0, 0,0);
uitype_textbox(uitype) t.int86ax(0x81, 402,uitype,0,0, 0,0);

! DONT EDIT THIS FILE
! DONT EDIT THIS FILE
! DONT EDIT THIS FILE
! DONT EDIT THIS FILE
! DONT EDIT THIS FILE
! DONT EDIT THIS FILE
! DONT EDIT THIS FILE
! DONT EDIT THIS FILE
! DONT EDIT THIS FILE
! DONT EDIT THIS FILE
! DONT EDIT THIS FILE
! DONT EDIT THIS FILE
! DONT EDIT THIS FILE
! DONT EDIT THIS FILE
! DONT EDIT THIS FILE
! DONT EDIT THIS FILE

!#IMPORT SHELL\BASE.T
! Text Shell for HUSIS
! Humberto Costa dos Santos Junior, 2022
! 3-Clause BSD license
! Text user interface for HUSIS


const VERSION = 0;
const SUB_VERSION = 1;
const REVISION = 0;
! DONT EDIT THIS FILE
! DONT EDIT THIS FILE
! DONT EDIT THIS FILE
! DONT EDIT THIS FILE
! DONT EDIT THIS FILE
! DONT EDIT THIS FILE
! DONT EDIT THIS FILE
! DONT EDIT THIS FILE
! DONT EDIT THIS FILE
! DONT EDIT THIS FILE
! DONT EDIT THIS FILE
! DONT EDIT THIS FILE
! DONT EDIT THIS FILE
! DONT EDIT THIS FILE
! DONT EDIT THIS FILE
! DONT EDIT THIS FILE

!#IMPORT SHELL\TERM.T
! ==========================================================================
! Terminal I/O
! ==========================================================================



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
        @TermColors)|' ', t.fargetw(t.local(), @TermWidth)*(t.fargetw(t.local(), @TermHeight)));
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

term_change_color(x, y, foreground, background) do
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
    t.farsetb(
            t.fargetw(t.local(), @TermSeg), 
            ((y * 80 + x) << 1) + 1, 
            (background << 4) | (foreground));
end

term_change_char(x, y, c) do
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
    t.farsetb(
            t.fargetw(t.local(), @TermSeg), 
            ((y * 80 + x) << 1), 
            c);
end

term_get_char(x, y) do
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
    return t.fargetb(
                    t.fargetw(t.local(), @TermSeg), 
                    ((y * 80 + x) << 1)
                    );
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
! \ed       = Force draw special character
! \el       = Clear current line and set x = 0
! \ex00     = Set X position (00-80)
! \ey00     = Set Y position (00-25)
! \ef00     = Set fore color (00-15)
! \eb00     = Set back color (00-15)
! \er00C    = Repeat C character 00 times (00-99)
! \eR00HH   = Repeat HH(Hex) character 00 times (00-FF)
!
    var i, y, cmd, cmd_pos, value_a, value_b, utf_pos, utf_0, utf_1, utf_2, utf_3, force;
    force := FALSE;
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
            else ie(c = 'd') cmd_pos := 2;
            else ie(c = 'b') cmd_pos := 2;
            else ie(c = 'x') cmd_pos := 2;
            else ie(c = 'y') cmd_pos := 2;
            else ie(c = 'r') cmd_pos := 2;
            else ie(c = 'R') cmd_pos := 2;
            else cmd_pos := 0;
            t.farsetw(t.local(), @TermCmdPos, cmd_pos);
        end
        else ie(cmd_pos = 2) do
            ie(cmd = 'd') do
                cmd_pos := 0;
                force := TRUE;
            end
            else do
                cmd_pos := 3;
                if(\char_is_num(c)) cmd_pos := 0;
                value_a := (c - '0') * 10;
                t.farsetw(t.local(), @TermCmdPos, cmd_pos);
            end
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
        if(force = FALSE) return;
    end
    if(force = FALSE) do
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
                    ie((c = 0x81) | (c = 0xa1)) c := 0x61;
                    else ie((c = 0x80) | (c = 0xa0)) c := 0x62;
                    else ie((c = 0x82) | (c = 0xa2)) c := 0x63;
                    else ie((c = 0x85) | (c = 0xa5)) c := 0x64;
                    else ie((c = 0x83) | (c = 0xa3)) c := 0x65;
                    else ie((c = 0x84) | (c = 0xa4)) c := 0x66;
                    else ie((c = 0x89) | (c = 0xa9)) c := 0x67;
                    else ie((c = 0x88) | (c = 0xa8)) c := 0x68;
                    else ie((c = 0x9c) | (c = 0xbc)) c := 0x69;
                    else ie((c = 0x8a) | (c = 0xaa)) c := 0x6a;
                    else ie((c = 0x87) | (c = 0xa7)) c := 0x6b;
                    else ie((c = 0x91) | (c = 0xb1)) c := 0x6c;
                    else ie((c = 0x86) | (c = 0xa6)) c := 0x6d;
                    else ie((c = 0x8d) | (c = 0xad)) c := 0x6e;
                    else ie((c = 0x8c) | (c = 0xac)) c := 0x6f;
                    else ie((c = 0x8f) | (c = 0xaf)) c := 0x70;
                    else ie((c = 0x8e) | (c = 0xae)) c := 0x71;
                    else ie((c = 0x93) | (c = 0xb3)) c := 0x72;
                    else ie((c = 0x92) | (c = 0xb2)) c := 0x73;
                    else ie((c = 0x94) | (c = 0xb4)) c := 0x74;
                    else ie((c = 0x96) | (c = 0xb6)) c := 0x75;
                    else ie((c = 0x95) | (c = 0xb5)) c := 0x76;
                    else ie((c = 0x98) | (c = 0xb8)) c := 0x77;
                    else ie((c = 0x9a) | (c = 0xba)) c := 0x78;
                    else ie((c = 0x99) | (c = 0xb9)) c := 0x79;
                    else ie((c = 0x9f) | (c = 0xbf)) c := 0x7f;
                    else ie((c = 0x81) | (c = 0xa1)) c := 0x1d;
                    else c := '?';
                end
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

term_write_char_force(c) do
    term_write_char('\e');
    term_write_char('d');
    term_write_char(c);
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
! DONT EDIT THIS FILE
! DONT EDIT THIS FILE
! DONT EDIT THIS FILE
! DONT EDIT THIS FILE
! DONT EDIT THIS FILE
! DONT EDIT THIS FILE
! DONT EDIT THIS FILE
! DONT EDIT THIS FILE
! DONT EDIT THIS FILE
! DONT EDIT THIS FILE
! DONT EDIT THIS FILE
! DONT EDIT THIS FILE
! DONT EDIT THIS FILE
! DONT EDIT THIS FILE
! DONT EDIT THIS FILE
! DONT EDIT THIS FILE

!#IMPORT SHELL\FONT.T
! ==========================================================================
! Font Manipulation
! ==========================================================================


var Font8x8::4096;

load_font(font_file, font_dest, start)do
    var buffer::BUFFER_SIZE, tmp::128, stream[OBJ_STREAM], type, stage,
        i, x, y, ptr, value, count;
    ie(open_file(font_file, stream)) do
        stream_buffer_init(buffer, BUFFER_SIZE);
        stage := 0;
        type := 0;
        count := 0;
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
                    ptr := str_to_hex(tmp) * y + start;
                    if(ptr > 4096) return 0;
                    stage := 4;
                    i := 0;
                end
                else ie(stage = 4) do ! Read Character line
                    value := str_to_binary(tmp);
                    font_dest::ptr := value;
                    ptr := ptr + 1;
                    i := i + 1;
                    if(i = y) stage := 3;
                end
                else return 0;
            end
            else return 0;
        end
        stream_close(stream);
        return ptr + 1;
    end
    else do
        return 0;
    end
end
! DONT EDIT THIS FILE
! DONT EDIT THIS FILE
! DONT EDIT THIS FILE
! DONT EDIT THIS FILE
! DONT EDIT THIS FILE
! DONT EDIT THIS FILE
! DONT EDIT THIS FILE
! DONT EDIT THIS FILE
! DONT EDIT THIS FILE
! DONT EDIT THIS FILE
! DONT EDIT THIS FILE
! DONT EDIT THIS FILE
! DONT EDIT THIS FILE
! DONT EDIT THIS FILE
! DONT EDIT THIS FILE
! DONT EDIT THIS FILE

!#IMPORT SHELL\UI.T
! ==========================================================================
! User Interface
! ==========================================================================

var ThemeControl, ThemeText, ThemeWindowBorder, ThemeWindowTitleBack,
    ThemeWindowTitleText, ThemeScreenBack, ThemeScreenText, 
    ThemeWindowClose, ThemeWindowMaximize, ThemeWindowMinimize,
    ThemeWindowButtonDisable, ThemeEditorBack, ThemeEditorText;

const WINDOW_CAPACITY = 32;

var WindowList[WINDOW_CAPACITY];

interface_new_control(control, uitype) do
    control[CONTROL_SEG] := t.stack();
    control[CONTROL_PARENT_PTR] := -1;
    control[CONTROL_WINDOW_PTR] := control;
    control[CONTROL_TYPE_SEG] := uitype[UITYPE_SEG];
    control[CONTROL_TYPE_PTR] := uitype;
    control[CONTROL_TYPE_RENDER_PTR] := uitype[UITYPE_RENDER_PTR];
    control[CONTROL_TYPE_MOUSE_PTR] := uitype[UITYPE_MOUSE_PTR];
    control[CONTROL_TYPE_KEYBOARD_PTR] := uitype[UITYPE_KEYBOARD_PTR];
    control[CONTROL_TYPE_FOCUS_PTR] := uitype[UITYPE_FOCUS_PTR];
    control[CONTROL_SHOW] := FALSE;
    control[CONTROL_CASCADE_HIDE] := FALSE;
    control[CONTROL_NEXT_PTR] := 0;
    control[CONTROL_CHILD_PTR] := 0;
    control[CONTROL_CONTENT_PTR] := 0;
    control[CONTROL_CONTENT_AUX_PTR] := 0;
    control[CONTROL_VALUE_1] := 0;
    control[CONTROL_VALUE_2] := 0;
    control[CONTROL_VALUE_3] := 0;
    control[CONTROL_VALUE_4] := 0;
    control[CONTROL_ACTION_PTR] := 0;
    control[CONTROL_ACTION_AUX_PTR] := 0;
    control[CONTROL_ACTION_ENTER_PTR] := 0;
    control[CONTROL_ACTION_EXIT_PTR] := 0;
    control[CONTROL_X] := 0;
    control[CONTROL_Y] := 0;
    control[CONTROL_WIDTH] := 0;
    control[CONTROL_HEIGHT] := 0;
    control[CONTROL_MARGIN_X] := 0;
    control[CONTROL_MARGIN_Y] := 0;
    control[CONTROL_MARGIN_WIDTH] := 0;
    control[CONTROL_MARGIN_HEIGHT] := 0;
    control[CONTROL_CALC_X] := 0;
    control[CONTROL_CALC_Y] := 0;
    control[CONTROL_CALC_WIDTH] := 0;
    control[CONTROL_CALC_HEIGHT] := 0;
end

interface_render(control) do
    var ptr::T3X.PTRSIZE, i, win_ptr;
    if(control = -1) return;
    if(control[CONTROL_PARENT_PTR] = -1) return;
    if(control = SCREEN_CONTROL) do
        term_color_fore(t.fargetw(t.local(), @ThemeScreenText));
        term_color_back(t.fargetw(t.local(), @ThemeScreenBack));
        term_cls();
        win_ptr := t.fargetw(t.local(), @WindowList);
        for(i = 0, WINDOW_CAPACITY) do
            if(t.fargetw(t.local(), win_ptr + (i << 1)) \= 0) do
                if
                (
                    t.fargetw(t.local(), 
                        t.fargetw(t.local(), win_ptr + (i << 1)) + 
                        CONTROL_SHOW
                    )
                )
                interface_render(t.fargetw(t.local(), win_ptr + (i << 1)));
            end
        end
        return;
    end
    if(control[CONTROL_WINDOW_PTR][CONTROL_FOCUS]) return;
    if(control[CONTROL_TYPE_SEG] = 0) return;
    if(control[CONTROL_TYPE_RENDER_PTR] = 0) return;
    ie(control[CONTROL_PARENT_PTR] = SCREEN_CONTROL) do
        control[CONTROL_CALC_X] := control[CONTROL_X];
        control[CONTROL_CALC_Y] := control[CONTROL_Y];
        control[CONTROL_CALC_WIDTH] := control[CONTROL_WIDTH];
        control[CONTROL_CALC_HEIGHT] := control[CONTROL_HEIGHT];
    end
    else do 
        if(control[CONTROL_PARENT_PTR][CONTROL_SHOW] = FALSE) return;
        if(control[CONTROL_PARENT_PTR][CONTROL_CASCADE_HIDE]) return;
    end
    t.setptr(ptr, control[CONTROL_TYPE_SEG], control[CONTROL_TYPE_RENDER_PTR]);
    callfar ptr(control);
end

interface_calc_child(control) do
    var parent;
    if(control[CONTROL_PARENT_PTR] = SCREEN_CONTROL) do
        control[CONTROL_CALC_X] := control[CONTROL_X];
        control[CONTROL_CALC_Y] := control[CONTROL_Y];
        control[CONTROL_CALC_WIDTH] := control[CONTROL_WIDTH];
        control[CONTROL_CALC_HEIGHT] := control[CONTROL_HEIGHT];
        return TRUE;
    end
    if(control[CONTROL_SHOW] = FALSE) return FALSE;
    parent := control[CONTROL_PARENT_PTR];
    control[CONTROL_CALC_X] := control[CONTROL_X] + parent[CONTROL_CALC_X] + parent[CONTROL_MARGIN_X];
    control[CONTROL_CALC_Y] := control[CONTROL_Y] + parent[CONTROL_CALC_Y] + parent[CONTROL_MARGIN_X];
    control[CONTROL_CALC_WIDTH] := control[CONTROL_WIDTH];
    control[CONTROL_CALC_HEIGHT] := control[CONTROL_HEIGHT];
    if((control[CONTROL_X] + parent[CONTROL_MARGIN_X] + control[CONTROL_CALC_WIDTH]) >= (parent[CONTROL_CALC_WIDTH] - parent[CONTROL_MARGIN_WIDTH])) do
        control[CONTROL_CALC_WIDTH] := parent[CONTROL_CALC_WIDTH] - parent[CONTROL_MARGIN_WIDTH] - parent[CONTROL_MARGIN_X] - control[CONTROL_X];
    end
    if((control[CONTROL_Y] + control[CONTROL_CALC_HEIGHT]) >= (parent[CONTROL_CALC_HEIGHT] - parent[CONTROL_MARGIN_HEIGHT])) do
        control[CONTROL_CALC_HEIGHT] := parent[CONTROL_CALC_HEIGHT] - parent[CONTROL_MARGIN_HEIGHT] - parent[CONTROL_MARGIN_Y] - control[CONTROL_Y];
    end
    return TRUE;
end

interface_calc_all(parent) do
    var child;
    child := parent[CONTROL_CHILD_PTR];
    while(child \= 0) do
        interface_calc_child(child);
        child := child[CONTROL_NEXT_PTR];
    end
end

interface_render_child(control) do
    if(interface_calc_child(control))
        interface_render(control);
end

interface_render_all(parent) do
    var child;
    child := parent[CONTROL_CHILD_PTR];
    while(child \= 0) do
        interface_render_child(child);
        child := child[CONTROL_NEXT_PTR];
    end
end

interface_destroy(control) do
    var current, i, win_ptr;
    control[CONTROL_SHOW] := FALSE;
    interface_render(control[CONTROL_PARENT_PTR]);
    ie(control[CONTROL_PARENT_PTR] = SCREEN_CONTROL) do
        win_ptr := t.fargetw(t.local(), @WindowList);
        for(i = 0, WINDOW_CAPACITY) do
            if(t.fargetw(t.local(), win_ptr + (i << 1)) = control) 
                t.farsetw(t.local(), win_ptr + (i << 1), 0);
        end
    end
    else do
        if(control[CONTROL_PARENT_PTR][CONTROL_CHILD_PTR] = control) do
            control[CONTROL_PARENT_PTR][CONTROL_CHILD_PTR] := control[CONTROL_NEXT_PTR];
            return;
        end
        current := control[CONTROL_PARENT_PTR][CONTROL_CHILD_PTR];
        while(current[CONTROL_NEXT_PTR] \= 0) do
            if(current[CONTROL_NEXT_PTR] = control) do
                current[CONTROL_NEXT_PTR] := control[CONTROL_NEXT_PTR];
                leave;
            end
            current := current[CONTROL_NEXT_PTR];
        end
    end
end

interface_attach(control, parent) do
    var current;
    control[CONTROL_SHOW] := TRUE;
    control[CONTROL_PARENT_PTR] := parent;
    ie(parent[CONTROL_CHILD_PTR] = 0) do
        parent[CONTROL_CHILD_PTR] := control;
        control[CONTROL_WINDOW_PTR] := parent[CONTROL_WINDOW_PTR];
    end
    else do
        current := parent[CONTROL_CHILD_PTR];
        while(current[CONTROL_NEXT_PTR] \= 0) do
            current := current[CONTROL_NEXT_PTR];
        end
        current[CONTROL_NEXT_PTR] := control;
        control[CONTROL_WINDOW_PTR] := parent[CONTROL_WINDOW_PTR];
    end
end

interface_attach_window(control) do
    var i, win_ptr, window;
    win_ptr := t.fargetw(t.local(), @WindowList);
    control[CONTROL_PARENT_PTR] := SCREEN_CONTROL;
    control[CONTROL_WINDOW_PTR] := control;
    for(i = 0, WINDOW_CAPACITY) do
        window := t.fargetw(t.local(), win_ptr + (i << 1));
        window[CONTROL_FOCUS] := FALSE;
        if(t.fargetw(t.local(), win_ptr + (i << 1)) = 0) do
            t.farsetw(t.local(), win_ptr + (i << 1), control);
            window[CONTROL_FOCUS] := TRUE;
        end
    end
end

interface_cascade(control, show) do
    var child;
    control[CONTROL_CASCADE_HIDE] := \show;
    child := control[CONTROL_CHILD_PTR];
    while(child \= 0) do
        child[CONTROL_CASCADE_HIDE] := \show;
        if(child[CONTROL_CHILD_PTR] \= 0)
            interface_cascade(control, show);
        child := child[CONTROL_NEXT_PTR];
    end
end

interface_show(control) do
    if(control \= SCREEN_CONTROL) do
        control[CONTROL_SHOW] := TRUE;
        interface_cascade(control, TRUE);
    end
    interface_render(control);
end

interface_hide(control) do
    if(control \= SCREEN_CONTROL) do
        control[CONTROL_SHOW] := FALSE;
        interface_cascade(control, FALSE);
    end
    interface_render(control[CONTROL_PARENT_PTR]);
end

interface_new_uitype(uitype, seg, ptr_render, ptr_focus, ptr_key, ptr_mouse) do
    uitype[UITYPE_SEG] := seg;
    uitype[UITYPE_RENDER_PTR] := ptr_render;
    uitype[UITYPE_FOCUS_PTR] := ptr_focus;
    uitype[UITYPE_KEYBOARD_PTR] := ptr_key;
    uitype[UITYPE_MOUSE_PTR] := ptr_mouse;
end
! DONT EDIT THIS FILE
! DONT EDIT THIS FILE
! DONT EDIT THIS FILE
! DONT EDIT THIS FILE
! DONT EDIT THIS FILE
! DONT EDIT THIS FILE
! DONT EDIT THIS FILE
! DONT EDIT THIS FILE
! DONT EDIT THIS FILE
! DONT EDIT THIS FILE
! DONT EDIT THIS FILE
! DONT EDIT THIS FILE
! DONT EDIT THIS FILE
! DONT EDIT THIS FILE
! DONT EDIT THIS FILE
! DONT EDIT THIS FILE

!#IMPORT SHELL\CONTROLS\WINDOW.T
! ==========================================================================
! Window UIType
! ==========================================================================

window_render(control) far do
    var tmp::10, i, color_window;
    term_calc_pos(control[CONTROL_CALC_X], control[CONTROL_CALC_Y]);

    term_color_fore(t.fargetw(t.local(), @ThemeWindowTitleText));
    term_color_back(t.fargetw(t.local(), @ThemeWindowTitleBack));

    term_write_char('\e');
    term_write_char('r');
    str_from_num_fixed(tmp, 2, control[CONTROL_CALC_WIDTH] - 1);
    term_writes(tmp);
    term_write_char(FONT_HORIZONTAL_LINES);
    term_write_char_force(FONT_FRAME_LEFT);

    if(control[CONTROL_CONTENT_PTR] \= 0) do
        ie((str_len(control[CONTROL_CONTENT_PTR]) + 6) >= control[CONTROL_CALC_WIDTH]) do
            term_calc_pos(control[CONTROL_CALC_X] + 5, control[CONTROL_CALC_Y]);
            term_write(control[CONTROL_CONTENT_PTR], (control[CONTROL_CALC_WIDTH] - 6));
        end
        else do
            term_calc_pos(control[CONTROL_CALC_X] + ((control[CONTROL_CALC_WIDTH] - str_len(control[CONTROL_CONTENT_PTR])) >> 1), control[CONTROL_CALC_Y]);
            term_write(control[CONTROL_CONTENT_PTR], str_len(control[CONTROL_CONTENT_PTR]));
        end
    end

    term_calc_pos(control[CONTROL_CALC_X], control[CONTROL_CALC_Y]);
    term_color_fore(t.fargetw(t.local(), @ThemeWindowClose));
    term_write_char_force(FONT_CLOSE);
    ie(control[CONTROL_VALUE_1])
        term_color_fore(t.fargetw(t.local(), @ThemeWindowMinimize));
    else
        term_color_fore(t.fargetw(t.local(), @ThemeWindowButtonDisable));
    term_write_char_force(FONT_MINIMIZE);
    ie(control[CONTROL_VALUE_1])
        term_color_fore(t.fargetw(t.local(), @ThemeWindowMaximize));
    else
        term_color_fore(t.fargetw(t.local(), @ThemeWindowButtonDisable));
    term_write_char_force(FONT_MAXIMIZE);

    term_color_fore(t.fargetw(t.local(), @ThemeWindowTitleText));
    term_write_char_force(FONT_FRAME_RIGHT);

    term_calc_pos(control[CONTROL_CALC_X], control[CONTROL_CALC_Y]+1);

    term_color_fore(t.fargetw(t.local(), @ThemeWindowBorder));
    term_color_back(t.fargetw(t.local(), @ThemeControl));

    term_write_char(FONT_FRAME_UP_LEFT);
    term_write_char('\e');
    term_write_char('r');
    str_from_num_fixed(tmp, 2, control[CONTROL_CALC_WIDTH]-2);
    term_writes(tmp);
    term_write_char(FONT_FRAME_UP);
    term_write_char(FONT_FRAME_UP_RIGHT);
    str_from_num_fixed(tmp, 2, control[CONTROL_CALC_WIDTH]-2);
    for(i = 2, control[CONTROL_CALC_HEIGHT]-1) do
        term_calc_pos(control[CONTROL_CALC_X], control[CONTROL_CALC_Y]+i);
        term_write_char(FONT_FRAME_LEFT);
        term_write_char('\e');
        term_write_char('r');
        term_writes(tmp);
        term_write_char(' ');
        term_write_char(FONT_FRAME_RIGHT);
    end
    term_calc_pos(control[CONTROL_CALC_X], control[CONTROL_CALC_Y]+control[CONTROL_CALC_HEIGHT]-1);
    term_write_char(FONT_FRAME_DOWN_LEFT);
    term_write_char('\e');
    term_write_char('r');
    str_from_num_fixed(tmp, 2, control[CONTROL_CALC_WIDTH]-2);
    term_writes(tmp);
    term_write_char(FONT_FRAME_DOWN);
    term_write_char_force(FONT_FRAME_DOWN_RIGHT);

    control[CONTROL_MARGIN_X] := 1;
    control[CONTROL_MARGIN_Y] := 2;
    control[CONTROL_MARGIN_WIDTH] := 1;
    control[CONTROL_MARGIN_HEIGHT] := 1;
    interface_render_all(control);
end

window_focus(control, focus) far do
end

window_keyboard(control, press, ascii, scancode) far do
end

window_mouse(control, primary_click, secondary_click, scroll) far do
end

window_new(uitype) do
    interface_new_uitype
    (
        uitype, 
        t.local(), 
        @window_render,
        @window_focus,
        @window_keyboard,
        @window_mouse
    );
end
! DONT EDIT THIS FILE
! DONT EDIT THIS FILE
! DONT EDIT THIS FILE
! DONT EDIT THIS FILE
! DONT EDIT THIS FILE
! DONT EDIT THIS FILE
! DONT EDIT THIS FILE
! DONT EDIT THIS FILE
! DONT EDIT THIS FILE
! DONT EDIT THIS FILE
! DONT EDIT THIS FILE
! DONT EDIT THIS FILE
! DONT EDIT THIS FILE
! DONT EDIT THIS FILE
! DONT EDIT THIS FILE
! DONT EDIT THIS FILE

!#IMPORT SHELL\CONTROLS\LABEL.T
! ==========================================================================
! Label UIType
! ==========================================================================

label_render(control) far do
    var tmp::20;
    term_calc_pos(control[CONTROL_CALC_X], control[CONTROL_CALC_Y]);
    term_color_fore(t.fargetw(t.local(), @ThemeText));
    term_color_back(t.fargetw(t.local(), @ThemeControl));
    ie(control[CONTROL_CONTENT_PTR] = 0) do
        term_write_char('\e');
        term_write_char('r');
        str_from_num_fixed(tmp, 2, control[CONTROL_CALC_WIDTH]);
        term_writes(tmp);
        term_write_char(' ');
    end
    else do
        ie(str_len(control[CONTROL_CONTENT_PTR]) < control[CONTROL_CALC_WIDTH]) do
            term_writes(control[CONTROL_CONTENT_PTR]);
            term_write_char('\e');
            term_write_char('r');
            str_from_num_fixed(tmp, 2, control[CONTROL_CALC_WIDTH] - str_len(control[CONTROL_CONTENT_PTR]));
            term_writes(tmp);
            term_write_char(' ');
        end
        else do
            term_write(control[CONTROL_CONTENT_PTR], control[CONTROL_CALC_WIDTH]);
        end
    end
end

label_focus(control, focus) far do
end

label_keyboard(control, press, ascii, scancode) far do
end

label_mouse(control, primary_click, secondary_click, scroll) far do
end

label_new(uitype) do
    interface_new_uitype
    (
        uitype, 
        t.local(), 
        @label_render,
        @label_focus,
        @label_keyboard,
        @label_mouse
    );
end

! DONT EDIT THIS FILE
! DONT EDIT THIS FILE
! DONT EDIT THIS FILE
! DONT EDIT THIS FILE
! DONT EDIT THIS FILE
! DONT EDIT THIS FILE
! DONT EDIT THIS FILE
! DONT EDIT THIS FILE
! DONT EDIT THIS FILE
! DONT EDIT THIS FILE
! DONT EDIT THIS FILE
! DONT EDIT THIS FILE
! DONT EDIT THIS FILE
! DONT EDIT THIS FILE
! DONT EDIT THIS FILE
! DONT EDIT THIS FILE

!#IMPORT SHELL\CONTROLS\TEXTBOX.T
! ==========================================================================
! TextBox UIType
! ==========================================================================

textbox_render(control) far do
    var tmp::20;
    term_calc_pos(control[CONTROL_CALC_X], control[CONTROL_CALC_Y]);
    term_color_fore(t.fargetw(t.local(), @ThemeEditorText));
    term_color_back(t.fargetw(t.local(), @ThemeEditorBack));
    ie(control[CONTROL_CONTENT_PTR] = 0) do
        term_write_char('\e');
        term_write_char('r');
        str_from_num_fixed(tmp, 2, control[CONTROL_CALC_WIDTH]);
        term_writes(tmp);
        term_write_char(' ');
    end
    else do
        ie(str_len(control[CONTROL_CONTENT_PTR]) < control[CONTROL_CALC_WIDTH]) do
            term_writes(control[CONTROL_CONTENT_PTR]);
            term_write_char('\e');
            term_write_char('r');
            str_from_num_fixed(tmp, 2, control[CONTROL_CALC_WIDTH] - str_len(control[CONTROL_CONTENT_PTR]));
            term_writes(tmp);
            term_write_char(' ');
        end
        else do
            term_write(control[CONTROL_CONTENT_PTR], control[CONTROL_CALC_WIDTH]);
        end
    end
    if(control[TEXTBOX_CURSOR_X] >= control[CONTROL_CALC_WIDTH]) control[TEXTBOX_CURSOR_X] := control[CONTROL_CALC_WIDTH];
    term_change_color(control[CONTROL_CALC_X] + control[TEXTBOX_CURSOR_X], control[CONTROL_CALC_Y], t.fargetw(t.local(), @ThemeEditorText), t.fargetw(t.local(), @ThemeEditorBack));
end

textbox_focus(control, focus) far do
end

textbox_keyboard(control, press, ascii, scancode) far do
end

textbox_mouse(control, primary_click, secondary_click, scroll) far do
end

textbox_new(uitype) do
    interface_new_uitype
    (
        uitype, 
        t.local(), 
        @textbox_render,
        @textbox_focus,
        @textbox_keyboard,
        @textbox_mouse
    );
end

! DONT EDIT THIS FILE
! DONT EDIT THIS FILE
! DONT EDIT THIS FILE
! DONT EDIT THIS FILE
! DONT EDIT THIS FILE
! DONT EDIT THIS FILE
! DONT EDIT THIS FILE
! DONT EDIT THIS FILE
! DONT EDIT THIS FILE
! DONT EDIT THIS FILE
! DONT EDIT THIS FILE
! DONT EDIT THIS FILE
! DONT EDIT THIS FILE
! DONT EDIT THIS FILE
! DONT EDIT THIS FILE
! DONT EDIT THIS FILE

!#IMPORT SHELL\INT81.T
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
    !
    ! Font API
    !
    else ie(ax < 300) do
        ie (ax = 200) do ! Load base font to local array (LEN 4096)
            ax := load_font(bx, cx, 0);
        end
        else ie (ax = 201) do ! Load extended font to local array (LEN 4096)
            ax := load_font(bx, cx, dx);
        end
        else ie (ax = 202) do ! Implement local base font
            t.farcopy(t.local(), @Font8x8, t.stack(), bx, 2048);
        end
        else ie (ax = 203) do ! Implement local extended font
            t.farcopy(t.local(), @Font8x8 + 2048, t.stack(), bx, 2048);
        end
        else ie (ax = 204) do ! Get extended font start pointer
            ax := 2048;
        end
        else ie (ax = 205) do ! Get extended font start char
            ax := 128;
        end
        else int_debug(0x79, ax,bx,cx,dx,ds,si,es,di);
    end
    !
    ! User Interface API
    !
    else ie(ax < 400) do
        ie (ax = 300) do ! New control
            interface_new_control(bx, cx);
        end
        else ie (ax = 301) do ! Render control
            interface_render(bx);
        end
        else ie (ax = 302) do ! Destroy control
            interface_destroy(bx);
        end
        else ie (ax = 303) do ! Attach control
            interface_attach(bx, cx);
        end
        else ie (ax = 304) do ! Attach window
            interface_attach_window(bx);
        end
        else ie (ax = 305) do ! Show control
            interface_show(bx);
        end
        else ie (ax = 306) do ! Hide control
            interface_hide(bx);
        end
        else ie (ax = 307) do ! New type
            interface_new_uitype(bx,t.stack(),cx,dx,si,di);
        end
        else int_debug(0x79, ax,bx,cx,dx,ds,si,es,di);
    end
    !
    ! User Interface Type API
    !
    else ie(ax < 500) do
        ie (ax = 400) do ! New Window Type
            window_new(bx);
        end
        else ie (ax = 401) do ! New Label Type
            label_new(bx);
        end
        else ie (ax = 402) do ! New TextBox Type
            textbox_new(bx);
        end
        else int_debug(0x79, ax,bx,cx,dx,ds,si,es,di);
    end
    else int_debug(0x79, ax,bx,cx,dx,ds,si,es,di);
end
! DONT EDIT THIS FILE
! DONT EDIT THIS FILE
! DONT EDIT THIS FILE
! DONT EDIT THIS FILE
! DONT EDIT THIS FILE
! DONT EDIT THIS FILE
! DONT EDIT THIS FILE
! DONT EDIT THIS FILE
! DONT EDIT THIS FILE
! DONT EDIT THIS FILE
! DONT EDIT THIS FILE
! DONT EDIT THIS FILE
! DONT EDIT THIS FILE
! DONT EDIT THIS FILE
! DONT EDIT THIS FILE
! DONT EDIT THIS FILE

!#IMPORT SHELL\MAIN.T
! ==========================================================================
! Main
! ==========================================================================


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
    term_writes("\ex13\ey");
    str_from_num_fixed(txt, 2, term_get_height() - 5);
    term_writes(txt);
    str_from_num_fixed(txt, 2, perc >> 1);
    term_writes("\ef03[\eR");
    term_writes(txt);
    term_writes("1E");
    str_from_num_fixed(txt, 2, 50 - (perc >> 1));
    term_writes("\ef07\eR");
    term_writes(txt);
    term_writes("1E");
    term_writes("\ef03]\ef07\n\ex14");
    str_from_num_fixed(txt, 2, (50 - str_len(text)) / 2);
    term_writes("\eb00\ef07\er");
    term_writes(txt);
    term_writes(" ");
    term_writes(text);
    term_writes("\ex13\ey");
    str_from_num_fixed(txt, 2, term_get_height() - 7);
    term_writes(txt);
    term_writes("License:\ef03 3-Clause BSD\ef07");
    term_writes("\ex13\ey");
    str_from_num_fixed(txt, 2, term_get_height() - 6);
    term_writes(txt);
    term_writes("Version:\ef03 ");
    term_writenum(husis_get_version());
    term_writes(".");
    term_writenum(husis_get_sub_version());
    term_writes(" R");
    term_writenum(husis_get_revision());
    term_writes("\ef07");
end

do
    var i;
    for(i = 0, WINDOW_CAPACITY) do
        WindowList[i] := 0;
    end
    ! Set Theme Colors
    ThemeControl := LIGHT_GRAY;
    ThemeText := BLACK;
    ThemeWindowBorder := BLACK;
    ThemeWindowTitleBack := BLACK;
    ThemeWindowTitleText := LIGHT_GRAY;
    ThemeScreenBack := DARK_CYAN;
    ThemeScreenText := BLACK;
    ThemeWindowClose := LIGHT_RED;
    ThemeWindowMinimize := LIGHT_YELLOW;
    ThemeWindowMaximize := LIGHT_GREEN;
    ThemeWindowButtonDisable := LIGHT_GRAY;
    ThemeEditorBack := WHITE;
    ThemeEditorText := BLACK;
    ! Initialize Terminal
    term_init();
    term_cls();
    husis_int_set(Int81Old, 0x81, @int81);
    progress(30, "Loading Fonts");
    if(load_font("/System/Default.fon", Font8x8, 0))
        video_set_font8x8(Font8x8);
    progress(50, "Loading Splash Screen");
    splash_screen();
    progress(70, "Loading Application Manager");
    husis_exec_com("/System/AppMan.com", "");
end