! ==========================================================================
! COM File Support
! ==========================================================================

com_exec(stream, args) do
! Load COM file to RAM and Execute
    var temp::128, seg, i, pos, block, process, args_size, exec, sp, bp, ip;
    process := new_process();
    seg := mem_alloc_seg(process);
    if(seg = 0) return %2;
    ! Load COM file
    pos := 256;
    block := 0;
    i := 128;
    while(i = 128) do
        i := stream_read(stream, temp, 128);
        t.farcopy(seg, pos, t.stack(), temp, i);
        pos := pos + i;
    end
    t.farfill(seg, 0, 0, 255);
    t.farsetw(seg, 0xfffe, 0);
    args_size := str_len(args);
    if(args_size > 120) args_size := 120;
    t.farcopy(seg, 0x81, t.stack(), args, args_size);
    t.farsetb(seg, 0x80, args_size);
    t.farsetb(seg, 0x81 + args_size, 0xd);
    exec := FALSE;
    sp := t.stackptr();
    bp := t.baseptr();
    ip := t.instrptr();
    ie(exec)do
        ! Exit of COM Program
        return process_get_ret(process_get_current());
    end
    else do
        ! Call COM Program
        process_set_segs(process_get_current(), t.stack(), sp, bp, 
            t.local(), ip);
        process_set_segs(process, seg, 0xfffe, 0xfffe, seg, 256);
        process_set_parent(process, process_get_current());
        process_set_current(process);
        exec := TRUE;
        t.jmpstack(seg, 0xfffe, 0xfffe, seg, 256);
    end

end

! ==========================================================================
! PRG File Support
! ==========================================================================

prg_exec(stream, args) do
! Load PRG file to RAM and Execute
    var temp::128, seg, i, pos, block, process, args_size, exec, sp, bp, ip, start_ip;
    i := stream_read(stream, temp, 128);
    if(t.farcomp(t.stack(), temp, t.local(), "HUSIS", 5)) return %3;
    process := new_process();
    start_ip := temp[4];
    seg := mem_alloc(process, ((temp[5] + temp[6] + 2048) >> 4) + 10);
    if(seg = 0) return %2;
    ! Load PRG file
    t.farcopy(seg, 2048, t.stack(), temp, i);
    pos := 2048 + i;
    block := 0;
    while(i = 128) do
        i := stream_read(stream, temp, 128);
        t.farcopy(seg, pos, t.stack(), temp, i);
        pos := pos + i;
    end
    t.farfill(seg, 0, 0, 2048);
    args_size := str_len(args);
    if(args_size > 120) args_size := 120;
    t.farcopy(seg, 0, t.stack(), args, args_size);
    t.farsetb(seg, args_size, 0);
    exec := FALSE;
    sp := t.stackptr();
    bp := t.baseptr();
    ip := t.instrptr();
    ie(exec)do
        ! Exit of PRG Program
        return process_get_ret(process_get_current());
    end
    else do
        ! Call PRG Program
        process_set_segs(process_get_current(), t.stack(), sp, bp, 
            t.local(), ip);
        process_set_segs(process, seg, 2048, 2048, seg, start_ip);
        process_set_parent(process, process_get_current());
        process_set_current(process);
        exec := TRUE;
        t.jmpstack(seg, 2048, 2048, seg, start_ip);
    end

end