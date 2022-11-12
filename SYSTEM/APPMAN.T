
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

!#IMPORT APPMAN\MAIN.T
! Application Manager
! Humberto Costa dos Santos Junior, 2022
! 3-Clause BSD license
! Cooperative multitask manager

var WindowType[OBJ_UITYPE], 
    LabelType[OBJ_UITYPE],
    TextBoxType[OBJ_UITYPE];

var MainWindow[OBJ_CONTROL],
    CounterLabel[OBJ_CONTROL],
    CounterTxt::30,
    VersionLabel[OBJ_CONTROL],
    VersionTxt::30,
    TestTextBox[OBJ_CONTROL],
    TestTxt::30;


initialize_types() do
    ! Import control types
    uitype_window(WindowType);
    uitype_label(LabelType);
    uitype_textbox(TextBoxType);
end


do
    var i, number::11;

    ! Import and initialize types
    initialize_types();

    ! Renderize Screen
    ui_render(SCREEN_CONTROL);

    ! Create main window
    ui_new(MainWindow, WindowType);
    MainWindow[CONTROL_X] := 5;
    MainWindow[CONTROL_Y] := 5;
    MainWindow[CONTROL_WIDTH] := 35;
    MainWindow[CONTROL_HEIGHT] := 10;
    MainWindow[CONTROL_CONTENT_PTR] := "Window Test"; ! Content = Title

    ! Attach main window to screen
    ui_attach_window(MainWindow);

    ! Create Label
    ui_new(CounterLabel, LabelType);
    CounterLabel[CONTROL_X] := 2;
    CounterLabel[CONTROL_Y] := 4;
    CounterLabel[CONTROL_WIDTH] := 20;
    CounterLabel[CONTROL_HEIGHT] := 1;
    str_copy(CounterTxt, "Test");
    CounterLabel[CONTROL_CONTENT_PTR] := CounterTxt; ! Content = Text

    ! Attach label to window
    ui_attach(CounterLabel, MainWindow);

    ! Create Label
    ui_new(VersionLabel, LabelType);
    VersionLabel[CONTROL_X] := 2;
    VersionLabel[CONTROL_Y] := 3;
    VersionLabel[CONTROL_WIDTH] := 20;
    VersionLabel[CONTROL_HEIGHT] := 1;
    str_copy(VersionTxt, "HUSIS v");
    str_from_num_fixed(number, 4, husis_get_version());
    str_concat(VersionTxt, number);
    str_concat(VersionTxt, ".");
    str_from_num_fixed(number, 2, husis_get_sub_version());
    str_concat(VersionTxt, number);
    str_concat(VersionTxt, " R");
    str_from_num_fixed(number, 2, husis_get_revision());
    str_concat(VersionTxt, number);
    VersionLabel[CONTROL_CONTENT_PTR] := VersionTxt; ! Content = Text

    ! Attach label to window
    ui_attach(VersionLabel, MainWindow);

    ! Create textbox
    ui_new(TestTextBox, TextBoxType);
    TestTextBox[CONTROL_X] := 2;
    TestTextBox[CONTROL_Y] := 6;
    TestTextBox[CONTROL_WIDTH] := 20;
    TestTextBox[CONTROL_HEIGHT] := 1;
    str_copy(TestTxt, "ABX");
    TestTextBox[CONTROL_CONTENT_PTR] := TestTxt; ! Content = Text
    TestTextBox[TEXTBOX_LEN] := 30;

    ! Attach textbox to window
    ui_attach(TestTextBox, MainWindow);

    ! Show Main Window
    ui_show(MainWindow);
    while(TRUE) do
        ! Update Counter
        str_copy(CounterTxt, "Counter: ");
        str_from_num_fixed(number, 6, i);
        str_concat(CounterTxt, number);
        ! Render counter
        ui_render(CounterLabel);
        i := i + 1;
    end
end