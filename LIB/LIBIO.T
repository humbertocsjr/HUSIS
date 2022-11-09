! HUSIS Library
! Humberto Costa dos Santos Junior, 2022
! License: 0BSD or Public Domain

! ==========================================================================
! Standard I/O
! ==========================================================================

io_cls() t.int86ax(0x81, 100,0,0,0, 0,0);
io_print(str) t.int86ax(0x81, 102,str,0,0, 0,0);
io_error(str) t.int86ax(0x81, 105,str,0,4, 0,0);
io_println(str) t.int86ax(0x81, 103,str,0,0, 0,0);
io_errorln(str) t.int86ax(0x81, 106,str,0,4, 0,0);
io_printenter() t.int86ax(0x81, 109,0,0,0, 0,0);
io_errorenter() t.int86ax(0x81, 109,0,0,0, 0,0);
io_printnum(str) t.int86ax(0x81, 107,str,0,0, 0,0);
io_errornum(str) t.int86ax(0x81, 108,str,0,0, 0,0);
io_printfixed(str, len) t.int86ax(0x81, 101,str,len,0, 0,0);
io_errorfixed(str, len) t.int86ax(0x81, 104,str,len,4, 0,0);
io_printchar(char) t.int86ax(0x81, 110,char,0,0, 0,0);
io_errorchar(char) t.int86ax(0x81, 111,char,0,4, 0,0);
io_avail() return t.int86ax(0x81, 112,0,0,0, 0,0);
io_readchar() return t.int86ax(0x81, 113,0,0,0, 0,0);
io_readln(dest, len) return t.int86ax(0x81, 114,dest,len,0, 0,0);


! ==========================================================================
! File
! ==========================================================================


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

open_file(address, stream) return t.int86ax(0x79, 504,address,stream,0, 0,0);
open_dir(address, item) return t.int86ax(0x79, 503,address,item,0, 0,0);
item_first(dir_item, item) return t.int86ax(0x79, 505,dir_item,item,0, 0,0);
item_next(item) return t.int86ax(0x79, 506,item,0,0, 0,0);
item_open(item, stream) return t.int86ax(0x79, 502,item,stream,0, 0,0);
item_copy(item_dest, item_orig) return t.int86ax(0x79, 507,item_orig,item_dest,0, 0,0);
path_get(dest, len) return t.int86ax(0x79, 509,dest,len,0, 0,0);
path_set(path) return t.int86ax(0x79, 508,path,0,0, 0,0);


! ==========================================================================
! Stream I/O
! ==========================================================================

const STATUS_UNKNOWN = 0;
const STATUS_OPEN = 1;
const STATUS_CLOSE = 2;

const BUFFER_SIZE = 1030;

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

stream_readfixed(stream, dest, len) return t.int86ax(0x79, 205,stream,dest,len, 0,0);
stream_writefixed(stream, orig, len) return t.int86ax(0x79, 206,stream,orig,len, 0,0);
stream_close(stream) return t.int86ax(0x79, 204,stream,0,0, 0,0);
stream_buffer_init(buffer, total_len) do
    if(total_len < 10) return FALSE;
    buffer[0] := total_len - 6;
    buffer[1] := 0;
    buffer[2] := 0;
    buffer[3] := 0;
    return TRUE;
end
stream_readln(stream, buffer, dest, dest_len) do
    var i, j, contents;
    if(buffer[1] = 0) do
        buffer[1] := stream_readfixed(stream, @buffer[3], buffer[0]);
        if(buffer[1] = 0) return FALSE;
        buffer[2] := 0;
    end
    dest::0 := 0;
    contents := @buffer[3];
    j := buffer[2];
    for(i=0,dest_len-1) do
        if(j >= buffer[1]) do
            ie(buffer[1] = buffer[0])do
                buffer[1] := stream_readfixed(stream, @buffer[3], buffer[0]);
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
! Generic functions
! ==========================================================================

t.writes(file, str) t.write(file, str, str_len(str));
! Write string to file

t.rwrites(file, seg, str) do
! Write string to file
    var tmp::128;
    t.farcopy(t.stack(), tmp, seg, str, 128);
    t.write(file, tmp, str_len(tmp));
end

t.writeln(file, str) do
! Write line string to file
    t.write(file, str, str_len(str));
    t.rwrites(file, t.local(), "\r\n");
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
