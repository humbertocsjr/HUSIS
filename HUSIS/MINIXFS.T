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

const MINIXFS_BUFFER_CAPACITY = 5;

var MinixFSBuffer::5120, 
    MinixFSBufferPos[MINIXFS_BUFFER_CAPACITY],
    MinixFSBufferDisk[MINIXFS_BUFFER_CAPACITY],
    MinixFSBufferUsage[MINIXFS_BUFFER_CAPACITY];

minixfs_buffer_read(disk, position, dest) do
    var i, fsbuffer, pos_list, disk_list, usage_list;
    fsbuffer := t.fargetw(t.local(), @MinixFSBuffer);
    pos_list := t.fargetw(t.local(), @MinixFSBufferPos);
    disk_list := t.fargetw(t.local(), @MinixFSBufferDisk);
    usage_list := t.fargetw(t.local(), @MinixFSBufferUsage);
    for(i = 0, MINIXFS_BUFFER_CAPACITY) do
        t.farsetw
        (
            t.local(), 
            usage_list + (i<<1),
            t.fargetw(t.local(), usage_list + (i<<1)) + 1
        );
    end
    for(i = 0, MINIXFS_BUFFER_CAPACITY) do
        if
        (
            (t.fargetw(t.local(), pos_list + (i<<1)) = position) &
            (t.fargetw(t.local(), disk_list + (i<<1)) = disk)
        )
        do
            t.farsetw
            (
                t.local(), 
                usage_list + (i<<1),
                1
            );
            t.farcopy(t.stack(), dest, t.local(), fsbuffer + (i * 1024), 1024);
!term_kwrites("[RFOUND");
!term_writenum(i);
!term_kwrites("]");
            return TRUE;
        end
    end
    return FALSE;
end

minixfs_buffer_write(disk, position, orig) do
    var i, fsbuffer, pos_list, disk_list, usage_list, old_usage, old_index;
    fsbuffer := t.fargetw(t.local(), @MinixFSBuffer);
    pos_list := t.fargetw(t.local(), @MinixFSBufferPos);
    disk_list := t.fargetw(t.local(), @MinixFSBufferDisk);
    usage_list := t.fargetw(t.local(), @MinixFSBufferUsage);
    old_usage := 0;
    old_index := 0;
    for(i = 0, MINIXFS_BUFFER_CAPACITY) do
        t.farsetw
        (
            t.local(), 
            usage_list + (i<<1),
            t.fargetw(t.local(), usage_list + (i<<1)) + 1
        );
        if(t.fargetw(t.local(), usage_list + (i<<1)) > old_usage) do
            old_index := i;
            old_usage := t.fargetw(t.local(), usage_list + (i<<1));
        end
    end
    for(i = 0, MINIXFS_BUFFER_CAPACITY) do
        if
        (
            (t.fargetw(t.local(), pos_list + (i<<1)) = position) &
            (t.fargetw(t.local(), disk_list + (i<<1)) = disk)
        )
        do
            t.farsetw
            (
                t.local(), 
                usage_list + (i<<1),
                1
            );
            t.farcopy(t.local(), fsbuffer + (i * 1024), t.stack(), orig, 1024);
!term_kwrites("[WFOUND");
!term_writenum(old_index);
!term_kwrites("]");
            return TRUE;
        end
    end
    t.farsetw
    (
        t.local(), 
        usage_list + (old_index<<1),
        1
    );
    t.farsetw
    (
        t.local(), 
        pos_list + (old_index<<1),
        position
    );
    t.farsetw
    (
        t.local(), 
        disk_list + (old_index<<1),
        disk
    );
    t.farcopy(t.local(), fsbuffer + (old_index * 1024), t.stack(), orig, 1024);
!term_kwrites("[WNEW");
!term_writenum(old_index);
!term_kwrites("]");
end

minixfs_read_zone(disk, position, dest) do
! Read zones (1024 bytes disk block) using 512 bytes physical blocks
    var dtmp[OBJ_STREAM], dptr;
    dptr := t.fargetw(t.local(), @DiskList);
    t.farcopy(t.stack(), dtmp, t.local(), 
        t.fargetw(t.local(), dptr + (disk << 1)), OBJ_STREAM<<1);
    ! Check buffer, if buffered, return copy
    if(minixfs_buffer_read(disk, position, dest)) return TRUE;
!term_kwrites("[READ ");
!term_writenum(position);
!term_kwrites("]");
    ! Read from disk
    if(\stream_seek(dtmp, position << 1, 0)) return FALSE;
    if(stream_read(dtmp, dest, 512) = 0) return FALSE;
    if(\stream_seek(dtmp, (position << 1) + 1, 0)) return FALSE;
    if(stream_read(dtmp, @dest::512, 512) = 0) return FALSE;
    ! Store on buffer
    minixfs_buffer_write(disk, position, dest);
    return TRUE;
end

minixfs_write_zone(disk, position, orig) do
! Write zones (1024 bytes disk block) using 512 bytes physical blocks
    var dtmp[OBJ_STREAM], dptr;
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
    minixfs_buffer_write(disk, position, orig);
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
    var i;
    for(i = 0, MINIXFS_BUFFER_CAPACITY) do
        MinixFSBufferDisk[i] := %1;
        MinixFSBufferPos[i] := 0;
        MinixFSBufferUsage[i] := 2000;
    end
end