! HUSIS Library
! Humberto Costa dos Santos Junior, 2022
! License: 0BSD or Public Domain

! ==========================================================================
! Memory Management
! ==========================================================================

mem_calc_free_kib() return t.int86ax(0x79, 400,0,0,0, 0,0);
mem_calc_free() return t.int86ax(0x79, 401,0,0,0, 0,0);
mem_size(segment) return t.int86ax(0x79, 402,segment,0,0, 0,0);

! ==========================================================================
! Kernel I/O
! ==========================================================================

kernel_print(str) t.int86ax(0x79, 101,str,0,0, 0,0);
kernel_println(str) t.int86ax(0x79, 102,str,0,0, 0,0);
kernel_printenter() t.int86ax(0x79, 105,0,0,0, 0,0);
kernel_printnum(str) t.int86ax(0x79, 103,str,0,0, 0,0);
kernel_printfixed(str, len) t.int86ax(0x79, 100,str,len,0, 0,0);
kernel_printchar(char) t.int86ax(0x79, 106,char,0,0, 0,0);


! ==========================================================================
! Process info
! ==========================================================================

husis_get_version() return t.int86ax(0x79, 5,0,0,0, 0,0);
husis_get_sub_version() return t.int86ax(0x79, 6,0,0,0, 0,0);
husis_get_revision() return t.int86ax(0x79, 7,0,0,0, 0,0);
husis_process_id() return t.int86ax(0x79, 302,0,0,0, 0,0);
husis_parent_id() return t.int86ax(0x79, 309,0,0,0, 0,0);
husis_other_parent_id(id) return t.int86ax(0x79, 308,id,0,0, 0,0);
husis_other_seg(id) return t.int86ax(0x79, 304,id,0,0, 0,0);
husis_other_ip(id) return t.int86ax(0x79, 305,id,0,0, 0,0);
husis_other_sp(id) return t.int86ax(0x79, 306,id,0,0, 0,0);
husis_other_bp(id) return t.int86ax(0x79, 307,id,0,0, 0,0);
husis_other_status(id) return t.int86ax(0x79, 303,id,0,0, 0,0);
husis_exit(status) return t.int86ax(0x79, 0,status,0,0, 0,0);
husis_exit_main() return t.int86ax(0x79, 2,0,0,0, 0,0);
husis_shutdown() return t.int86ax(0x79, 1,0,0,0, 0,0);
husis_exec_com(file_name, args) return t.int86ax(0x79, 300,file_name,args,0, 0,0);
husis_exec_prg(file_name, args) return t.int86ax(0x79, 301,file_name,args,0, 0,0);
husis_int_set(old_seg_ptr, int, function) 
    return t.int86ax(0x79, 3,old_seg_ptr,t.local(),int, function,0);
husis_int_restore(old_seg_ptr, int) 
    return t.int86ax(0x79, 4,old_seg_ptr,int,0, 0,0);

