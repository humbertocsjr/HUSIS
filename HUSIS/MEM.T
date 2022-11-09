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
