! HUSIS - Modular Kernel
! Humberto Costa dos Santos Junior, 2022
! 3-Clause BSD license
! Operating System for IBM PC and compatibles
!
!  This Operating System implements minimum INT 0x21 function set to run 
!  T3X/86 applications and Old-School Assembler without modifications.
!
!  This is a reorganization and simplification of original HUSIS Kernel, to 
!  keep kernel under 40 KiB.

const VERSION = 0;
const SUB_VERSION = 5;
const REVISION = 0;

const TRUE = %1;
const FALSE = 0;


var Mode;
const MODE_STANDALONE = 1; ! Running as Operating System
const MODE_DOS_APP = 2;  ! Running as DOS App
!
! Running as DOS Application:
! 
! - Use for Debug
! - Use on ROM DOS machines like HP Palmtop 95LX/100LX/200LX
!
! In this mode HUSIS Kernel will preserve all DOS Structures on RAM and use
! DOS delimited RAM space by MCB (DOS Memory Control Block).


! ==========================================================================
! String/Character
! ==========================================================================

char_is_num(c) return (c >= '0') & (c <= '9');
char_is_upper(c) return (c >= 'A') & (c <= 'Z');
char_is_lower(c) return (c >= 'a') & (c <= 'z');
char_is_alpha(c) return char_is_lower(c) | char_is_upper(c);
char_is_alphanum(c) return char_is_alpha(c) | char_is_num(c);
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


! ==========================================================================
! I/O STREAM (Generic API)
! ==========================================================================

const STATUS_UNKNOWN = 0;
const STATUS_OPEN = 1;
const STATUS_CLOSE = 2;


struct OBJ_RET =
! Return Object
    RET_OK,
    RET_VALUE,
    RET_AUX;

struct OBJ_STREAM = 
! String Object
    STREAM_STATUS,
    STREAM_SEG, 
    STREAM_PTR_AVAIL,
    STREAM_PTR_SEEK,
    STREAM_PTR_CAN_READ, 
    STREAM_PTR_READ, 
    STREAM_PTR_CAN_WRITE,
    STREAM_PTR_WRITE,
    STREAM_PTR_CLOSE,
    STREAM_SEG_BUFFER,
    STREAM_SIZE_BUFFER,
    STREAM_PTR_BUFFER,
    STREAM_POS_BUFFER,
    STREAM_POS,
    STREAM_POS_HIGH,
    STREAM_AUX1,
    STREAM_AUX2,
    STREAM_AUX3,
    STREAM_AUX4,
    STREAM_AUX5,
    STREAM_AUX6,
    STREAM_AUX7,
    STREAM_AUX8,
    STREAM_AUX9,
    STREAM_AUX10;

var StreamIO[OBJ_STREAM], StreamOut, StreamIn, StreamErr;
! Standard Stream I/O


new(
    stream, 
    seg, 
    ptr_avail, ptr_seek, ptr_can_read, ptr_read, ptr_can_write, ptr_write
    ) 
! Create new Stream object
do
    stream[STREAM_STATUS] := STATUS_OPEN;
    stream[STREAM_SEG] := seg;
    stream[STREAM_PTR_CLOSE] := 0;
    stream[STREAM_PTR_AVAIL] := ptr_avail;
    stream[STREAM_PTR_SEEK] := ptr_seek;
    stream[STREAM_PTR_CAN_READ] := ptr_can_read;
    stream[STREAM_PTR_READ] := ptr_read;
    stream[STREAM_PTR_CAN_WRITE] := ptr_can_write;
    stream[STREAM_PTR_WRITE] := ptr_write;
    stream[STREAM_SEG_BUFFER] := 0;
    stream[STREAM_SIZE_BUFFER] := 0;
    stream[STREAM_PTR_BUFFER] := 0;
    stream[STREAM_POS_BUFFER] := 0;
    stream[STREAM_POS] := 0;
    stream[STREAM_POS_HIGH] := 0;
    stream[STREAM_AUX1] := 0;
    stream[STREAM_AUX2] := 0;
    stream[STREAM_AUX3] := 0;
    stream[STREAM_AUX4] := 0;
    stream[STREAM_AUX5] := 0;
    stream[STREAM_AUX6] := 0;
    stream[STREAM_AUX7] := 0;
    stream[STREAM_AUX8] := 0;
    stream[STREAM_AUX9] := 0;
    stream[STREAM_AUX10] := 0;
end

buffer_set(stream, seg, ptr, len) do
! Set buffer to stream object
    stream[STREAM_SEG_BUFFER] := seg;
    stream[STREAM_SIZE_BUFFER] := len;
    stream[STREAM_PTR_BUFFER] := ptr;
    stream[STREAM_POS_BUFFER] := 0;
end

stream_seek(stream, pos_low, pos_high) do
! Seek on stream
    var ret[OBJ_RET];
    var ptr::T3X.PTRSIZE;
    if(stream[STREAM_SEG] = 0) return 0;
    if(stream[STREAM_PTR_SEEK] = 0) return 0;
    t.setptr(ptr, 
        stream[STREAM_SEG],
        stream[STREAM_PTR_SEEK]);
    callfar ptr(stream, pos_low, pos_high, ret);
    return ret[RET_OK];
end

stream_close(stream) do
! Close stream
    var ret[OBJ_RET];
    var ptr::T3X.PTRSIZE;
    if(stream[STREAM_SEG] = 0) return 0;
    if(stream[STREAM_PTR_CLOSE] = 0) return 0;
    t.setptr(ptr, 
        stream[STREAM_SEG],
        stream[STREAM_PTR_CLOSE]);
    callfar ptr(stream, ret);
    return ret[RET_OK];
end

stream_read(stream, buffer, len) do
! Read from stream
    var ret[OBJ_RET];
    var ptr::T3X.PTRSIZE;
    if(stream[STREAM_SEG] = 0) return 0;
    if(stream[STREAM_PTR_READ] = 0) return 0;
    t.setptr(ptr, 
        stream[STREAM_SEG],
        stream[STREAM_PTR_READ]);
    callfar ptr(stream, t.stack(), buffer, len, ret);
    return ret[RET_VALUE];
end

stream_write(stream, buffer, len) do
! Write on stream
    var ret[OBJ_RET];
    var ptr::T3X.PTRSIZE;
    if(stream[STREAM_SEG] = 0) return 0;
    if(stream[STREAM_PTR_WRITE] = 0) return 0;
    t.setptr(ptr, 
        stream[STREAM_SEG],
        stream[STREAM_PTR_WRITE]);
    callfar ptr(stream, t.stack(), buffer, len, ret);
    return ret[RET_VALUE];
end

stream_writes(stream, str) return stream_write(stream, str, str_len(str));
! Write string to stream

stream_writeln(stream, str) do
! Write line string to stream
    stream_writes(stream, str);
    stream_writes(stream, "\r\n");
end

stream_rwrite(stream, seg, buffer, len) do
! Write remote block to stream
    var ret[OBJ_RET];
    var ptr::T3X.PTRSIZE;
    if(stream[STREAM_SEG] = 0) return 0;
    if(stream[STREAM_PTR_WRITE] = 0) return 0;
    t.setptr(ptr, 
        stream[STREAM_SEG],
        stream[STREAM_PTR_WRITE]);
    callfar ptr(stream, seg, buffer, len, ret);
    return ret[RET_VALUE];
end

stream_rwrites(stream, seg, str) 
! Write remote string to stream
    return stream_rwrite(stream, seg, str, rstr_len(seg, str));

stream_rwriteln(stream, seg, str) do
! Write remote line string to stream
    stream_rwrites(stream, seg, str);
    stream_writes(stream, "\r\n");
end

stream_write_char(stream, char) do
! Write char to stream
    var str::2;
    str::0 := char;
    str::1 := 0;
    stream_writes(stream, str);
end

stream_write_num(stream, value) do
! Write number to stream
    var tmp, tmp2;
    if(value < 0) do
        stream_write_char(stream, '-');
        value := -value;
    end
    tmp := value mod 10;
    tmp2 := value / 10;
    if (tmp2 > 0) stream_write_num(stream, tmp2);
    stream_write_char(stream, tmp + '0'); 
end

stream_write_hex(stream, value) do
! Write Hexadecimal to stream
    var tmp, tmp2;
    tmp := value & 15;
    tmp2 := value >> 4;
    if (tmp2 > 0) stream_write_hex(stream, tmp2);
    ie (tmp < 10) stream_write_char(stream, tmp + '0'); 
    else stream_write_char(stream, tmp + 'a' - 10);
end

stream_buffer_init(buffer, total_len) do
! Initialize stream buffer
    if(total_len < 10) return FALSE;
    buffer[0] := total_len - 6;
    buffer[1] := 0;
    buffer[2] := 0;
    buffer[3] := 0;
    return TRUE;
end

stream_readln(stream, buffer, dest, dest_len) do
! Read line using buffer
    var i, j, contents;
    if(buffer[1] = 0) do
        buffer[1] := stream_read(stream, @buffer[3], buffer[0]);
        if(buffer[1] = 0) return FALSE;
        buffer[2] := 0;
    end
    dest::0 := 0;
    contents := @buffer[3];
    j := buffer[2];
    for(i=0,dest_len-1) do
        if(j >= buffer[1]) do
            ie(buffer[1] = buffer[0])do
                buffer[1] := stream_read(stream, @buffer[3], buffer[0]);
                if(buffer[1] = 0)do
                    ie(i > 0)
                        return TRUE;
                    else
                        return FALSE;
                end
                buffer[2] := 0;
                j := 0;
            end
            else return (i > 0);
        end
        if(contents::j = 0) ie(i > 0) leave; else return FALSE;
        if(contents::j = '\n')do
            buffer[2] := j + 1;
            leave;
        end
        ie(contents::j \= '\r') do
            dest::i := contents::j;
            dest::(i+1) := 0;
        end
	    else i := i - 1;
        j := j + 1;
        buffer[2] := j;
    end
    return TRUE;
end

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


! ==========================================================================
! Memory Manager
! ==========================================================================
decl fatal_error(1);

const MEM_FULL_CAPACITY = 2560; ! 640KiB / 256B

const MEM_TYPE_EMPTY = 0;
const MEM_TYPE_PROGRAM = 256;
const MEM_TYPE_DATA = 512;
const MEM_TYPE_END = 1024;

var MemFirstSegment;

mem_total_kib() do
! Get total accessible ram size
    if(t.fargetw(t.local(), @Mode) = MODE_DOS_APP) do
        ! (Get MCB allocated paras(16 bytes block) + Local segment) / 64
        return (
                (t.fargetw(t.local()-1, 3) + 
                t.local()) >> 6
            ) & 0x7fff;
    end
    return t.int86ax(0x12,0,0,0,0,0,0);
end

mem_usable_kib() do
! Get usable ram size
    ! Total - (Kernel position) - (Kernel Size)
    return mem_total_kib() - ((t.local() >> 6) & 0x7fff) - 64;
end

mem_init() do
! Initialize application memory with first MCB (Use same format of DOS)
    var start_free;
    MemFirstSegment := t.local() + 4096;
    start_free := ((MemFirstSegment >> 4) + (MEM_FULL_CAPACITY >> 7));
    t.farfillw(MemFirstSegment, 0, 0, MEM_FULL_CAPACITY);
    t.farfillw(MemFirstSegment, 0, 0xffff, start_free);
    t.farfillw(MemFirstSegment, (mem_usable_kib() << 3), 0xffff, 
        MEM_FULL_CAPACITY - (mem_usable_kib() << 2));

end

mem_size(seg) do
! Return size of allocated block in paras
    var i, map, find, size;
    map := t.fargetw(t.local(), @MemFirstSegment);
    find := (t.fargetw(map, seg >> 3) & 0xff);
    size := 0;
    for(i=(seg >> 4),MEM_FULL_CAPACITY)do
        ie((t.fargetw(map, i << 1) & 0xff) = find) do
            size := size + 1;
            if((t.fargetw(map, i << 1) & MEM_TYPE_END) = MEM_TYPE_END) leave;
        end
        else leave;
    end
    return size << 4;
end

mem_alloc(process, paras) do
! Allocate block in application memory (1 para. = 16 Bytes)
! Return 0 if fails
    var size, blocks, first, last, finding;
    var i, map;
    blocks := paras >> 4;
    if((paras & 0xf) > 0)blocks := blocks + 1;
    if((blocks < 0) | (blocks > 512)) return 0; ! More than 128 KiB
    map := t.fargetw(t.local(), @MemFirstSegment);
    size := 0;
    finding := FALSE;
    for(i=0,MEM_FULL_CAPACITY)do
        ie(t.fargetw(map, i << 1) = 0) do
            ie(\finding)do
                size := 1;
                finding := TRUE;
                first := i;
                last := i;
            end
            else do
                size := size + 1;
                last := i;
            end
            if(size = blocks) do
                leave;
            end
        end
        else finding := FALSE;
    end
    if(\finding) return 0;
    if(size \= blocks) return 0;
    for(i=first,last)do
        ie(i = last) do
            t.farsetw(map, i << 1, process | MEM_TYPE_END | MEM_TYPE_DATA);
        end
        else do
            t.farsetw(map, i << 1, process | MEM_TYPE_DATA);
        end
    end
    return first << 4;
end

mem_alloc_seg(process) do
! Allocate full segment block (64 KiB)
    return mem_alloc(process, 4096);
end

mem_free(seg) do
! Free block of application memory
    var i, map, find, size, tmp;
    map := t.fargetw(t.local(), @MemFirstSegment);
    find := (t.fargetw(map, seg >> 3) & 0xff);
    size := 0;
    for(i=(seg >> 4),MEM_FULL_CAPACITY)do
        tmp := t.fargetw(map, i << 1);
        if((tmp & 0xff) = find) do
            t.farsetw(map, i << 1, 0);
            if((tmp & MEM_TYPE_END) = MEM_TYPE_END) leave;
        end
    end
end

mem_free_process(process) do
! Free all blocks of one process
    var i, map, size;
    map := t.fargetw(t.local(), @MemFirstSegment);
    size := 0;
    for(i=0,MEM_FULL_CAPACITY)do
        if((t.fargetw(map, i << 1) & 0xff) = process) do
            t.farsetw(map, i << 1, 0);
        end
    end
end

mem_calc_free() do
! Return total free space
    var i, map, size;
    map := t.fargetw(t.local(), @MemFirstSegment);
    size := 0;
    for(i=0,MEM_FULL_CAPACITY)do
        if(t.fargetw(map, i << 1) = 0) do
            size := size + 1;
        end
    end
    return size << 4;
end

mem_calc_free_kib() do
    return (mem_calc_free() >> 6) & 0x7fff;
end

! ==========================================================================
! BIOS Disk I/O using Stream API
! ==========================================================================
const TOTAL_DISK = 16;

var DiskList[TOTAL_DISK], DiskData[OBJ_STREAM * TOTAL_DISK];

const DISK_CILINDERS = STREAM_AUX1;
const DISK_HEADS = STREAM_AUX2;
const DISK_SECTORS = STREAM_AUX3;
const DISK_BIOS_ID = STREAM_AUX4;
const DISK_POS_LOW = STREAM_POS;
const DISK_POS_HIGH = STREAM_POS_HIGH;

_disk_seek(stream, pos_low, pos_high, ret) far do
! 'Seek' on disk
    stream[DISK_POS_LOW] := pos_low;
    stream[DISK_POS_HIGH] := pos_high;
    ret[RET_OK] := TRUE;
end

_disk_read(stream, seg, dest, len, ret) far do
! Read block from disk using BIOS Disk API
    var ax, bx, cx, dx, i;
    var cil, head, sect, cil_tot, head_tot, sect_tot, posicao;
    ret[RET_OK] := FALSE;
    ret[RET_VALUE] := 0;
    if(len \= 512) return;
    posicao := stream[DISK_POS_LOW];
    cil_tot := stream[DISK_CILINDERS];
    head_tot := stream[DISK_HEADS];
    sect_tot := stream[DISK_SECTORS];
    cil := posicao / (head_tot * sect_tot);
    head := (posicao / sect_tot) mod head_tot;
    sect := (posicao mod sect_tot) + 1;
    if(cil >= cil_tot) return;
    ax := 0x201;
    bx := dest;
    cx := (cil << 8) | sect | ((cil >> 8) << 6);
    dx := stream[DISK_BIOS_ID] | (head << 8);
    for(i=0,3) do
        ! Try 3 times (Physical Floppy disk controller needed this)
        ret[RET_OK] := TRUE;
        ret[RET_VALUE] := 1;
        ! Try reading block
        if(t.int86c(0x13, ax,bx,cx,dx, 0,0) = 0) return;
        ! Reset disk controller if fails
        t.int86c(0x13, 0,0,0,stream[DISK_BIOS_ID], 0,0);
    end
    ret[RET_OK] := FALSE;
    ret[RET_VALUE] := 0;
end

_disk_write(stream, seg, orig, len, ret) far do
! Write block from disk using BIOS Disk API
    var ax, bx, cx, dx, i;
    var cil, head, sect, cil_tot, head_tot, sect_tot, posicao;
    ret[RET_OK] := FALSE;
    ret[RET_VALUE] := 0;
    if(len \= 512) return;
    posicao := stream[DISK_POS_LOW];
    cil_tot := stream[DISK_CILINDERS];
    head_tot := stream[DISK_HEADS];
    sect_tot := stream[DISK_SECTORS];
    cil := posicao / (head_tot * sect_tot);
    head := (posicao / sect_tot) mod head_tot;
    sect := (posicao mod sect_tot) + 1;
    if(cil >= cil_tot) return;
    ax := 0x301;
    bx := orig;
    cx := (cil << 8) | sect | ((cil >> 8) << 6);
    dx := stream[DISK_BIOS_ID] | (head << 8);
    for(i=0,3) do
        ! Try 3 times (Physical Floppy disk controller needed this)
        ret[RET_OK] := TRUE;
        ret[RET_VALUE] := 1;
        ! Try writing block
        if(t.int86c(0x13, ax,bx,cx,dx, 0,0) = 0) return;
        ! Reset disk controller if fails
        t.int86c(0x13, 0,0,0,stream[DISK_BIOS_ID], 0,0);
    end
    ret[RET_OK] := FALSE;
    ret[RET_VALUE] := 0;
end

_disk_avail(stream, ret) far do
! Return if disk has data avail
    ret[RET_OK] := TRUE;
    ret[RET_VALUE] := 1;
end

_disk_can_read(stream, ret) far do
! Return if can read
    ret[RET_OK] := TRUE;
end 

_disk_can_write(stream, ret) far do
! Return if can write
    ret[RET_OK] := TRUE;
end 

disk_init() do
! Initialize global disk structures
    var i;
    for(i=0,TOTAL_DISK) do
        DiskList[i] := @DiskData[i * OBJ_STREAM];
        DiskList[i][STREAM_STATUS] := STATUS_UNKNOWN;
    end
end

disk_reg(id, cil, head, sect) do
! Register new BIOS Disk
    var i;
    for(i=0,TOTAL_DISK) do
        if(DiskList[i][STREAM_STATUS] = STATUS_UNKNOWN) do
            new(
                DiskList[i],
                t.local(),
                @_disk_avail, @_disk_seek, @_disk_can_read, 
                @_disk_read, @_disk_can_write, @_disk_write
                );
            DiskList[i][DISK_CILINDERS] := cil;
            DiskList[i][DISK_HEADS] := head;
            DiskList[i][DISK_SECTORS] := sect;
            DiskList[i][DISK_BIOS_ID] := id;
            return i;
        end
    end
    return %1;
end

! ==========================================================================
! File System Infrastructure
! ==========================================================================

const PATH_LEN = 512;
const TOTAL_FS = 16;

const STATUS_FS_AVAIL = 0;
const STATUS_FS_MOUNTED = 1;


struct OBJ_FS = 
! File System Object
    FS_STATUS,
    FS_ID,
    FS_DISK,
    FS_SEG,
    FS_PTR_FIRST_ITEM,
    FS_PTR_NEXT_ITEM,
    FS_PTR_UMOUNT,
    FS_AUX1,
    FS_AUX2,
    FS_AUX3,
    FS_AUX4,
    FS_AUX5,
    FS_AUX6,
    FS_AUX7,
    FS_AUX8,
    FS_AUX9,
    FS_AUX10;

const TYPE_UNKNOWN = 0;
const TYPE_FILE = 1;
const TYPE_DIRECTORY = 2;

struct OBJ_ITEM_HEADER =
! File System Item Object
    ITEM_TYPE,
    ITEM_PARENT_ID,
    ITEM_ID,
    ITEM_POS_ON_PARENT,
    ITEM_SEG_OPEN,
    ITEM_PTR_OPEN,
    ITEM_FS,
    ITEM_NAME;
const OBJ_ITEM = OBJ_ITEM_HEADER + 16; ! 16 Words/32 Bytes to name

const SIZE_NAME = 30;

var FSList[TOTAL_FS], FSData[OBJ_FS * TOTAL_FS], FSCurrent;
var FSPath::PATH_LEN;

new_item(item, type, seg, ptr_open, parent_id, id) do
! Create file system item
    item[ITEM_TYPE] := type;
    item[ITEM_ID] := id;
    item[ITEM_PARENT_ID] := parent_id;
    item[ITEM_SEG_OPEN] := seg;
    item[ITEM_PTR_OPEN] := ptr_open;
    item[ITEM_NAME] := @item[ITEM_NAME] + 2;
    item[ITEM_NAME]::0 := 0;
end

fs_reg(disk, seg, ptr_first_item, ptr_next_item, ptr_umount) do
! Register new mounted file system
    var i;
    for(i=0,TOTAL_FS) do
        if(FSList[i][FS_STATUS] = STATUS_FS_AVAIL) do
            FSList[i][FS_STATUS] := STATUS_FS_MOUNTED;
            FSList[i][FS_SEG] := seg;
            FSList[i][FS_DISK] := disk;
            FSList[i][FS_PTR_FIRST_ITEM] := ptr_first_item;
            FSList[i][FS_PTR_NEXT_ITEM] := ptr_next_item;
            FSList[i][FS_PTR_UMOUNT] := ptr_umount;
            return i;
        end
    end
    return %1;
end

fs_init() do
! Initialize file system global vars
    var i;
    for(i=0,TOTAL_FS) do
        FSList[i] := @FSData[i * OBJ_FS];
        FSList[i][FS_ID] := i;
        FSList[i][FS_STATUS] := STATUS_FS_AVAIL;
    end
    str_copy(FSPath, "/");
    FSCurrent := 0;
end

fs_open_item(item, stream) do
! Open item, returns stream
    var ret[OBJ_RET], ptr[T3X.PTRSIZE];
    if(item[ITEM_TYPE] = TYPE_DIRECTORY) return FALSE;
    if(item[ITEM_SEG_OPEN] = 0) return FALSE;
    if(item[ITEM_PTR_OPEN] = 0) return FALSE;
    t.setptr(ptr, item[ITEM_SEG_OPEN], item[ITEM_PTR_OPEN]);
    callfar ptr(item, stream, ret);
    return ret[RET_OK];
end

fs_first(fs, id, item) do
! Get first sub item from directory(by ID)
    var ret[OBJ_RET], ptr[T3X.PTRSIZE], fsobj[OBJ_FS];
    t.farcopy
    (
        t.stack(), 
        fsobj,
        t.local(), 
        t.fargetw(t.local(),t.fargetw(t.local(),@FSList)) + (fs << 1), 
        OBJ_FS << 1
    );
    if(fsobj[FS_SEG] = 0) return FALSE;
    if(fsobj[FS_PTR_FIRST_ITEM] = 0) return FALSE;
    t.setptr(ptr, fsobj[FS_SEG], fsobj[FS_PTR_FIRST_ITEM]);
    callfar ptr(fsobj, id, item, ret);
    return ret[RET_OK];
end

fs_next(fs, item) do
! Get next sub item from directory
    var ret[OBJ_RET], ptr[T3X.PTRSIZE], fsobj[OBJ_FS];
    t.farcopy
    (
        t.stack(), 
        fsobj,
        t.local(), 
        t.fargetw(t.local(),t.fargetw(t.local(),@FSList)) + (fs << 1), 
        OBJ_FS << 1
    );
    if(fsobj[FS_SEG] = 0) return FALSE;
    if(fsobj[FS_PTR_NEXT_ITEM] = 0) return FALSE;
    t.setptr(ptr, fsobj[FS_SEG], fsobj[FS_PTR_NEXT_ITEM]);
    callfar ptr(fsobj, item, ret);
    return ret[RET_OK];
end

fs_open_file(file_address, stream) do
! Open file from address
! Accepted address format:
!  [FS]/DIR/DIR/FILE
! OR
!  /DIR/DIR/FILE
!
!  - FS = Number of File System, started in 0
!  - DIR or FILE = Name
    var fsobj[OBJ_FS], fs, item[OBJ_ITEM], i, j, ok, name::32, name_len, dir;
    var old_item[OBJ_ITEM], address::PATH_LEN;
    ie((file_address::0 = '[') | (file_address::0 = '/'))do
        str_copy(address, file_address);
    end
    else do
        rstr_copy(t.stack(), address, t.local(), @FSPath);
        str_concat(address, file_address);
    end
    fs := t.fargetw(t.local(), @FSCurrent);
    ok := FALSE;
    i := 0;
    if(address::0 = '[') do
        fs := 0;
        for(i=1,str_len(address)) do
            if(address::i = ']') leave;
            if(\char_is_num(address::i)) return FALSE;
            fs := (fs * 10) + (address::i - '0');
        end
        i := i + 1;
    end
    ! Load file system
    t.farcopy
    (
        t.stack(), 
        fsobj,
        t.local(), 
        t.fargetw(t.local(),t.fargetw(t.local(),@FSList)) + (fs << 1), 
        OBJ_FS << 1
    );
    if(fsobj[FS_STATUS] \= STATUS_FS_MOUNTED) return FALSE;
    if(address::i \= '/') return FALSE;
    i := i + 1;
    dir := 0;
    name_len := 0;
    name::name_len := 0;
    for(i = i, str_len(address)) do
        ie(address::i = '/') do
            ok := FALSE;
            j := fs_first(fsobj[FS_ID], dir, item);
            while(j) do
                str_to_lower(name);
                str_to_lower(item[ITEM_NAME]);
                if(str_equal(name, item[ITEM_NAME])) do
                    ok := TRUE;
                    dir := item[ITEM_ID];
                    t.memcopy(old_item, item, OBJ_ITEM << 1);
                    leave;
                end
                j := fs_next(fsobj[FS_ID], item);
            end
            if(ok = FALSE) return FALSE;
            name_len := 0;
            name::name_len := 0;
        end
        else do
            if(name_len = 31) return FALSE;
            name::name_len := address::i;
            name_len := name_len + 1;
            name::name_len := 0;
        end
    end
    if(name_len = 0) return FALSE;
    ok := FALSE;
    j := fs_first(fsobj[FS_ID], dir, item);
    while(j) do
        str_to_lower(name);
        str_to_lower(item[ITEM_NAME]);
        if(str_equal(name, item[ITEM_NAME])) do
            ok := TRUE;
            dir := item[ITEM_ID];
            leave;
        end
        j := fs_next(fsobj[FS_ID], item);
    end
    if(ok = FALSE) return FALSE;
    return fs_open_item(item, stream);
end

fs_open_dir(dir_address, item_dir) do
! Open dir from address
! Accepted address format:
!  [FS]/DIR/DIR/FILE
! OR
!  /DIR/DIR/FILE
!
!  - FS = Number of File System, started in 0
!  - DIR or FILE = Name
    var fsobj[OBJ_FS], fs, item[OBJ_ITEM], i, j, ok, name::32, name_len, dir;
    var old_item[OBJ_ITEM], address::PATH_LEN;
    ie((dir_address::0 = '[') | (dir_address::0 = '/'))do
        str_copy(address, dir_address);
    end
    else do
        rstr_copy(t.stack(), address, t.local(), @FSPath);
        str_concat(address, dir_address);
    end
    fs := t.fargetw(t.local(), @FSCurrent);
    ok := FALSE;
    i := 0;
    if(address::0 = '[') do
        fs := 0;
        for(i=1,str_len(address)) do
            if(address::i = ']') leave;
            if(\char_is_num(address::i)) return FALSE;
            fs := (fs * 10) + (address::i - '0');
        end
        i := i + 1;
    end
    ! Load file system
    t.farcopy
    (
        t.stack(), 
        fsobj,
        t.local(), 
        t.fargetw(t.local(),t.fargetw(t.local(),@FSList)) + (fs << 1), 
        OBJ_FS << 1
    );
    if(fsobj[FS_STATUS] \= STATUS_FS_MOUNTED) return FALSE;
    if(address::i \= '/') return FALSE;
    i := i + 1;
    dir := 0;
    name_len := 0;
    name::name_len := 0;
    ie(str_equal(@address::i, "/"))do
        ok := TRUE;
        fs_first(fsobj[FS_ID], dir, item); ! First item is allways '.'
    end
    else do
        for(i = i, str_len(address)) do
            ie(address::i = '/') do
                ok := FALSE;
                j := fs_first(fsobj[FS_ID], dir, item);
                while(j) do
                    str_to_lower(name);
                    str_to_lower(item[ITEM_NAME]);
                    if(str_equal(name, item[ITEM_NAME])) do
                        ok := TRUE;
                        dir := item[ITEM_ID];
                        t.memcopy(old_item, item, OBJ_ITEM << 1);
                        leave;
                    end
                    j := fs_next(fsobj[FS_ID], item);
                end
                if(ok = FALSE) return FALSE;
                name_len := 0;
                name::name_len := 0;
            end
            else do
                if(name_len = 31) return FALSE;
                name::name_len := address::i;
                name_len := name_len + 1;
                name::name_len := 0;
            end
        end
        if(name_len > 0) do
            ok := FALSE;
            j := fs_first(fsobj[FS_ID], dir, item);
            while(j) do
                str_to_lower(name);
                str_to_lower(item[ITEM_NAME]);
                if(str_equal(name, item[ITEM_NAME])) do
                    ok := TRUE;
                    dir := item[ITEM_ID];
                    leave;
                end
                j := fs_next(fsobj[FS_ID], item);
            end
        end 
        if(ok = FALSE) return FALSE;
    end
    if(item[ITEM_TYPE] \= TYPE_DIRECTORY) return FALSE;
    t.memcopy(item_dir, item, OBJ_ITEM << 1);
    return TRUE;
end

fs_cd(new_path) do
    var item[OBJ_ITEM];
    if(new_path > (PATH_LEN - 128)) return FALSE;
    if(\fs_open_dir(new_path, item)) return FALSE;
    rstr_copy(t.local(), @FSPath, t.stack(), new_path);
    if(new_path::(str_len(new_path)-1) \= '/') 
        rstr_concat(t.local(), @FSPath, t.local(), "/");
    return TRUE;
end

fs_pwd(path, len)do
    if((rstr_len(t.local(), @FSPath)+1) > len) return FALSE;
    rstr_copy(t.stack(), path, t.local(), @FSPath);
    return TRUE;
end

! ==========================================================================
! Minix File System
! ==========================================================================

const MINIXFS_TOTAL_ITENS = FS_AUX1;
const MINIXFS_TOTAL_ZONES = FS_AUX2;
const MINIXFS_MAP_ITENS = FS_AUX3;
const MINIXFS_MAP_ITENS_SIZE = FS_AUX4;
const MINIXFS_MAP_ZONES = FS_AUX5;
const MINIXFS_MAP_ZONES_SIZE = FS_AUX6;
const MINIXFS_LIST_ITENS = FS_AUX7;
const MINIXFS_LIST_ITENS_SIZE = FS_AUX8;
const MINIXFS_OPENED_COUNT = FS_AUX9;

const STREAM_MINIXFS_ZONE = STREAM_AUX1;
const STREAM_MINIXFS_POS = STREAM_AUX2;
const STREAM_MINIXFS_ID = STREAM_AUX3;
const STREAM_MINIXFS_FS = STREAM_AUX4;

var MinixFSBuffer::5120, 
! 4 Buffers regions most used
    MinixFSBuffer0, 
    MinixFSBuffer1, 
    MinixFSBuffer2,
    MinixFSBuffer3,
    MinixFSBuffer4, 
    MinixFSBufferFS0, 
    MinixFSBufferFS1, 
    MinixFSBufferFS2,
    MinixFSBufferFS3,
    MinixFSBufferFS4;

minixfs_read_zone(disk, position, dest) do
! Read zones (1024 bytes disk block) using 512 bytes physical blocks
    var fsbuffer, fsbuffer0, fsbuffer1, fsbuffer2, fsbuffer3, fsbuffer4;
    var fsbufferfs0, fsbufferfs1, fsbufferfs2, fsbufferfs3, fsbufferfs4;
    var dtmp[OBJ_STREAM], dptr;
    fsbuffer := t.fargetw(t.local(), @MinixFSBuffer);
    fsbuffer0 := t.fargetw(t.local(), @MinixFSBuffer0);
    fsbuffer1 := t.fargetw(t.local(), @MinixFSBuffer1);
    fsbuffer2 := t.fargetw(t.local(), @MinixFSBuffer2);
    fsbuffer3 := t.fargetw(t.local(), @MinixFSBuffer3);
    fsbuffer4 := t.fargetw(t.local(), @MinixFSBuffer4);
    fsbufferfs0 := t.fargetw(t.local(), @MinixFSBufferFS0);
    fsbufferfs1 := t.fargetw(t.local(), @MinixFSBufferFS1);
    fsbufferfs2 := t.fargetw(t.local(), @MinixFSBufferFS2);
    fsbufferfs3 := t.fargetw(t.local(), @MinixFSBufferFS3);
    fsbufferfs4 := t.fargetw(t.local(), @MinixFSBufferFS4);
    dptr := t.fargetw(t.local(), @DiskList);
    t.farcopy(t.stack(), dtmp, t.local(), 
        t.fargetw(t.local(), dptr + (disk << 1)), OBJ_STREAM<<1);
    ! Check buffer, if buffered, return copy
    ie
    (
        (position > 0) &
        (position < 8) & 
        (fsbuffer0 = position) &
        (fsbufferfs0 = disk)
    ) do
        t.farcopy(t.stack(), dest, t.local(), @fsbuffer::0, 1024);
        return TRUE;
    end
    else ie
    (
        (position >= 8) & 
        (position < 16) & 
        (fsbuffer1 = position) &
        (fsbufferfs1 = disk)
    ) do
        t.farcopy(t.stack(), dest, t.local(), @fsbuffer::1024, 1024);
        return TRUE;
    end
    else ie
    (
        (position >= 16) & 
        (position < 64) & 
        (fsbuffer2 = position) &
        (fsbufferfs2 = disk)
    ) do
        t.farcopy(t.stack(), dest, t.local(), @fsbuffer::2048, 1024);
        return TRUE;
    end
    else ie
    (
        (position >= 64) & 
        (position < 1024) & 
        (fsbuffer3 = position) &
        (fsbufferfs3 = disk)
    ) do
        t.farcopy(t.stack(), dest, t.local(), @fsbuffer::3072, 1024);
        return TRUE;
    end
    else if
    (
        (position >= 1024) &
        (fsbuffer4 = position) &
        (fsbufferfs4 = disk)
    ) do
        t.farcopy(t.stack(), dest, t.local(), fsbuffer::4096, 1024);
        return TRUE;
    end
!term_kwrites("[READ ");
!t.writenum(T3X.SYSERR, position);
!term_kwrites("]");
    ! Read from disk
    if(\stream_seek(dtmp, position << 1, 0)) return FALSE;
    if(stream_read(dtmp, dest, 512) = 0) return FALSE;
    if(\stream_seek(dtmp, (position << 1) + 1, 0)) return FALSE;
    if(stream_read(dtmp, @dest::512, 512) = 0) return FALSE;
    ! Store on buffer
    ie
    (
        (position > 0) &
        (position < 8)
    ) do
        t.farcopy(t.local(), @fsbuffer::0, t.stack(), dest, 1024);
        t.farsetw(t.local(),   @fsbuffer0, position);
        t.farsetw(t.local(), @fsbufferfs0, disk);
    end
    else ie
    (
        (position >= 8) & 
        (position < 16)
    ) do
        t.farcopy(t.local(), @fsbuffer::1024, t.stack(), dest, 1024);
        t.farsetw(t.local(),   @fsbuffer1, position);
        t.farsetw(t.local(), @fsbufferfs1, disk);
    end
    else ie
    (
        (position >= 16) & 
        (position < 64)
    ) do
        t.farcopy(t.local(), @fsbuffer::2048, t.stack(), dest, 1024);
        t.farsetw(t.local(),   @fsbuffer2, position);
        t.farsetw(t.local(), @fsbufferfs2, disk);
    end
    else ie
    (
        (position >= 64) & 
        (position < 1024)
    ) do
        t.farcopy(t.local(), @fsbuffer::3072, t.stack(), dest, 1024);
        t.farsetw(t.local(),   @fsbuffer3, position);
        t.farsetw(t.local(), @fsbufferfs3, disk);
    end
    else if
    (
        (position >= 1024)
    ) do
        t.farcopy(t.local(), @fsbuffer::4096, t.stack(), dest, 1024);
        t.farsetw(t.local(),   @fsbuffer4, position);
        t.farsetw(t.local(), @fsbufferfs4, disk);
    end
    return TRUE;
end

minixfs_write_zone(disk, position, orig) do
! Write zones (1024 bytes disk block) using 512 bytes physical blocks
    var fsbuffer, fsbuffer0, fsbuffer1, fsbuffer2, fsbuffer3, fsbuffer4;
    var fsbufferfs0, fsbufferfs1, fsbufferfs2, fsbufferfs3, fsbufferfs4;
    var dtmp[OBJ_STREAM], dptr;
    fsbuffer := t.fargetw(t.local(), @MinixFSBuffer);
    fsbuffer0 := t.fargetw(t.local(), @MinixFSBuffer0);
    fsbuffer1 := t.fargetw(t.local(), @MinixFSBuffer1);
    fsbuffer2 := t.fargetw(t.local(), @MinixFSBuffer2);
    fsbuffer3 := t.fargetw(t.local(), @MinixFSBuffer3);
    fsbuffer4 := t.fargetw(t.local(), @MinixFSBuffer4);
    fsbufferfs0 := t.fargetw(t.local(), @MinixFSBufferFS0);
    fsbufferfs1 := t.fargetw(t.local(), @MinixFSBufferFS1);
    fsbufferfs2 := t.fargetw(t.local(), @MinixFSBufferFS2);
    fsbufferfs3 := t.fargetw(t.local(), @MinixFSBufferFS3);
    fsbufferfs4 := t.fargetw(t.local(), @MinixFSBufferFS4);
    dptr := t.fargetw(t.local(), @DiskList);
    t.farcopy(t.stack(), dtmp, t.local(), 
        t.fargetw(t.local(), dptr + (disk << 1)), OBJ_STREAM<<1);
    !t.writes(T3X.SYSERR, "[WRITE ");
    !t.writenum(T3X.SYSERR, position);
    !t.writes(T3X.SYSERR, "]");
    ! Write to disk
    if(\stream_seek(dtmp, position << 1, 0)) return FALSE;
    if(stream_write(dtmp, orig, 512) = 0) return FALSE;
    if(\stream_seek(dtmp, (position << 1) + 1, 0)) return FALSE;
    if(stream_write(dtmp, @orig::512, 512) = 0) return FALSE;
    ! Store on buffer
    ie
    (
        (position > 0) &
        (position < 8)
    ) do
        t.farcopy(t.local(), @fsbuffer::0, t.stack(), orig, 1024);
        t.farsetw(t.local(),   @fsbuffer0, position);
        t.farsetw(t.local(), @fsbufferfs0, disk);
    end
    else ie
    (
        (position >= 8) & 
        (position < 16)
    ) do
        t.farcopy(t.local(), @fsbuffer::1024, t.stack(), orig, 1024);
        t.farsetw(t.local(),   @fsbuffer1, position);
        t.farsetw(t.local(), @fsbufferfs1, disk);
    end
    else ie
    (
        (position >= 16) & 
        (position < 64)
    ) do
        t.farcopy(t.local(), @fsbuffer::2048, t.stack(), orig, 1024);
        t.farsetw(t.local(),   @fsbuffer2, position);
        t.farsetw(t.local(), @fsbufferfs2, disk);
    end
    else ie
    (
        (position >= 64) & 
        (position < 1024)
    ) do
        t.farcopy(t.local(), @fsbuffer::3072, t.stack(), orig, 1024);
        t.farsetw(t.local(),   @fsbuffer3, position);
        t.farsetw(t.local(), @fsbufferfs3, disk);
    end
    else if
    (
        (position >= 1024)
    ) do
        t.farcopy(t.local(), @fsbuffer::4096, t.stack(), orig, 1024);
        t.farsetw(t.local(),   @fsbuffer4, position);
        t.farsetw(t.local(), @fsbufferfs4, disk);
    end
    return TRUE;
end

minixfs_last_zone_size(fs, id) do
! Get last zone size
    var zone::1024, item;
    ie(id = 0) id := 1; else id := id - 1;
    if(fs[FS_STATUS] \= STATUS_FS_MOUNTED) return 0;
    if(fs[MINIXFS_TOTAL_ITENS] < id) return 0;
    if
    (
        minixfs_read_zone
        (
            fs[FS_DISK], 
            fs[MINIXFS_LIST_ITENS] + (id >> 6),
            zone
        )
    )
    do
        item := (id mod 32) * 16;
        return zone[item + 2] & 0x3ff;
    end
    return 0;
end

minixfs_last_zone_pos(fs, id) do
! Get last zone size
    var zone::1024, item;
    ie(id = 0) id := 1; else id := id - 1;
    if(fs[FS_STATUS] \= STATUS_FS_MOUNTED) return 0;
    if(fs[MINIXFS_TOTAL_ITENS] < id) return 0;
    if
    (
        minixfs_read_zone
        (
            fs[FS_DISK], 
            fs[MINIXFS_LIST_ITENS] + (id >> 6),
            zone
        )
    )
    do
        item := (id mod 32) * 16;
        return (zone[item + 2] >> 10) | (zone[item + 3] << 6);
    end
    return 0;
end

minixfs_load_zone(fs, id, pos, dest) do
! Load one zone from item in fs(direct OBJ_FS)
    var zone::1024, item;
    ie(id = 0) id := 1; else id := id - 1;
    if(fs[FS_STATUS] \= STATUS_FS_MOUNTED) return FALSE;
    if(fs[MINIXFS_TOTAL_ITENS] < id) return FALSE;
!term_kwrites("[LOAD ID ");
!t.writenum(T3X.SYSERR, id);
!term_kwrites(" POS ");
!t.writenum(T3X.SYSERR, pos);
!term_kwrites(" ZONE ");
!t.writenum(T3X.SYSERR, fs[MINIXFS_LIST_ITENS]);
!term_kwrites("]");
    if
    (
        minixfs_read_zone
        (
            fs[FS_DISK], 
            fs[MINIXFS_LIST_ITENS] + (id >> 6),
            zone
        )
    )
    do
        item := (id mod 32) * 16;
        ie(pos < 7) do ! direct zone
            if(zone[item + pos + 7] = 0) return FALSE;
            if
            (
                minixfs_read_zone
                (
                    fs[FS_DISK], 
                    zone[item + pos + 7],
                    dest
                )
            ) return TRUE;
        end
        else ie (pos < 519) do ! indirect zone
            if
            (
                minixfs_read_zone
                (
                    fs[FS_DISK], 
                    zone[item + 14],
                    zone
                )
            )
            do
                if(zone[pos - 7] = 0) return FALSE;
                if
                (
                    minixfs_read_zone
                    (
                        fs[FS_DISK], 
                        zone[pos - 7],
                        dest
                    )
                ) return TRUE;
            end
        end
        else do ! double indirect zone
        end
    end
    return 0;
end

minixfs_store_zone(fs, id, pos, orig) do
! Store one zone from item in fs(direct OBJ_FS)
    var zone::1024, item;
    ie(id = 0) id := 1; else id := id - 1;
    if(fs[FS_STATUS] \= STATUS_FS_MOUNTED) return FALSE;
    if(fs[MINIXFS_TOTAL_ITENS] < id) return FALSE;
    if
    (
        minixfs_read_zone
        (
            fs[FS_DISK], 
            fs[MINIXFS_LIST_ITENS] + (id / 32),
            zone
        )
    )
    do
        item := (id mod 32) * 16;
        ie(pos < 7) do ! direct zone
            if(zone[item + pos + 7] = 0) return FALSE;
            if
            (
                minixfs_write_zone
                (
                    fs[FS_DISK], 
                    zone[item + pos + 7],
                    orig
                )
            ) return TRUE;
        end
        else ie (pos < 519) do ! indirect zone
            if
            (
                minixfs_read_zone
                (
                    fs[FS_DISK], 
                    zone[item + 14],
                    zone
                )
            )
            do
                if(zone[pos - 7] = 0) return FALSE;
                if
                (
                    minixfs_write_zone
                    (
                        fs[FS_DISK], 
                        zone[pos - 7],
                        orig
                    )
                ) return TRUE;
            end
        end
        else do ! double indirect zone
        end
    end
    return 0;
end

_minixfs_avail(stream, ret) far do
    ret[RET_OK] := TRUE;
end

_minixfs_seek(stream, pos_low, pos_high, ret) far do
! Seek on file
    ret[RET_OK] := FALSE;
    if(stream[STREAM_STATUS] = STATUS_CLOSE) return;
    stream[STREAM_MINIXFS_ZONE] := (pos_low >> 10) | (pos_high << 6);
    stream[STREAM_MINIXFS_POS] := pos_low & 0x3ff;
    ret[RET_OK] := TRUE;
end

_minixfs_can_read(stream, ret) far do
! Return if can read
    ret[RET_OK] := FALSE;
    if(stream[STREAM_STATUS] = STATUS_CLOSE) return;
    ret[RET_OK] := TRUE;
end

_minixfs_read(stream, seg, dest, len, ret) far do
! Read block from file
    var zone::1024, read_len, calc, zone_pos, fs[OBJ_FS], last_zone, last_size;
    read_len := 0;
    ret[RET_OK] := FALSE;
    ret[RET_VALUE] := 0;
    if(stream[STREAM_STATUS] = STATUS_CLOSE) return;
    t.farcopy
    (
        t.stack(), 
        fs, 
        t.local(), 
        t.fargetw(t.local(),
            t.fargetw(t.local(), @FSList)) + (stream[STREAM_MINIXFS_FS] << 1), 
        OBJ_FS << 1
    );
    last_zone := minixfs_last_zone_pos(fs, stream[STREAM_MINIXFS_ID]);
    last_size := minixfs_last_zone_size(fs, stream[STREAM_MINIXFS_ID]);
    while
    (
        minixfs_load_zone
        (
            fs, 
            stream[STREAM_MINIXFS_ID],
            stream[STREAM_MINIXFS_ZONE],
            zone
        )
    )
    do
        if(stream[STREAM_MINIXFS_POS] >= 1024) do
            stream[STREAM_MINIXFS_ZONE] := stream[STREAM_MINIXFS_ZONE]+1;
            stream[STREAM_MINIXFS_POS] := stream[STREAM_MINIXFS_POS]-1024;
        end
        zone_pos := stream[STREAM_MINIXFS_POS];
        calc := 1024 - zone_pos;
        if(last_zone = stream[STREAM_MINIXFS_ZONE])do
            calc := last_size - zone_pos;
            if(calc < 0) calc := 0; 
        end
        if(last_zone < stream[STREAM_MINIXFS_ZONE]) return;
        ie(len > calc)do
            t.farcopy(seg, dest + read_len, t.stack(), zone + zone_pos, calc);
            read_len := read_len + calc;
            stream[STREAM_MINIXFS_ZONE] := stream[STREAM_MINIXFS_ZONE] + 1;
            stream[STREAM_MINIXFS_POS] := 0;
        end
        else do
            t.farcopy(seg, dest + read_len, t.stack(), zone + zone_pos, len);
            read_len := read_len + len;
            stream[STREAM_MINIXFS_POS] := stream[STREAM_MINIXFS_POS] + len;
            if(stream[STREAM_MINIXFS_POS] >= 1024) do
                stream[STREAM_MINIXFS_ZONE] := stream[STREAM_MINIXFS_ZONE]+1;
                stream[STREAM_MINIXFS_POS] := stream[STREAM_MINIXFS_POS]-1024;
            end
            leave;
        end
    end
    ret[RET_OK] := TRUE;
    ret[RET_VALUE] := read_len;
end

_minixfs_can_write(stream, ret) far do
! Return if can write
    ret[RET_OK] := FALSE;
    if(stream[STREAM_STATUS] = STATUS_CLOSE) return;
    ret[RET_OK] := TRUE;
end

_minixfs_write(stream, seg, orig, len, ret) far do
! Write block on file
    ret[RET_OK] := FALSE;
end

_minixfs_close(stream, ret) far do
! Close file
    var fs[OBJ_FS];
    ret[RET_OK] := TRUE;
    if(stream[STREAM_STATUS] = STATUS_CLOSE) return;
    stream[STREAM_STATUS] := STATUS_CLOSE;
    t.farcopy
    (
        t.stack(), 
        fs, 
        t.local(), 
        t.fargetw(t.local(),FSList) + (stream[STREAM_MINIXFS_FS] << 1), 
        OBJ_FS << 1
    );
    fs[MINIXFS_OPENED_COUNT] := fs[MINIXFS_OPENED_COUNT] - 1;
    t.farcopy
    (
        t.local(), 
        t.fargetw(t.local(),FSList) + (stream[STREAM_MINIXFS_FS] << 1), 
        t.stack(), 
        fs, 
        OBJ_FS << 1
    );

end

_minixfs_open(item, stream, ret) far do
! Open file item
    var fs[OBJ_FS];
    ret[RET_OK] := FALSE;
    if(item[ITEM_TYPE] \= TYPE_FILE) return;
    new(
        stream, 
        t.local(), 
        @_minixfs_avail, @_minixfs_seek, 
        @_minixfs_can_read, @_minixfs_read, 
        @_minixfs_can_write, @_minixfs_write
        );
    stream[STREAM_PTR_CLOSE] := @_minixfs_close;
    stream[STREAM_MINIXFS_POS] := 0;
    stream[STREAM_MINIXFS_ZONE] := 0;
    stream[STREAM_MINIXFS_ID] := item[ITEM_ID];
    stream[STREAM_MINIXFS_FS] := item[ITEM_FS];
    t.farcopy
    (
        t.stack(), 
        fs, 
        t.local(), 
        t.fargetw(t.local(),FSList) + (stream[STREAM_MINIXFS_FS] << 1), 
        OBJ_FS << 1
    );
    fs[MINIXFS_OPENED_COUNT] := fs[MINIXFS_OPENED_COUNT] + 1;
    t.farcopy
    (
        t.local(), 
        t.fargetw(t.local(),FSList) + (stream[STREAM_MINIXFS_FS] << 1), 
        t.stack(), 
        fs, 
        OBJ_FS << 1
    );
    ret[RET_OK] := TRUE;
end

_minixfs_first_item(fs, id, item, ret) far do
! Read first sub-item from item id
    var zone::1024, pos_item;
    if(id = 0) id := 1;
    ret[RET_OK] := FALSE;
    if(fs[FS_STATUS] \= STATUS_FS_MOUNTED) return;
    if(fs[MINIXFS_TOTAL_ITENS] < id) return;
    if(\minixfs_load_zone(fs, id, 0, zone)) return;
    if(zone[0] = 0) return;
    new_item(item, TYPE_FILE, t.local(), @_minixfs_open, id, zone[0]);
    item[ITEM_POS_ON_PARENT] := 0;
    item[ITEM_FS] := fs[FS_ID];
    t.farcopy(t.stack(), item[ITEM_NAME], t.stack(), @zone[1], 30);
    if
    (
        minixfs_read_zone
        (
            fs[FS_DISK], 
            fs[MINIXFS_LIST_ITENS] + ((item[ITEM_ID]-1) / 32),
            zone
        )
    )
    do
        pos_item := ((item[ITEM_ID] - 1) mod 32) * 16;
        ie((zone[pos_item] & 0x4000) = 0x4000)
            item[ITEM_TYPE] := TYPE_DIRECTORY;
        else ie((zone[pos_item] & 0x8000) = 0x8000)
            item[ITEM_TYPE] := TYPE_FILE;
        else item[ITEM_TYPE] := TYPE_UNKNOWN;
    end
    ret[RET_OK] := TRUE;
end

_minixfs_next_item(fs, item, ret) far do
! Read next item from existent item
    var zone::1024, pos, id, pos_item;
    id := item[ITEM_PARENT_ID];
    ret[RET_OK] := FALSE;
    if(fs[FS_STATUS] \= STATUS_FS_MOUNTED) return;
    if(fs[MINIXFS_TOTAL_ITENS] < id) return;
    pos := item[ITEM_POS_ON_PARENT] + 1;
    if(\minixfs_load_zone(fs, id, pos / 32, zone)) return;
    if(zone[(pos mod 32) * 16] = 0) return;
    new_item(item, TYPE_FILE, t.local(), @_minixfs_open, id, 
        zone[(pos mod 32) * 16]);
    t.farcopy(t.stack(), item[ITEM_NAME], t.stack(), 
        @zone[(pos mod 32) * 16 + 1], 30);
    item[ITEM_POS_ON_PARENT] := pos;
    item[ITEM_FS] := fs[FS_ID];
    if
    (
        minixfs_read_zone
        (
            fs[FS_DISK], 
            fs[MINIXFS_LIST_ITENS] + ((item[ITEM_ID]-1) / 32),
            zone
        )
    )
    do
        pos_item := ((item[ITEM_ID] - 1) mod 32) * 16;
        ie((zone[pos_item] & 0x4000) = 0x4000)
            item[ITEM_TYPE] := TYPE_DIRECTORY;
        else ie((zone[pos_item] & 0x8000) = 0x8000)
            item[ITEM_TYPE] := TYPE_FILE;
        else item[ITEM_TYPE] := TYPE_UNKNOWN;
    end
    ret[RET_OK] := TRUE;
end

_minixfs_umount(fs, ret) far do
! Umount partition
    ret[RET_OK] := fs[MINIXFS_OPENED_COUNT] = 0;
end

minixfs_mount(disk) do
! Mount Minix File System
    var zone::1024, fs, pos;
    if(\minixfs_read_zone(disk, 1, zone)) return FALSE;
    if(zone[8] \= 5007) return FALSE; ! MinixFS v1 30 Char Signature
    fs := fs_reg
    (
        disk,
        t.local(),
        @_minixfs_first_item,
        @_minixfs_next_item,
        @_minixfs_umount
    );
    if(fs < 0) return FALSE;
    pos := 2;
    FSList[fs][MINIXFS_MAP_ITENS] := pos;
    pos := pos + zone[2];
    FSList[fs][MINIXFS_MAP_ITENS_SIZE] := zone[2];
    FSList[fs][MINIXFS_MAP_ZONES] := pos;
    pos := pos + zone[3];
    FSList[fs][MINIXFS_MAP_ZONES_SIZE] := zone[3];
    FSList[fs][MINIXFS_LIST_ITENS] := pos;
    FSList[fs][MINIXFS_TOTAL_ITENS] := zone[0];
    FSList[fs][MINIXFS_TOTAL_ZONES] := zone[1];
    FSList[fs][MINIXFS_LIST_ITENS_SIZE] := zone[0] / 32;
    return TRUE;
end

minixfs_init() do
! Initialize buffer
    MinixFSBuffer0 := 0;
    MinixFSBuffer1 := 0;
    MinixFSBuffer2 := 0;
    MinixFSBuffer3 := 0;
end

! ==========================================================================
! Process Management
! ==========================================================================

const TOTAL_PROCESS = 32;

const STATUS_PROCESS_EMPTY = 0;
const STATUS_PROCESS_RUNING = 1;
const STATUS_PROCESS_WAINTING = 2;
const STATUS_PROCESS_BACKEND = 3;

struct OBJ_PROCESS =
! Process
    PROCESS_ID,
    PROCESS_PARENT_ID,
    PROCESS_SEG,
    PROCESS_SP,
    PROCESS_BP,
    PROCESS_CS,
    PROCESS_IP,
    PROCESS_STATUS,
    PROCESS_WAITING_ID,
    PROCESS_RET;

var ProcessList[TOTAL_PROCESS], ProcessData[TOTAL_PROCESS * OBJ_PROCESS];
var ProcessCurrent, ProcessKernel;

new_process() do
    var i, ptr;
    for(i=1,TOTAL_PROCESS) do
        ptr :=t.fargetw(t.local(),t.fargetw(t.local(),@ProcessList)+(i << 1));
        if
        (
            t.fargetw(t.local(), ptr + (PROCESS_STATUS<<1)) = 
            STATUS_PROCESS_EMPTY
        ) 
        do
            t.farsetw(t.local(), ptr + (PROCESS_SEG<<1), 0);
            t.farsetw(t.local(), ptr + (PROCESS_IP<<1), 0);
            t.farsetw(t.local(), ptr + (PROCESS_SP<<1), 0);
            t.farsetw(t.local(), ptr + (PROCESS_BP<<1), 0);
            t.farsetw(t.local(), ptr + (PROCESS_STATUS<<1), 
                STATUS_PROCESS_RUNING);
            return i;
        end
    end
    return 0;
end

process_set_segs(id, seg, sp, bp, cs, ip)do
    var ptr;
    ptr := t.fargetw(t.local(),t.fargetw(t.local(), @ProcessList)+(id << 1));
    t.farsetw(t.local(), ptr + (PROCESS_SEG<<1), seg);
    t.farsetw(t.local(), ptr + (PROCESS_CS<<1), cs);
    t.farsetw(t.local(), ptr + (PROCESS_IP<<1), ip);
    t.farsetw(t.local(), ptr + (PROCESS_SP<<1), sp);
    t.farsetw(t.local(), ptr + (PROCESS_BP<<1), bp);
end

process_get_seg(id)do
    var ptr;
    ptr := t.fargetw(t.local(),t.fargetw(t.local(), @ProcessList)+(id << 1));
    return t.fargetw(t.local(), ptr + (PROCESS_SEG<<1));
end

process_get_cs(id)do
    var ptr;
    ptr := t.fargetw(t.local(),t.fargetw(t.local(), @ProcessList)+(id << 1));
    return t.fargetw(t.local(), ptr + (PROCESS_CS<<1));
end

process_get_sp(id)do
    var ptr;
    ptr := t.fargetw(t.local(),t.fargetw(t.local(), @ProcessList)+(id << 1));
    return t.fargetw(t.local(), ptr + (PROCESS_SP<<1));
end

process_get_bp(id)do
    var ptr;
    ptr := t.fargetw(t.local(),t.fargetw(t.local(), @ProcessList)+(id << 1));
    return t.fargetw(t.local(), ptr + (PROCESS_BP<<1));
end

process_get_ip(id)do
    var ptr;
    ptr := t.fargetw(t.local(),t.fargetw(t.local(), @ProcessList)+(id << 1));
    return t.fargetw(t.local(), ptr + (PROCESS_IP<<1));
end

process_get_status(id)do
    var ptr;
    ptr := t.fargetw(t.local(),t.fargetw(t.local(), @ProcessList)+(id << 1));
    return t.fargetw(t.local(), ptr + (PROCESS_STATUS<<1));
end

process_set_status(id, status)do
    var ptr;
    ptr := t.fargetw(t.local(),t.fargetw(t.local(), @ProcessList)+(id << 1));
    t.farsetw(t.local(), ptr + (PROCESS_STATUS<<1), status);
end

process_get_ret(id)do
    var ptr;
    ptr := t.fargetw(t.local(),t.fargetw(t.local(), @ProcessList)+(id << 1));
    return t.fargetw(t.local(), ptr + (PROCESS_RET<<1));
end

process_set_ret(id, ret)do
    var ptr;
    ptr := t.fargetw(t.local(),t.fargetw(t.local(), @ProcessList)+(id << 1));
    t.farsetw(t.local(), ptr + (PROCESS_RET<<1), ret);
end

process_get_parent(id)do
    var ptr;
    ptr := t.fargetw(t.local(),t.fargetw(t.local(), @ProcessList)+(id << 1));
    return t.fargetw(t.local(), ptr + (PROCESS_PARENT_ID<<1));
end

process_set_parent(id, parent_id)do
    var ptr;
    ptr := t.fargetw(t.local(),t.fargetw(t.local(), @ProcessList)+(id << 1));
    t.farsetw(t.local(), ptr + (PROCESS_PARENT_ID<<1), parent_id);
end

process_get_current()do
    return t.fargetw(t.local(), @ProcessCurrent);
end

process_set_current(id)do
    t.farsetw(t.local(), @ProcessCurrent, id);
end

process_init() do
    var i;
    for(i=0,TOTAL_PROCESS) do
        ProcessList[i] := @ProcessData[OBJ_PROCESS * i];
        ProcessList[i][PROCESS_ID] := i;
        ProcessList[i][PROCESS_STATUS] := STATUS_PROCESS_EMPTY;
    end
    ProcessKernel := new_process();
    process_set_segs(ProcessKernel, t.local(), 0xff00, 0xff00, 
        t.local(), 256);
    ProcessCurrent := ProcessKernel;
end

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
    var buffer::256, exec_stream[OBJ_STREAM];

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
        stream_buffer_init(buffer, 256);
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