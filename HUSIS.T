! HUSIS - Kernel
! Humberto Costa dos Santos Junior, 2022
! 3-Clause BSD license
! Operating System for IBM PC and compatibles
!
!  This Operating System implements minimum INT 0x21 function set to run 
!  T3X/86 applications and Old-School Assembler without modifications.
!

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


!
! String/Character
!

char_is_num(c) return (c >= '0') & (c <= '9');
char_is_upper(c) return (c >= 'A') & (c <= 'Z');
char_is_lower(c) return (c >= 'a') & (c <= 'z');
char_is_alpha(c) return char_is_lower(c) | char_is_upper(c);
char_is_alphanum(c) return char_is_alpha(c) | char_is_num(c);

str_len(txt) 
! Get ASCIZ string length
    return t.memscan(txt, 0, 2048);

str_copy(orig, dest) 
! Copy string contents to another
    t.memcopy(dest, orig, str_len(orig)+1);

str_concat(orig, dest)
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

rstr_len(seg, txt) 
! Get ASCIZ string length from remote string
    return t.farscan(seg, txt, 0, 2048);

rstr_copy(sego, orig, segd, dest) 
! Copy retmote string contents to another remote string 
    t.farcopy(segd, dest, sego, orig, rstr_len(sego, orig)+1);

rstr_concat(sego, orig, segd, dest)
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

!
! Generic functions
!

t.writes(file, str) t.write(file, str, str_len(str));
! Write string to file

t.writeln(file, str) do
! Write line string to file
    t.write(file, str, str_len(str));
    t.write(file, "\r\n", 2);
end

t.writec(file, c) do
! Write char to file
    var str::2;
    str::0 := c;
    str::1 := 0;
    t.write(file, str, 1);
end

t.writenum(file, value) do
! Write number to file
    var tmp, tmp2;
    if(value < 0) do
        t.writec(file, '-');
        value := -value;
    end
    tmp := value mod 10;
    tmp2 := value / 10;
    if (tmp2 > 0) t.writenum(file, tmp2);
    t.writec(file, tmp + '0'); 
end

!
! I/O STREAM (Generic API)
!

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
    STREAM_AUX6;

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

stream_read(stream, buffer, len) do
! Read from stream
    var ret[OBJ_RET];
    var ptr::T3X.PTRSIZE;
    if(stream[STREAM_SEG] = 0) return 0;
    if(stream[STREAM_PTR_READ] = 0) return 0;
    t.setptr(ptr, 
        stream[STREAM_SEG],
        stream[STREAM_PTR_READ]);
    callfar ptr(stream, t.local(), buffer, len, ret);
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
    callfar ptr(stream, t.local(), buffer, len, ret);
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
    if(value < 0) do
        stream_write_char(stream, '-');
        value := -value;
    end
    tmp := value mod 16;
    tmp2 := value / 16;
    if (tmp2 > 0) stream_write_hex(stream, tmp2);
    ie (tmp < 10) stream_write_char(stream, tmp + '0'); 
    else stream_write_char(stream, tmp + 'a' - 10);
end

!
! Terminal I/O using Stream API
!
struct COLORS = BLACK, DARK_BLUE, DARK_GREEN, DARK_CYAN, DARK_RED,
                DARK_MAGENTA, BROWN, DARK_GRAY, LIGHT_GRAY,
                LIGHT_BLUE, LIGHT_GREEN, LIGHT_CYAN, LIGHT_RED, LIGHT_MAGENTA, 
                LIGHT_YELLOW, WHITE;

const TERM_X = STREAM_AUX1;
const TERM_Y = STREAM_AUX2;
const TERM_COLORS = STREAM_AUX3;
const TERM_CMD = STREAM_AUX4;
const TERM_CMD_POS = STREAM_AUX5;
const TERM_VALUE = STREAM_AUX6;

term_cls(stream) do
! Clear screen
    var i;
    stream[TERM_CMD_POS] := 0;
    stream[TERM_Y] := 0;
    stream[TERM_X] := 0;
    stream[STREAM_PTR_BUFFER] := 0;
    for(i=0,25*80) do
        t.farsetw(stream[STREAM_SEG_BUFFER], i<<1, ' ' | (stream[TERM_COLORS] << 8));
    end
end

term_calc_pos(stream, x, y) do
! Calculate new position
    stream[TERM_X] := x;
    stream[TERM_Y] := y;
    stream[STREAM_PTR_BUFFER] := (stream[TERM_Y] * 80 + stream[TERM_X]) << 1;
    if(stream[TERM_X] > 79) do
        stream[TERM_X] := stream[TERM_X] - 80;
        stream[TERM_Y] := stream[TERM_Y] + 1;
    end
    if(stream[TERM_Y] > 24) do
        stream[STREAM_PTR_BUFFER] := 0;
        stream[TERM_Y] := 0;
    end
end

term_colors_set(stream, front, back) do
! Set new colors to output
    stream[TERM_COLORS] := (back << 12) | (front << 8);
end

term_color_front(stream, front) do
! Set front color
    stream[TERM_COLORS] := (stream[TERM_COLORS] & 0xf000) | (front << 8);
end

term_color_back(stream, back) do
! Set back color
    stream[TERM_COLORS] :=  (stream[TERM_COLORS] & 0x0f00) | (back << 12);
end

term_write_char(stream, c) do
! Write char to screen
!
! Special escape commands:
! \ec       = Clear screen
! \ex00     = Set X position (00-80)
! \ey00     = Set Y position (00-25)
! \ef00     = Set front color (00-15)
! \eb00     = Set back color (00-15)
! \er00C    = Repeat C character 00 times (00-99)
!
    var i;
    if(c = '\e') do
    stream[TERM_CMD_POS] := 1;
    return;
    end
    if(stream[TERM_CMD_POS] > 0) do
        ie(stream[TERM_CMD_POS] = 1) do
            stream[TERM_VALUE] := 0;
            stream[TERM_CMD_POS] := 0;
            stream[TERM_CMD] := c;
            ie(c = 'c') term_cls(stream);
            else ie(c = 'f') stream[TERM_CMD_POS] := 2;
            else ie(c = 'b') stream[TERM_CMD_POS] := 2;
            else ie(c = 'x') stream[TERM_CMD_POS] := 2;
            else ie(c = 'y') stream[TERM_CMD_POS] := 2;
            else ie(c = 'r') stream[TERM_CMD_POS] := 2;
            else stream[TERM_CMD_POS] := 0;
        end 
        else ie(stream[TERM_CMD_POS] = 2) do
            stream[TERM_CMD_POS] := 3;
            if(\char_is_num(c)) stream[TERM_CMD_POS] := 0;
            stream[TERM_VALUE] := (c - '0') * 10;
        end
        else ie(stream[TERM_CMD_POS] = 3) do
            stream[TERM_CMD_POS] := 0;
            if(\char_is_num(c)) return;
            stream[TERM_VALUE] := (c - '0') + stream[TERM_VALUE];
            ie(stream[TERM_CMD] = 'x') term_calc_pos(stream, stream[TERM_VALUE], stream[TERM_Y]);
            else ie(stream[TERM_CMD] = 'y') term_calc_pos(stream, stream[TERM_X], stream[TERM_VALUE]);
            else ie(stream[TERM_CMD] = 'r') stream[TERM_CMD_POS] := 4;
            else ie(stream[TERM_CMD] = 'f') term_color_front(stream, stream[TERM_VALUE]);
            else ie(stream[TERM_CMD] = 'b') term_color_back(stream, stream[TERM_VALUE]);
            else stream[TERM_CMD_POS] := 0;
        end
        else ie(stream[TERM_CMD_POS] = 4) do
            stream[TERM_CMD_POS] := 0;
            if(stream[TERM_CMD] = 'r') for(i=0,stream[TERM_VALUE]) term_write_char(stream, c);
        end
        else stream[TERM_CMD_POS] := 0;
        return;
    end
    if(c = 13) do
        term_calc_pos(stream, 0, stream[TERM_Y]);
        return;
    end
    if(c = 10) do
        term_calc_pos(stream, 0, stream[TERM_Y] + 1);
        return;
    end
    if(c = 8) do
        ie(stream[TERM_X] = 0)
            term_calc_pos(stream, 79, stream[TERM_Y] - 1);
        else
            term_calc_pos(stream, stream[TERM_X] - 1, stream[TERM_Y]);
        return;
    end
    if(c = 9) do
        c := ' ';
    end
    t.farsetw(stream[STREAM_SEG_BUFFER], stream[STREAM_PTR_BUFFER], c | stream[TERM_COLORS]);
    stream[STREAM_PTR_BUFFER] := stream[STREAM_PTR_BUFFER] + 2;
    stream[TERM_X] := stream[TERM_X] + 1;
    if(stream[TERM_X] > 79) do
        stream[TERM_X] := 0;
        stream[TERM_Y] := stream[TERM_Y] + 1;
    end
    if(stream[TERM_Y] > 24) do
        stream[STREAM_PTR_BUFFER] := 0;
        stream[TERM_Y] := 0;
    end
end

term_read_char(stream) do
! Read key from keyboard using BIOS
    return t.int86ax(0x16, 0,0,0,0, 0,0) & 0xff;
end

_term_avail(stream, ret) far do
! Check if has key avail
    ret[RET_OK] := (t.int86z(0x16, 0x100,0,0,0, 0,0) = 1) -> 0 : 1;
    ret[RET_VALUE] := ret[RET_OK] -> 1 : 0;
end

_term_seek(stream, pos_low, pos_high, ret) ret[RET_OK] := FALSE;
! (NOT SUPPORTED) Seek on keyboard stream

_term_can_read(stream, ret) far do
! Return if can read
    ret[RET_OK] := TRUE;
end 

_term_read(stream, seg, dest, len, ret) far do
! Read line string from keyboard showing on screen
    var pos, c;
    pos := 0;
    dest::pos := 0;
    term_write_char(stream, '_');
    while(%1) do
        c := term_read_char(stream);
        if (c = 0xd) leave;
        if (c = 0xa) leave;
        ie (c = 0x8) do
            if (pos = 0) loop;
            term_write_char(stream, c);
            term_write_char(stream, c);
            term_write_char(stream, '_');
            term_write_char(stream, ' ');
            term_write_char(stream, c);
            pos := pos - 1;
        end
        else do
            if ((pos + 2) > len) loop;
            dest::pos := c;
            term_write_char(stream, 8);
            term_write_char(stream, c);
            term_write_char(stream, '_');
            pos := pos + 1;
        end
        dest::pos := 0;
    end
    term_write_char(stream, 8);
    term_write_char(stream, ' ');
    term_write_char(stream, 13);
    term_write_char(stream, 10);
    ret[RET_OK] := pos > 0;
    ret[RET_VALUE] := pos;
end 

_term_can_write(stream, ret) far do
! Return if can write
    ret[RET_OK] := TRUE;
end 

_term_write(stream, seg, orig, len, ret) far do
! Write to screen
    var i;
    for(i=0,len) do
        term_write_char(stream, t.fargetb(seg, orig + i));
    end
end 

term_new_stream(stream) do
! Create new Terminal Stream
    new(stream, t.local(), 
        @_term_avail, @_term_seek, @_term_can_read, @_term_read,
        @_term_can_write, @_term_write);
    buffer_set(stream, 0xb800, 0, 80*25*2);
    term_calc_pos(stream, 0, 0);
    term_colors_set(stream, DARK_GRAY, BLACK);
end

term_init() do
    ! Hiding cursor
    t.int86ax(0x10, 0x100,0,0x2020,0,0,0);
    ! Initialize Standard I/O
    term_new_stream(StreamIO);
    StreamIn := StreamIO;
    StreamOut := StreamIO;
    StreamErr := StreamIO;
end

!
! File System Infrastructure
!

const TOTAL_FS = 16;

const STATUS_FS_AVAIL = 0;
const STATUS_FS_MOUNTED = 1;


struct OBJ_FS = 
! File System Object
    FS_STATUS,
    FS_DISK,
    FS_SEG,
    FS_PTR_FIRST_ITEM,
    FS_PTR_NEXT_ITEM,
    FS_PTR_UMOUNT;

var FSList[TOTAL_FS], FSData[OBJ_FS * TOTAL_FS];

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
        FSList[i][FS_STATUS] := STATUS_FS_AVAIL;
    end
end

!
! BIOS Disk I/O using Stream API
!
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

!
! Memory Manager
!

mem_total_kib() do
    return t.int86ax(0x12,0,0,0,0,0,0);
end

!
! Minix File System
!

minixfs_read_zone(disk, position, dest) do
! Read zones (1024 bytes disk block) using 512 bytes physical blocks
    if(\stream_seek(DiskList[disk], position << 1, 0)) return FALSE;
    if(stream_read(DiskList[disk], dest, 512) = 0) return FALSE;
    if(\stream_seek(DiskList[disk], (position << 1) + 1, 0)) return FALSE;
    if(stream_read(DiskList[disk], @dest::512, 512) = 0) return FALSE;
    return TRUE;
end

minixfs_mount(disk) do
! Mount Minix File System
    var zone::1024;
    if(\minixfs_read_zone(disk, 1, zone)) return FALSE;
    if(zone[8] \= 5007) return FALSE; ! MinixFS v1 30 Char Signature
!
! TODO: Implement interpretation of MinixFS Super block data
!
    return TRUE;
end


!
! Interrupt Handlers
!

int_set(ptr_ant, int, funcao) do
! Set new Interrupt Handler, store previous handler to restore
    t.setptr(ptr_ant, t.fargetw(0, int*4+2), t.fargetw(0, int*4));
    t.farsetw(0, int*4, funcao);
    t.farsetw(0, int*4+2, t.local());
end

int_restore(ptr_ant, int) do
! Restore stored interrupt handler
    t.farsetw(0, int*4, t.getoff(ptr_ant));
    t.farsetw(0, int*4+2, t.getseg(ptr_ant));
end

int_debug(int,ax,bx,cx,dx,ds,si,es,di) do
! Show calling args on screen
    stream_writes(StreamErr, "[INT 0x");
    stream_write_hex(StreamErr, int);
    stream_writes(StreamErr, " AX ");
    stream_write_num(StreamErr, ax);
    stream_writes(StreamErr, " AH 0x");
    stream_write_hex(StreamErr, ax >> 8);
    stream_writes(StreamErr, " BX ");
    stream_write_num(StreamErr, bx);
    stream_writes(StreamErr, " CX ");
    stream_write_num(StreamErr, cx);
    stream_writes(StreamErr, " DX ");
    stream_write_num(StreamErr, dx);
    stream_writes(StreamErr, " DS ");
    stream_write_num(StreamErr, es);
    stream_writes(StreamErr, " SI ");
    stream_write_num(StreamErr, si);
    stream_writes(StreamErr, " ES ");
    stream_write_num(StreamErr, es);
    stream_writes(StreamErr, " DI ");
    stream_write_num(StreamErr, di);
    stream_writes(StreamErr, "]\r\n");
end

int79(ax,bx,cx,dx,ds,si,es,di,ss,sp) farint do
! HUSIS API
    int_debug(0x20, ax,bx,cx,dx,ds,si,es,di);
    return 0;
end

int20(ax,bx,cx,dx,ds,si,es,di,ss,sp) farint do
! DOS API
    int_debug(0x20, ax,bx,cx,dx,ds,si,es,di);
end

int21(ax,bx,cx,dx,ds,si,es,di,ss,sp) farint do
! DOS API
    var func, al, preserve;
    func := ax >> 8;
    al := ax & 0xff;
    ie(func = 0x40) do ! DOS WRITE
        ie(bx = 1) do ! SYSOUT
            stream_write(StreamOut, dx, cx);
        end
        else ie(bx = 2) do ! SYSERR
            preserve := StreamErr[TERM_COLORS];
            StreamErr[TERM_COLORS] := 4 << 8;
            stream_write(StreamErr, dx, cx);
            StreamErr[TERM_COLORS] := preserve;
        end
        else int_debug(0x20, ax,bx,cx,dx,ds,si,es,di);
    end
    else ie(func = 0x3f) do ! DOS READ
        ie(bx = 0) do ! SYSIN
            stream_read(StreamIn, dx, cx);
        end
        else int_debug(0x20, ax,bx,cx,dx,ds,si,es,di);
    end
    else int_debug(0x20, ax,bx,cx,dx,ds,si,es,di);
end

!
! Main
!

var Int79Ant[T3X.PTRSIZE], Int20Ant[T3X.PTRSIZE], Int21Ant[T3X.PTRSIZE];
! Previous Interrupt Handlers

shutdown() do
! Shutdown HUSIS
    t.writeln(T3X.SYSOUT, "\r\n\ef03SYSTEM STOPPED.");

    ! Restore Interrupts
    int_restore(Int79Ant, 0x79);
    int_restore(Int20Ant, 0x20);
    int_restore(Int21Ant, 0x21);

    if(Mode = MODE_STANDALONE) t.int86ax(0x18, 0,0,0,0 ,0,0); ! Reboot
    if(Mode = MODE_DOS_APP)t.int86ax(0x21, 0x4d00,0,0,0, 0,0); ! exit to DOS
end

fatal_error(msg) do
! Display fatal error and shutdown (My own 'blue screen of death' =) )
    var tmp::1;
    t.writes(T3X.SYSERR, "\r\nFATAL ERROR: ");
    t.writeln(T3X.SYSERR, msg);
    t.writes(T3X.SYSERR, "\r\nPress ENTER to shutdown.\r\n");
    t.read(T3X.SYSIN, tmp, 0);
    shutdown();
end

do
! Main routine, initialize operating system
    var arg::15, arg_disk, arg_cil, arg_head, arg_sect, arg_ok;
    var disk;
    ! Replace INT 20(DOS API), 21(DOS API) and INT 79(HUSIS API)
    int_set(Int79Ant, 0x79, @int79);
    int_set(Int21Ant, 0x20, @int20);
    int_set(Int21Ant, 0x21, @int21);

    ! Verify current ambient
    ie(t.fargetw(t.local(), 0x10) = 1989)
        Mode := MODE_STANDALONE;
    else
        Mode := MODE_DOS_APP;

    ! Initialize
    term_init();
    disk_init();
    fs_init();

    ! HUSIS Banner using DOS API implemented by HUSIS
    t.writes(T3X.SYSOUT, "\ec\ef03HUSIS \ef04v0.1\ef07 [RAM: ");
    t.writenum(T3X.SYSOUT, mem_total_kib());
    t.writeln(T3X.SYSOUT, " KiB]");
    t.writeln(T3X.SYSOUT, "Copyright (c) 2022, Humberto Costa dos Santos Junior");
    t.writeln(T3X.SYSOUT, "Build using \ef03T3X/86\ef07 Compiler");
    t.writeln(T3X.SYSOUT, "License: 3-Clause BSD");
    if(Mode = MODE_DOS_APP) t.writeln(T3X.SYSERR, "DOS Application Mode");
    t.writes(T3X.SYSOUT, "\er80=");

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
        t.writes(T3X.SYSOUT, "Mounting Disk ");
        t.writenum(T3X.SYSOUT, arg_disk);
        t.writes(T3X.SYSOUT, " [C:");
        t.writenum(T3X.SYSOUT, arg_cil);
        t.writes(T3X.SYSOUT, " H:");
        t.writenum(T3X.SYSOUT, arg_head);
        t.writes(T3X.SYSOUT, " S:");
        t.writenum(T3X.SYSOUT, arg_sect);
        t.writes(T3X.SYSOUT, "]");
        ! Create disk
        disk := disk_reg(arg_disk, arg_cil, arg_head, arg_sect);
        t.writes(T3X.SYSOUT, " .");
        ! Mount disk using MinixFS
        if(\minixfs_mount(disk)) fatal_error("Disk corrupted.");
        t.writeln(T3X.SYSOUT, " [ OK ]");
!
! TODO: Implement:
!       - Read config file
!       - Read and execute Command Prompt using parameters on config file
!
    end
    else do
        fatal_error(
        "Disk parameters incomplete. Use: DISK_ID CILINDERS HEADS SECTORS"
        );
    end

    t.writes(T3X.SYSOUT, "\n\n\n\n\rPress ENTER to shutdown.");
    t.read(T3X.SYSIN, arg, 0);

    ! Shutdown system
    shutdown();
end

