
! ==========================================================================
! Main
! ==========================================================================


shutdown() t.int86ax(0x79, 1,0,0,0 ,0,0);


fatal_error(msg) do
! Display fatal error and shutdown (My own 'blue screen of death' =) )
    var tmp::1;
    term_kwrites("\ex00\ey24FATAL ERROR: ");
    term_kwrites(msg);
    term_kwrites("\r\nPress ANY KEY to shutdown.\r\n");
    term_read_char();
    shutdown();
end


do
    var arg::64, arg_disk, arg_cil, arg_head, arg_sect, arg_ok;
    var disk, i, item[OBJ_ITEM], stream[OBJ_STREAM], file_name::128;
    var buffer::1030, exec_stream[OBJ_STREAM];

    ! Verify current ambient
    ie(t.fargetw(t.local(), 0x10) = 1989)
        Mode := MODE_STANDALONE;
    else
        Mode := MODE_DOS_APP;

    ! Preserve interrupt map
    t.farcopy(t.local(), IntMap, 0, 0, 1024);
    
    ! Initialize
    mem_init();
    term_init();
    disk_init();
    fs_init();
    minixfs_init();
    process_init();
    
    ! Initialize Kernel API
    int_set(Int79Ant, t.local(), 0x79, @int79);
    
    ! Parse arguments: DISK CILINDERS HEADS SECTORS
    arg_ok := TRUE;
    if(t.getarg(1, arg, 15) = 0) arg_ok := FALSE;
    arg_disk := str_to_num(arg);
    if(t.getarg(2, arg, 15) = 0) arg_ok := FALSE;
    arg_cil := str_to_num(arg);
    if(arg_cil = 0) arg_ok := FALSE;
    if(t.getarg(3, arg, 15) = 0) arg_ok := FALSE;
    arg_head := str_to_num(arg);
    if(arg_head = 0) arg_ok := FALSE;
    if(t.getarg(4, arg, 15) = 0) arg_ok := FALSE;
    arg_sect := str_to_num(arg);
    if(arg_sect = 0) arg_ok := FALSE;
    
    ie(arg_ok) do
        term_kwrites("Mounting Disk ");
        term_writenum(arg_disk);
        term_kwrites(" [C:");
        term_writenum(arg_cil);
        term_kwrites(" H:");
        term_writenum(arg_head);
        term_kwrites(" S:");
        term_writenum(arg_sect);
        term_kwrites("]");
        ! Create disk
        disk := disk_reg(arg_disk, arg_cil, arg_head, arg_sect);
        term_kwrites(" .");
        ! Mount disk using MinixFS
        if(\minixfs_mount(disk)) fatal_error("Disk corrupted.");
        term_kwriteln(" [ OK ]");
        if(t.getarg(5, arg, 64) = 0) 
            fatal_error(
            "Shell missing. Use: DISK_ID CILINDERS HEADS SECTORS SHELL_PATH");
        term_kwrites("Loading ");
        term_kwriteln(arg);
        if(\fs_open_file(arg, stream)) fatal_error("Autoexec file not found.");
        stream_buffer_init(buffer, 1030);
        while(stream_readln(stream, buffer, file_name, 127)) do
            if(str_len(file_name) > 0) do
                term_kwrites("Loading ");
                term_writes(file_name);
                if(\fs_open_file(file_name, exec_stream)) do 
                    term_writes(file_name);
                    term_kwriteln(" file not found");
                end
                ie(str_endswith(file_name, ".com")) do 
                    term_kwriteln(" . [ COM File ]");
                    com_exec(exec_stream, "");
                end
                else ie(str_endswith(file_name, ".prg")) do 
                    term_kwriteln(" . [ PRG File ]");
                    prg_exec(exec_stream, "");
                end
                else term_kwriteln(". [ FILE NOT SUPPORTED ]");
            end
        end
    end
    else do
        fatal_error(
"Disk parameters incomplete. Use: DISK_ID CILINDERS HEADS SECTORS SHELL_PATH"
        );
    end

    ! Shutdown system
    shutdown();
end