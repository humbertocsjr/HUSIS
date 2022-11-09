

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