
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

! IMPORT ..\LIB\LIBBASE.T
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

! IMPORT ..\LIB\LIBUI.T
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
    
struct OBJ_UITYPE = 
    UITYPE_SEG,
    UITYPE_RENDER_PTR,
    UITYPE_FOCUS_PTR,
    UITYPE_KEYBOARD_PTR,
    UITYPE_MOUSE_PTR;

uitype_window(uitype) t.int86ax(0x81, 400,uitype,0,0, 0,0);
uitype_label(uitype) t.int86ax(0x81, 401,uitype,0,0, 0,0);

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

! IMPORT ..\LIB\LIBSTR.T
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

! IMPORT ..\LIB\LIBIO.T
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

! IMPORT ..\LIB\LIBFONT.T
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

! IMPORT FILEMAN\MAIN.T
! File Manager
! Humberto Costa dos Santos Junior, 2022
! 3-Clause BSD license
! File Manager Application

var Font[OBJ_FONT];

do
end