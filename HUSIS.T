! HUSIS - Kernel
! Humberto Costa dos Santos Junior, 2022
! 3-Clause BSD license
! Operating System for IBM PC and compatibles
!
!  This Operating System implements minimum INT 0x21 function set to run 
!  T3X/86 applications and Old-School Assembler without modifications.
!

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

! ==========================================================================
! Generic functions
! ==========================================================================

t.writes(file, str) t.write(file, str, str_len(str));
! Write string to file

t.writeln(file, str) do
! Write line string to file
    t.write(file, str, str_len(str));
    t.write(file, "\r\n", 2);
end

t.rwrites(file, seg, str) do
! Write string to file
    var tmp::128;
    t.farcopy(t.stack(), tmp, seg, str, 128);
    t.write(file, tmp, str_len(tmp));
end

t.rwriteln(file, seg, str) do
! Write line string to file
    t.rwrites(file, seg, str);
    t.rwrites(file, t.local(), "\r\n");
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

! ==========================================================================
! Terminal I/O using Stream API
! ==========================================================================
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
const TERM_VALUE_B = STREAM_AUX7;

term_cls(stream) do
! Clear screen
    var i;
    stream[TERM_CMD_POS] := 0;
    stream[TERM_Y] := 0;
    stream[TERM_X] := 0;
    stream[STREAM_PTR_BUFFER] := 0;
    t.farfillw(stream[STREAM_SEG_BUFFER], 0, stream[TERM_COLORS]|' ', 80*25);
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

term_colors_set(stream, fore, back) do
! Set new colors to output
    stream[TERM_COLORS] := (back << 12) | (fore << 8);
end

term_color_fore(stream, fore) do
! Set fore color
    stream[TERM_COLORS] := (stream[TERM_COLORS] & 0xf000) | (fore << 8);
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
! \el       = Clear current line and set x = 0
! \ex00     = Set X position (00-80)
! \ey00     = Set Y position (00-25)
! \ef00     = Set fore color (00-15)
! \eb00     = Set back color (00-15)
! \er00C    = Repeat C character 00 times (00-99)
! \eR00HH   = Repeat HH(Hex) character 00 times (00-FF)
!
    var i, y;
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
            else ie(c = 'l') do
                y := stream[TERM_Y];
                term_calc_pos(stream, 0, y);
                for(i=0,80) term_write_char(stream, ' ');
                term_calc_pos(stream, 0, y);
            end            
            else ie(c = 'f') stream[TERM_CMD_POS] := 2;
            else ie(c = 'b') stream[TERM_CMD_POS] := 2;
            else ie(c = 'x') stream[TERM_CMD_POS] := 2;
            else ie(c = 'y') stream[TERM_CMD_POS] := 2;
            else ie(c = 'r') stream[TERM_CMD_POS] := 2;
            else ie(c = 'R') stream[TERM_CMD_POS] := 2;
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
            ie(stream[TERM_CMD] = 'x') 
                term_calc_pos(stream, stream[TERM_VALUE], stream[TERM_Y]);
            else ie(stream[TERM_CMD] = 'y') 
                term_calc_pos(stream, stream[TERM_X], stream[TERM_VALUE]);
            else ie(stream[TERM_CMD] = 'r') 
                stream[TERM_CMD_POS] := 4;
            else ie(stream[TERM_CMD] = 'R') 
                stream[TERM_CMD_POS] := 4;
            else ie(stream[TERM_CMD] = 'f') 
                term_color_fore(stream, stream[TERM_VALUE]);
            else ie(stream[TERM_CMD] = 'b') 
                term_color_back(stream, stream[TERM_VALUE]);
            else stream[TERM_CMD_POS] := 0;
        end
        else ie(stream[TERM_CMD_POS] = 4) do
            stream[TERM_CMD_POS] := 0;
            ie(stream[TERM_CMD] = 'r') 
                for(i=0,stream[TERM_VALUE]) term_write_char(stream, c);
            else if(stream[TERM_CMD] = 'R') do
                stream[TERM_VALUE_B] := char_from_hex(c) << 4;
                stream[TERM_CMD_POS] := 5;
            end 
        end
        else ie(stream[TERM_CMD_POS] = 5) do
            stream[TERM_CMD_POS] := 0;
            if(stream[TERM_CMD] = 'R') do
                stream[TERM_VALUE_B] := stream[TERM_VALUE_B]|char_from_hex(c);
                for(i=0,stream[TERM_VALUE]) 
                    term_write_char(stream, stream[TERM_VALUE_B]);
            end 
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
    t.farsetw(
            stream[STREAM_SEG_BUFFER], 
            stream[STREAM_PTR_BUFFER], 
            c | stream[TERM_COLORS]);
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

! ==========================================================================
! Memory Manager
! ==========================================================================

const MCB_TYPE_B = 0;
const MCB_PROCESS_W = 1;
const MCB_PARAGRAPHS_W = 3;
const MCB_NAME_STR = 8;

var MemFirstSegment;

mem_total_kib() do
! Get total accessible ram size
    if(t.fargetw(t.local(), @Mode) = MODE_DOS_APP) do
        ! (Get MCB allocated paras(16 bytes block) + Local segment) / 64
        return (
                (t.fargetw(t.local()-1, MCB_PARAGRAPHS_W) + 
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
    MemFirstSegment := t.local() + 4096;
    t.farsetb(MemFirstSegment, MCB_TYPE_B, 'Z'); 
        ! M = Commom Block, Z = Last Block
    t.farsetw(MemFirstSegment, MCB_PROCESS_W, 0); 
        ! Process ID (Segment)
    t.farsetw(MemFirstSegment, MCB_PARAGRAPHS_W, (mem_usable_kib() << 6) - 1); 
        ! Block Size
    t.farsetb(MemFirstSegment, MCB_NAME_STR, 0); ! Name ASCIZ
end

mem_find(initial_seg, process) do
! Find first segment from process
    var seg, eol;
    eol := false;
    seg := initial_seg;
    while(\eol) do
        eol := t.fargetb(seg, MCB_TYPE_B) = 'Z';
        if(t.fargetw(seg, MCB_PROCESS_W) = process) do
            return seg;
        end
        seg := 1 + seg + t.fargetw(seg, MCB_PARAGRAPHS_W);
    end
    return 0;
end

mem_find_next(initial_seg, process) do
! Find next segment from process
    if(t.fargetw(initial_seg, MCB_TYPE_B) = 'Z') return 0;
    return mem_find(
            1 + initial_seg + t.fargetw(initial_seg, MCB_PARAGRAPHS_W), 
            process
        );
end

mem_defrag() do
! Find and merge free blocks
    var seg, prev_seg, eol;
    if(t.fargetb(seg, MCB_TYPE_B) = 'Z') return;
    prev_seg := t.fargetw(t.local(), @MemFirstSegment);
    seg := t.fargetw(prev_seg, MCB_PARAGRAPHS_W) + prev_seg + 1;
    eol := false;
    while(\eol) do
        eol := t.fargetb(seg, MCB_TYPE_B) = 'Z';
        ie
        (
            (t.fargetw(seg, MCB_PROCESS_W) = 0) &
            (t.fargetw(prev_seg, MCB_PROCESS_W) = 0)
        ) 
        do
            t.farsetw
            (
                prev_seg, 
                MCB_PARAGRAPHS_W, 
                t.fargetw(seg, MCB_PARAGRAPHS_W) + 
                t.fargetw(prev_seg, MCB_PARAGRAPHS_W) + 1
            );
            t.farsetb
            (
                prev_seg,
                MCB_TYPE_B,
                t.fargetb(seg, MCB_TYPE_B)
            );
            t.farsetw(seg, MCB_PROCESS_W, 0xffff);
        end
        else if(t.fargetw(seg, MCB_PROCESS_W) \= 0) prev_seg := seg;
        seg := 1 + seg + t.fargetw(seg, MCB_PARAGRAPHS_W);
    end
end

mem_size(seg) do
! Return size of allocated block in paras
    return t.fargetw(seg - 1, MCB_PARAGRAPHS_W);
end

mem_alloc(process, paras) do
! Allocate block in application memory (1 para. = 16 Bytes)
! Return 0 if fails
    var seg, next_seg, size;
    if((paras < 0) | (paras > 8192)) return 0; ! More than 128 KiB
    seg := mem_find(t.fargetw(t.local(), @MemFirstSegment), 0);
    while(seg \= 0) do
        size := mem_size(seg + 1);
        if((size >= paras) | size < 0) leave;
        seg := mem_find_next(seg, 0);
    end
    if(seg = 0) return 0;
    size := t.fargetb(seg, MCB_PARAGRAPHS_W);
    if
        (
            ((size + 5) > paras) |
            (size < 0) ! More than integer limit
        )
    do
        next_seg := seg + 1 + paras;
        size := size - paras - 1;
        t.farsetb(next_seg, MCB_TYPE_B, t.fargetb(seg, MCB_TYPE_B));
        t.farsetb(seg, MCB_TYPE_B, 'M');
        t.farsetw(next_seg, MCB_PROCESS_W, 0);
        t.farsetw(next_seg, MCB_PARAGRAPHS_W, size);
        t.farsetb(next_seg, MCB_NAME_STR, 0);
        t.farsetw(seg, MCB_PARAGRAPHS_W, paras);
    end
    t.farsetw(seg, MCB_PROCESS_W, process);
    return seg + 1;
end

mem_alloc_seg(process) do
! Allocate full segment block (64 KiB)
    return mem_alloc(process, 4096);
end

mem_free(seg) do
! Free block of application memory
    t.farsetw(seg - 1, MCB_PROCESS_W, 0);
    mem_defrag();
end

mem_free_process(process) do
! Free all blocks of one process
    var seg, eol;
    seg := t.fargetw(t.local(), @MemFirstSegment);
    eol := false;
    while(\eol) do
        eol := t.fargetb(seg, MCB_TYPE_B) = 'Z';
        if(t.fargetw(seg, MCB_PROCESS_W) = process) do
            t.farsetw(seg, MCB_PROCESS_W, 0);
        end
        seg := 1 + seg + t.fargetw(seg, MCB_PARAGRAPHS_W);
    end
    mem_defrag();
end

mem_calc_free() do
! Return total free space
    var total, seg, eol;
    seg := t.fargetw(t.local(), @MemFirstSegment);
    eol := false;
    total := 0;
    while(\eol) do
        eol := t.fargetb(seg, MCB_TYPE_B) = 'Z';
        if(t.fargetw(seg, MCB_PROCESS_W) = 0) do
            total := total + t.fargetw(seg, MCB_PARAGRAPHS_W);
        end
        seg := 1 + seg + t.fargetw(seg, MCB_PARAGRAPHS_W);
    end
    return total;
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
        t.fargetw(t.local(),FSList) + (fs << 1), 
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
        t.fargetw(t.local(),FSList) + (fs << 1), 
        OBJ_FS << 1
    );
    if(fsobj[FS_SEG] = 0) return FALSE;
    if(fsobj[FS_PTR_NEXT_ITEM] = 0) return FALSE;
    t.setptr(ptr, fsobj[FS_SEG], fsobj[FS_PTR_NEXT_ITEM]);
    callfar ptr(fsobj, item, ret);
    return ret[RET_OK];
end

fs_open_file(address, stream) do
! Open file from address
! Accepted address format:
!  [FS]/DIR/DIR/FILE
! OR
!  /DIR/DIR/FILE
!
!  - FS = Number of File System, started in 0
!  - DIR or FILE = Name
    var fsobj[OBJ_FS], fs, item[OBJ_ITEM], i, j, ok, name::32, name_len, dir;
    var old_item[OBJ_ITEM];
    fs := FSCurrent;
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
        t.fargetw(t.local(),FSList) + (fs << 1), 
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
    ! Check buffer, if buffered, return copy
    ie
    (
        (position > 0) &
        (position < 8) & 
        (MinixFSBuffer0 = position) &
        (MinixFSBufferFS0 = disk)
    ) do
        t.farcopy(t.stack(), dest, t.local(), @MinixFSBuffer::0, 1024);
        return TRUE;
    end
    else ie
    (
        (position >= 8) & 
        (position < 16) & 
        (MinixFSBuffer1 = position) &
        (MinixFSBufferFS1 = disk)
    ) do
        t.farcopy(t.stack(), dest, t.local(), @MinixFSBuffer::1024, 1024);
        return TRUE;
    end
    else ie
    (
        (position >= 16) & 
        (position < 64) & 
        (MinixFSBuffer2 = position) &
        (MinixFSBufferFS2 = disk)
    ) do
        t.farcopy(t.stack(), dest, t.local(), @MinixFSBuffer::2048, 1024);
        return TRUE;
    end
    else ie
    (
        (position >= 64) & 
        (position < 1024) & 
        (MinixFSBuffer3 = position) &
        (MinixFSBufferFS3 = disk)
    ) do
        t.farcopy(t.stack(), dest, t.local(), @MinixFSBuffer::3072, 1024);
        return TRUE;
    end
    else if
    (
        (position >= 1024) &
        (MinixFSBuffer4 = position) &
        (MinixFSBufferFS4 = disk)
    ) do
        t.farcopy(t.stack(), dest, t.local(), @MinixFSBuffer::4096, 1024);
        return TRUE;
    end
    !t.writes(T3X.SYSERR, "[READ ");
    !t.writenum(T3X.SYSERR, position);
    !t.writes(T3X.SYSERR, "]");
    ! Read from disk
    if(\stream_seek(DiskList[disk], position << 1, 0)) return FALSE;
    if(stream_read(DiskList[disk], dest, 512) = 0) return FALSE;
    if(\stream_seek(DiskList[disk], (position << 1) + 1, 0)) return FALSE;
    if(stream_read(DiskList[disk], @dest::512, 512) = 0) return FALSE;
    ! Store on buffer
    ie
    (
        (position > 0) &
        (position < 8)
    ) do
        t.farcopy(t.local(), @MinixFSBuffer::0, t.stack(), dest, 1024);
        t.farsetw(t.local(),   @MinixFSBuffer0, position);
        t.farsetw(t.local(), @MinixFSBufferFS0, disk);
    end
    else ie
    (
        (position >= 8) & 
        (position < 16)
    ) do
        t.farcopy(t.local(), @MinixFSBuffer::1024, t.stack(), dest, 1024);
        t.farsetw(t.local(),   @MinixFSBuffer1, position);
        t.farsetw(t.local(), @MinixFSBufferFS1, disk);
    end
    else ie
    (
        (position >= 16) & 
        (position < 64)
    ) do
        t.farcopy(t.local(), @MinixFSBuffer::2048, t.stack(), dest, 1024);
        t.farsetw(t.local(),   @MinixFSBuffer2, position);
        t.farsetw(t.local(), @MinixFSBufferFS2, disk);
    end
    else ie
    (
        (position >= 64) & 
        (position < 1024)
    ) do
        t.farcopy(t.local(), @MinixFSBuffer::3072, t.stack(), dest, 1024);
        t.farsetw(t.local(),   @MinixFSBuffer3, position);
        t.farsetw(t.local(), @MinixFSBufferFS3, disk);
    end
    else if
    (
        (position >= 1024)
    ) do
        t.farcopy(t.local(), @MinixFSBuffer::4096, t.stack(), dest, 1024);
        t.farsetw(t.local(),   @MinixFSBuffer4, position);
        t.farsetw(t.local(), @MinixFSBufferFS4, disk);
    end
    return TRUE;
end

minixfs_write_zone(disk, position, orig) do
! Write zones (1024 bytes disk block) using 512 bytes physical blocks
    !t.writes(T3X.SYSERR, "[WRITE ");
    !t.writenum(T3X.SYSERR, position);
    !t.writes(T3X.SYSERR, "]");
    ! Write to disk
    if(\stream_seek(DiskList[disk], position << 1, 0)) return FALSE;
    if(stream_write(DiskList[disk], orig, 512) = 0) return FALSE;
    if(\stream_seek(DiskList[disk], (position << 1) + 1, 0)) return FALSE;
    if(stream_write(DiskList[disk], @orig::512, 512) = 0) return FALSE;
    ! Store on buffer
    ie
    (
        (position > 0) &
        (position < 8)
    ) do
        t.farcopy(t.local(), @MinixFSBuffer::0, t.stack(), orig, 1024);
        t.farsetw(t.local(),   @MinixFSBuffer0, position);
        t.farsetw(t.local(), @MinixFSBufferFS0, disk);
    end
    else ie
    (
        (position >= 8) & 
        (position < 16)
    ) do
        t.farcopy(t.local(), @MinixFSBuffer::1024, t.stack(), orig, 1024);
        t.farsetw(t.local(),   @MinixFSBuffer1, position);
        t.farsetw(t.local(), @MinixFSBufferFS1, disk);
    end
    else ie
    (
        (position >= 16) & 
        (position < 64)
    ) do
        t.farcopy(t.local(), @MinixFSBuffer::2048, t.stack(), orig, 1024);
        t.farsetw(t.local(),   @MinixFSBuffer2, position);
        t.farsetw(t.local(), @MinixFSBufferFS2, disk);
    end
    else ie
    (
        (position >= 64) & 
        (position < 1024)
    ) do
        t.farcopy(t.local(), @MinixFSBuffer::3072, t.stack(), orig, 1024);
        t.farsetw(t.local(),   @MinixFSBuffer3, position);
        t.farsetw(t.local(), @MinixFSBufferFS3, disk);
    end
    else if
    (
        (position >= 1024)
    ) do
        t.farcopy(t.local(), @MinixFSBuffer::4096, t.stack(), orig, 1024);
        t.farsetw(t.local(),   @MinixFSBuffer4, position);
        t.farsetw(t.local(), @MinixFSBufferFS4, disk);
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
    !t.writes(T3X.SYSERR, "[LOAD ID ");
    !t.writenum(T3X.SYSERR, id);
    !t.writes(T3X.SYSERR, " POS ");
    !t.writenum(T3X.SYSERR, pos);
    !t.writes(T3X.SYSERR, " ZONE ");
    !t.writenum(T3X.SYSERR, fs[MINIXFS_LIST_ITENS]);
    !t.writes(T3X.SYSERR, "]");
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
        t.fargetw(t.local(),FSList) + (stream[STREAM_MINIXFS_FS] << 1), 
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
! Interrupt Handlers
! ==========================================================================

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

decl banner(1);
decl shutdown(0);

int79(ax,bx,cx,dx,ds,si,es,di,ss,sp) farint do
! HUSIS API (DS,ES,SS,SP from Application)
    ie(ax = 1) ! Clear and print banner
        banner(bx);
    else ie(ax = 2) do
        t.setsegs(t.local(), 0xff00, 0xff00);
        shutdown();
    end
    else
        int_debug(0x20, ax,bx,cx,dx,ds,si,es,di);
    return 0;
end

int20(ax,bx,cx,dx,ds,si,es,di,ss,sp) farint do
! DOS API (DS,ES,SS,SP from Application)
    int_debug(0x20, ax,bx,cx,dx,ds,si,es,di);
end

int21(ax,bx,cx,dx,ds,si,es,di,ss,sp) farint do
! DOS API (DS,ES,SS,SP from Application)
    var func, al, preserve, tmp[OBJ_STREAM], tmp_ptr;
    func := ax >> 8;
    al := ax & 0xff;
    ie(func = 0x40) do ! DOS WRITE
        ie(bx = 1) do ! SYSOUT
            tmp_ptr := t.fargetw(t.local(), @StreamOut);
            t.farcopy(t.stack(), tmp, t.local(), tmp_ptr, OBJ_STREAM<<1);
            ! Copy Kernel Stream object to Application memory
            stream_write(tmp, dx, cx);
            t.farcopy(t.local(), tmp_ptr, t.stack(), tmp, OBJ_STREAM<<1);
        end
        else ie(bx = 2) do ! SYSERR
            tmp_ptr := t.fargetw(t.local(), @StreamErr);
            t.farcopy(t.stack(), tmp, t.local(), tmp_ptr, OBJ_STREAM<<1);
            ! Copy Kernel Stream object to Application memory
            preserve := tmp[TERM_COLORS];
            tmp[TERM_COLORS] := 4 << 8;
            stream_write(tmp, dx, cx);
            tmp[TERM_COLORS] := preserve;
            t.farcopy(t.local(), tmp_ptr, t.stack(), tmp, OBJ_STREAM<<1);
        end
        else int_debug(0x20, ax,bx,cx,dx,ds,si,es,di);
    end
    else ie(func = 0x3f) do ! DOS READ
        ie(bx = 0) do ! SYSIN
            tmp_ptr := t.fargetw(t.local(), @StreamIn);
            t.farcopy(t.stack(), tmp, t.local(), tmp_ptr, OBJ_STREAM<<1);
            ! Copy Kernel Stream object to Application memory
            stream_read(tmp, dx, cx);
            t.farcopy(t.local(), tmp_ptr, t.stack(), tmp, OBJ_STREAM<<1);
        end
        else int_debug(0x20, ax,bx,cx,dx,ds,si,es,di);
    end
    else int_debug(0x20, ax,bx,cx,dx,ds,si,es,di);
end

! ==========================================================================
! Process Management
! ==========================================================================

const TOTAL_PROCESS = 32;

const STATUS_PROCESS_EMPTY = 0;
const STATUS_PROCESS_RUNING = 1;
const STATUS_PROCESS_WAINTING = 2;

struct OBJ_PROCESS =
! Process
    PROCESS_ID,
    PROCESS_PARENT_ID,
    PROCESS_SEG,
    PROCESS_SP,
    PROCESS_IP,
    PROCESS_STATUS,
    PROCESS_WAITING_ID;

var ProcessList[TOTAL_PROCESS], ProcessData[TOTAL_PROCESS * OBJ_PROCESS];
var ProcessCurrent, ProcessKernel;

new_process(seg, sp, ip) do
    var i, ptr;
    for(i=1,TOTAL_PROCESS) do
        ptr := t.fargetw(t.local(), ProcessList) + (i * (OBJ_PROCESS<<1));
        if
        (
            t.fargetw(t.local(), ptr + (PROCESS_STATUS<1)) = 
            STATUS_PROCESS_EMPTY
        ) 
        do
            t.farsetw(t.local(), ptr + (PROCESS_SEG<1), seg);
            t.farsetw(t.local(), ptr + (PROCESS_IP<1), ip);
            t.farsetw(t.local(), ptr + (PROCESS_SP<1), sp);
            t.farsetw(t.local(), ptr + (PROCESS_STATUS<1), STATUS_PROCESS_RUNING);
            return i;
        end
    end
    return 0;
end

process_init() do
    var i;
    for(i=0,TOTAL_PROCESS) do
        ProcessList[i] := @ProcessData[OBJ_PROCESS * i];
        ProcessList[i][PROCESS_ID] := i;
        ProcessList[i][PROCESS_STATUS] := STATUS_PROCESS_EMPTY;
    end
    ProcessKernel := new_process(t.local(), 0xfffe, 0);
    ProcessCurrent := ProcessKernel;
end

! ==========================================================================
! COM File Support
! ==========================================================================

com_exec(stream, args) do
! Load COM file to RAM and Execute
    var temp::128, seg, i, pos, block, process, args_size, exec, sp, ip;
! TODO: Implement multiple process
    seg := mem_alloc_seg(1);
    if(seg = 0) return %1;
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
    ip := t.instrptr();
    ie(exec)do
        ! Exit of COM Program
    end
    else do
        ! Call COM Program
        t.jmpstack(seg, 0xfffe, 256);
    end

end


! ==========================================================================
! Main
! ==========================================================================

var Int79Ant[T3X.PTRSIZE], Int20Ant[T3X.PTRSIZE], Int21Ant[T3X.PTRSIZE];
! Previous Interrupt Handlers

banner(cls) do
    t.rwrites(T3X.SYSOUT, t.local(), "\ef07\eb00");
    ie(cls)
        t.rwrites(T3X.SYSOUT, t.local(), "\ec");
    else
        t.rwrites(T3X.SYSOUT, t.local(), 
            "\ex00\ey00\r80 \r80 \r80 \r80 \ey00\ex00");
    t.rwrites(T3X.SYSOUT, t.local(), "\ef03HUSIS \ef04v");
    t.writenum(T3X.SYSOUT, VERSION);
    t.rwrites(T3X.SYSOUT, t.local(), ".");
    t.writenum(T3X.SYSOUT, SUB_VERSION);
    t.rwrites(T3X.SYSOUT, t.local(), " R");
    t.writenum(T3X.SYSOUT, REVISION);
    t.rwriteln(T3X.SYSOUT, t.local(), "\ef07");
    if(Mode = MODE_DOS_APP) 
        t.rwrites(T3X.SYSERR, t.local(), "[ DOS Application Mode] ");
    t.rwriteln(T3X.SYSOUT, t.local(),"Build using \ef03T3X/86\ef07 Compiler");
    t.rwriteln(T3X.SYSOUT, t.local(), 
        "Copyright (c) 2022, Humberto Costa dos Santos Junior");
    t.rwriteln(T3X.SYSOUT, t.local(), "License: 3-Clause BSD");
    t.rwrites(T3X.SYSOUT, t.local(), "\eR80CD");
end

shutdown() do
! Shutdown HUSIS
    t.writeln(T3X.SYSOUT, "\ec\ef03SYSTEM HALTED.");

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
    t.writes(T3X.SYSERR, "\ex00\ey24FATAL ERROR: ");
    t.writeln(T3X.SYSERR, msg);
    t.writes(T3X.SYSERR, "\r\nPress ENTER to shutdown.\r\n");
    t.read(T3X.SYSIN, tmp, 0);
    shutdown();
end

do
! Main routine, initialize operating system
    var arg::64, arg_disk, arg_cil, arg_head, arg_sect, arg_ok;
    var disk, i, item[OBJ_ITEM], stream[OBJ_STREAM];
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
    mem_init();
    term_init();
    disk_init();
    fs_init();
    minixfs_init();
    process_init();

    ! HUSIS Banner using DOS API implemented by HUSIS
    banner(TRUE);

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
        if(t.getarg(5, arg, 64) = 0) 
            fatal_error(
            "Shell missing. Use: DISK_ID CILINDERS HEADS SECTORS SHELL_PATH");
        t.writes(T3X.SYSOUT, "Loading ");
        t.writeln(T3X.SYSOUT, arg);
        if(\fs_open_file(arg, stream)) fatal_error("Shell file not found.");
        com_exec(stream, "");
    end
    else do
        fatal_error(
"Disk parameters incomplete. Use: DISK_ID CILINDERS HEADS SECTORS SHELL_PATH"
        );
    end


    t.writes(T3X.SYSERR, "\ex00\ey24System Halted. Press ENTER to shutdown.");
    t.read(T3X.SYSIN, arg, 0);

    ! Shutdown system
    shutdown();
end

