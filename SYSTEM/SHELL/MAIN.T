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