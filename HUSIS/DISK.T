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
    var cil, head, sect, cil_tot, head_tot, sect_tot, position;
    ret[RET_OK] := FALSE;
    ret[RET_VALUE] := 0;
    if(len \= 512) return;
    position := stream[DISK_POS_LOW];
    cil_tot := stream[DISK_CILINDERS];
    head_tot := stream[DISK_HEADS];
    sect_tot := stream[DISK_SECTORS];
    cil := position / (head_tot * sect_tot);
    head := (position / sect_tot) mod head_tot;
    sect := (position mod sect_tot) + 1;
    if(cil >= cil_tot) return;
    ax := 0x201;
    bx := dest;
    cx := (cil << 8) | sect | ((cil >> 8) << 6);
    dx := stream[DISK_BIOS_ID] | (head << 8);
!term_kwrites("[R");
!term_writenum(position);
!term_kwrites("]");
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
    var cil, head, sect, cil_tot, head_tot, sect_tot, position;
    ret[RET_OK] := FALSE;
    ret[RET_VALUE] := 0;
    if(len \= 512) return;
    position := stream[DISK_POS_LOW];
    cil_tot := stream[DISK_CILINDERS];
    head_tot := stream[DISK_HEADS];
    sect_tot := stream[DISK_SECTORS];
    cil := position / (head_tot * sect_tot);
    head := (position / sect_tot) mod head_tot;
    sect := (position mod sect_tot) + 1;
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