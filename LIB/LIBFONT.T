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
