! ==========================================================================
! Terminal I/O
! ==========================================================================
struct COLORS = BLACK, DARK_BLUE, DARK_GREEN, DARK_CYAN, DARK_RED,
                DARK_MAGENTA, BROWN, DARK_GRAY, LIGHT_GRAY,
                LIGHT_BLUE, LIGHT_GREEN, LIGHT_CYAN, LIGHT_RED, LIGHT_MAGENTA, 
                LIGHT_YELLOW, WHITE;


term_write_char(c) do
! Write char to screen
    t.int86ax(0x10, 0xe00 | c,0,0,0 ,0,0);
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

term_kwrites(orig) 
! Write string on screen
    term_kwrite(orig, rstr_len(t.local(),orig));

term_writeln(orig) do
! Write string on screen
    term_writes(orig);
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

term_init() do
end
