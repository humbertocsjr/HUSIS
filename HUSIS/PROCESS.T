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