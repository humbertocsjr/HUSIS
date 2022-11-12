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