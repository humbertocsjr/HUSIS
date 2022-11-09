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