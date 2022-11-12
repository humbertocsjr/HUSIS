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