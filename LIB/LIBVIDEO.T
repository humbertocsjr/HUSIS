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
