! ==========================================================================
! Interrupt Handlers
! ==========================================================================

var Int79Ant::T3X.PTRSIZE, IntMap::1024;

int_set(ptr_ant, seg, int, funcao) do
! Set new Interrupt Handler, store previous handler to restore
    t.setptr(ptr_ant, t.fargetw(0, int*4+2), t.fargetw(0, int*4));
    t.farsetw(0, int*4, funcao);
    t.farsetw(0, int*4+2, seg);
end

int_restore(ptr_ant, int) do
! Restore stored interrupt handler
    t.farsetw(0, int*4, t.getoff(ptr_ant));
    t.farsetw(0, int*4+2, t.getseg(ptr_ant));
end

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

int79com(address, args)do
    var stream[OBJ_STREAM];
    if(\fs_open_file(address, stream)) return %1;
    return com_exec(stream, args);
end

int79prg(address, args)do
    var stream[OBJ_STREAM];
    if(\fs_open_file(address, stream)) return %1;
    return prg_exec(stream, args);
end

int79(ax,bx,cx,dx,ds,si,es,di,ss,sp) farint do
    var proc, proc_bp, proc_cs, proc_ip, proc_sp, proc_seg, parent;
    var color;
    !
    ! 0xx Kernel API
    !
    ie(ax < 100) do
        ie(ax = 0) do ! Exit
            proc := process_get_current();
            parent := process_get_parent(proc);
            process_set_status(proc, STATUS_PROCESS_EMPTY);
            mem_free_process(proc);
            process_set_current(parent);
            proc_bp := process_get_bp(parent);
            proc_cs := process_get_cs(parent);
            proc_ip := process_get_ip(parent);
            proc_sp := process_get_sp(parent);
            proc_seg := process_get_seg(parent);
            process_set_ret(parent, bx);
            t.jmpstack(proc_seg, proc_sp, proc_bp, proc_cs, proc_ip);
        end
        else ie(ax = 1) do ! Shutdown
            term_kwrites("\ec\ef03SYSTEM HALTED.");

            ! Restore Interrupts
            t.farcopy(0,0,t.local(), t.fargetw(t.local(), @IntMap), 1024);

            if(Mode = MODE_STANDALONE) t.int86ax(0x18, 0,0,0,0 ,0,0); ! Reboot
            if(Mode = MODE_DOS_APP)t.int86ax(0x21, 0x4d00,0,0,0, 0,0); ! exit to DOS
        end
        else ie(ax = 2) do ! Exit (Keep on memory)
            proc := process_get_current();
            parent := process_get_parent(proc);
            process_set_status(proc, STATUS_PROCESS_BACKEND);
            process_set_current(parent);
            proc_bp := process_get_bp(parent);
            proc_cs := process_get_cs(parent);
            proc_ip := process_get_ip(parent);
            proc_sp := process_get_sp(parent);
            proc_seg := process_get_seg(parent);
            process_set_ret(parent, 0);
            t.jmpstack(proc_seg, proc_sp, proc_bp, proc_cs, proc_ip);
        end
        else ie(ax = 3) do ! Set new interrupt handler
            int_set(bx, cx, dx, si);
        end
        else ie(ax = 4) do ! Restore interrupt handler
            int_restore(bx, cx);
        end
        else ie(ax = 5) do ! Version
            ax := VERSION;
        end
        else ie(ax = 6) do ! Sub-Version
            ax := SUB_VERSION;
        end
        else ie(ax = 7) do ! Revision
            ax := REVISION;
        end
        else int_debug(0x79, ax,bx,cx,dx,ds,si,es,di);
    end
    !
    ! 1xx Terminal API
    !
    else ie(ax < 200) do
        ie(ax = 100) do ! Write String on Screen(bx=string | cx=len)
            term_write(bx, cx);
        end
        else ie(ax = 101) do ! Write String on Screen(bx=string)
            term_writes(bx);
        end
        else ie(ax = 102) do ! Write String on Screen(bx=string)
            term_writeln(bx);
        end
        else ie(ax = 103) do ! Write number on Screen(bx=string)
            term_writenum(bx);
        end
        else ie(ax = 104) do ! Write hex on Screen(bx=string)
            term_writehex(bx);
        end
        else ie(ax = 105) do ! New line
            term_kwriteln("");
        end
        else ie(ax = 106) do ! Write char on Screen(bx=char)
            term_write_char(bx);
        end
        else int_debug(0x79, ax,bx,cx,dx,ds,si,es,di);
    end
    !
    ! 2xx Stream I/O API
    !
    else ie(ax < 300) do
        ie(ax = 200) do ! New Stream
            ! bx=Stream
            ! ds=Seg
            ! cx=Data Avail
            ! dx=Seek
            ! si=Read
            ! di=Write
            ax := new(bx,ds,cx,dx,0,si,0,di);
        end
        else ie(ax = 201) do ! Set extra pointers
            ! bx=Stream
            ! cx=Can Read
            ! dx=Car Write
            ! si=Close
            bx[STREAM_PTR_CAN_READ] := cx;
            bx[STREAM_PTR_CAN_WRITE] := dx;
            bx[STREAM_PTR_CLOSE] := si;
        end
        else ie(ax = 202) do ! Set Buffer
            ! bx=Stream
            ! cx=Buffer Segment
            ! dx=Buffer Pointer
            ! si=Buffer Len
            buffer_set(bx, cx,dx,si);
        end
        else ie(ax = 203) do ! Seek
            ! bx=Stream
            ! cx=Position Low
            ! dx=Position High
            ax := stream_seek(bx, cx,dx);
        end
        else ie(ax = 204) do ! Close
            ! bx=Stream
            ax := stream_close(bx);
        end
        else ie(ax = 205) do ! Read
            ! bx=Stream
            ! cx=Destination
            ! dx=Len
            ax := stream_read(bx, cx, dx);
        end
        else ie(ax = 206) do ! Write
            ! bx=Stream
            ! cx=Origin
            ! dx=Len
            ax := stream_write(bx, cx, dx);
        end
        else ie(ax = 207) do ! Write
            ! bx=Stream
            ! cx=Origin
            ax := stream_writes(bx, cx);
        end
        else ie(ax = 208) do ! Write
            ! bx=Stream
            ! cx=Origin
            ax := stream_writeln(bx, cx);
        end
        else ie(ax = 209) do ! Write
            ! bx=Stream
            ! cx=Segment
            ! dx=Origin
            ! si=Len
            ax := stream_rwrite(bx, cx,dx,si);
        end
        else ie(ax = 210) do ! Write
            ! bx=Stream
            ! cx=Segment
            ! dx=Origin
            ax := stream_rwrites(bx, cx,dx);
        end
        else ie(ax = 211) do ! Write
            ! bx=Stream
            ! cx=Char
            ax := stream_write_char(bx, cx);
        end
        else ie(ax = 212) do ! Write
            ! bx=Stream
            ! cx=Number
            ax := stream_write_num(bx, cx);
        end
        else ie(ax = 213) do ! Write
            ! bx=Stream
            ! cx=Number
            ax := stream_write_hex(bx, cx);
        end
        else int_debug(0x79, ax,bx,cx,dx,ds,si,es,di);
    end
    !
    ! 3xx Process API
    !
    else ie(ax < 400) do
        ie(ax = 300) do ! Execute COM File
            ! bx = File name
            ! cx = Arguments
            ax := int79com(bx, cx);
        end
        else ie(ax = 301) do ! Execute PRG File
            ! bx = File name
            ! cx = Arguments
            ax := int79prg(bx, cx);
        end
        else ie(ax = 302) do ! Get process ID
            ax := process_get_current();
        end
        else ie(ax = 303) do ! Get status from process
            ! bx = Process
            ax := process_get_status(bx);
        end
        else ie(ax = 304) do ! Get segment from process
            ! bx = Process
            ax := process_get_seg(bx);
        end
        else ie(ax = 305) do ! Get ip from process
            ! bx = Process
            ax := process_get_ip(bx);
        end
        else ie(ax = 306) do ! Get sp from process
            ! bx = Process
            ax := process_get_sp(bx);
        end
        else ie(ax = 307) do ! Get bp from process
            ! bx = Process
            ax := process_get_bp(bx);
        end
        else ie(ax = 308) do ! Get parent from process
            ! bx = Process
            ax := process_get_parent(bx);
        end
        else ie(ax = 309) do ! Get process ID
            ax := process_get_parent(process_get_current());
        end
        else int_debug(0x79, ax,bx,cx,dx,ds,si,es,di);
    end
    !
    ! 4xx Memory Managment API
    !
    else ie(ax < 500) do
        ie(ax = 400) do ! Get free memory in KiB
            ax := mem_calc_free_kib();;
        end
        else ie(ax = 401) do ! Get free memory in Segments
            ax := mem_calc_free();;
        end
        else ie(ax = 402) do ! Get size
            ax := mem_size(bx);;
        end
        else int_debug(0x79, ax,bx,cx,dx,ds,si,es,di);
    end
    !
    ! 5xx File System API
    !
    else ie(ax < 600) do
        ie(ax = 500) do ! Register and mount file system
            ! bx = Disk
            ! ds = Segment
            ! cx = First Item Function
            ! dx = Next Item Function
!            ax := fs_reg(bx, ds, cx,dx,si);
!TODO: Adapt code to farget/farset
            ax := FALSE;
        end
        else ie(ax = 501) do ! New item
            ! bx = item
            ! ds = Segment
            ! cx = Type
            ! dx = Open Function
            ! si = Parent ID
            ! di = ID
            new_item(bx, cx, ds, dx, si, di);
        end
        else ie(ax = 502) do ! Open Item
            ! bx = Item
            ! cx = Stream
            ax := fs_open_item(bx, cx);
        end
        else ie(ax = 503) do ! Open Dir
            ! bx = Address
            ! cx = Output Item
            ax := fs_open_dir(bx, cx);
        end
        else ie(ax = 504) do ! Open File
            ! bx = Address
            ! cx = Output Item
            ax := fs_open_file(bx, cx);
        end
        else ie(ax = 505) do ! First item
            ! bx = Directory Item
            ! cx = Item
            ax := fs_first(bx[ITEM_FS], bx[ITEM_ID], cx);
        end
        else ie(ax = 506) do ! First item
            ! bx = Item
            ax := fs_next(bx[ITEM_FS], bx);
        end
        else ie(ax = 507) do ! Copy item 
            ! bx = Orig
            ! cx = Dest
            t.memcopy(cx, bx, OBJ_ITEM << 1);
            ax := TRUE;
        end
        else ie(ax = 508) do ! Change current directory
            ! bx = Address
            ax := fs_cd(bx);
        end
        else ie(ax = 509) do ! Get current directory
            ! bx = Dest
            ! cx = Len
            ax := fs_pwd(bx, cx);
        end
        else int_debug(0x79, ax,bx,cx,dx,ds,si,es,di);
    end
    else int_debug(0x79, ax,bx,cx,dx,ds,si,es,di);
end