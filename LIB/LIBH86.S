| HUSIS Library
| Humberto Costa dos Santos Junior, 2022
| License: 0BSD or Public Domain

jmp libh86_end


TRUE = 0xffff
FALSE = 0


| ==========================================================================
| Standard I/O
| ==========================================================================

io_cls: | __io0
| Clear screen
    mov ax, #100
    int #0x79
    ret

io_print: | __io1
| Print ASCIZ in CS:IP
    push bp
    mov bp, sp
    push ax
    push bx
    push si
    mov bx, 2[bp]
    mov ax, #102
    int #0x79
    mov si, 2[bp]
    __io1Loop:
        lodsb
        cmpb al, #0
        je __io1End
        jmps __io1Loop
    __io1End:
    mov 2[bp], si
    pop si
    pop bx
    pop ax
    pop bp
    ret

io_println: | __io2
| Print ASCIZ in CS:IP
    push bp
    mov bp, sp
    push ax
    push bx
    push si
    mov bx, 2[bp]
    mov ax, #103
    int #0x79
    mov si, 2[bp]
    __io2Loop:
        lodsb
        cmpb al, #0
        je __io2End
        jmps __io2Loop
    __io2End:
    mov 2[bp], si
    pop si
    pop bx
    pop ax
    pop bp
    ret

io_printenter: | __io3
| Print New Line
    push ax
    mov ax, #109
    int #0x79
    pop ax
    ret

io_printsi: | __io4
| Print ASCIZ in CS:IP
    push ax
    push bx
    push si
    mov bx, si
    mov ax, #102
    int #0x79
    pop si
    pop bx
    pop ax
    ret

io_printnum: | __io5
| Print ASCIZ in CS:IP
    push ax
    push bx
    push si
    mov bx, ax
    mov ax, #107
    int #0x79
    pop si
    pop bx
    pop ax
    ret


| ==========================================================================
| Kernel I/O
| ==========================================================================

kernel_print: | __io6
    push bp
    mov bp, sp
    push ax
    push bx
    push si
    mov bx, 2[bp]
    mov ax, #101
    int #0x79
    mov si, 2[bp]
    __io6Loop:
        lodsb
        cmpb al, #0
        je __io6End
        jmps __io6Loop
    __io6End:
    mov 2[bp], si
    pop si
    pop bx
    pop ax
    pop bp
    ret

kernel_println: | __io7
| Print ASCIZ in CS:IP
    push bp
    mov bp, sp
    push ax
    push bx
    push si
    mov bx, 2[bp]
    mov ax, #102
    int #0x79
    mov si, 2[bp]
    __io7Loop:
        lodsb
        cmpb al, #0
        je __io7End
        jmps __io7Loop
    __io7End:
    mov 2[bp], si
    pop si
    pop bx
    pop ax
    pop bp
    ret

kernel_printenter: | __io8
| Print New Line
    push ax
    mov ax, #105
    int #0x79
    pop ax
    ret

kernel_printsi: | __io9
| Print ASCIZ in CS:IP
    push ax
    push bx
    push si
    mov bx, si
    mov ax, #101
    int #0x79
    pop si
    pop bx
    pop ax
    ret

kernel_printnum: | __io10
| Print ASCIZ in CS:IP
    push ax
    push bx
    push si
    mov bx, ax
    mov ax, #103
    int #0x79
    pop si
    pop bx
    pop ax
    ret

| ==========================================================================
| Process Info
| ==========================================================================

husis_process_id:
    mov ax, #302
    int #0x79
    ret

husis_parent_id:
    mov ax, #309
    int #0x79
    ret

| bx = Process ID
husis_other_parent_id:
    mov ax, #308
    int #0x79
    ret

| bx = Process ID
husis_other_seg:
    mov ax, #304
    int #0x79
    ret

| bx = Process ID
husis_other_ip:
    mov ax, #305
    int #0x79
    ret

| bx = Process ID
husis_other_sp:
    mov ax, #306
    int #0x79
    ret

| bx = Process ID
husis_other_bp:
    mov ax, #307
    int #0x79
    ret

| bx = Process ID
husis_other_status:
    mov ax, #303
    int #0x79
    ret

| bx = Status
husis_exit:
    xor ax, ax
    int #0x79
    ret

husis_exit_main:
    mov ax, #2
    int #0x79
    ret

husis_shutdown:
    mov ax, #1
    int #0x79
    ret

| bx = File name
| cx = Args
husis_exec_com:
    mov ax, #300
    int #0x79
    ret

| bx = File name
| cx = Args
husis_exec_prg:
    mov ax, #301
    int #0x79
    ret

| bx = Pointer to 4 bytes pointer (Old Pointer)
| cx = Segment
| dx = Interrupt Number
| si = Interrupt Handler
husis_int_set:
    mov ax, #3
    int #0x79
    ret

| ==========================================================================
| LIBH86 Extensions
| ==========================================================================

banner_extension:
    call io_print
    .asciz "HUSIS Kernel Extension - "
    call banner_application
    ret

banner_application:
    mov si, #name
    call io_printsi

    call io_print
    .asciz " v"

    mov ax, version
    call io_printnum

    call io_print
    .asciz "."

    mov ax, sub_version
    call io_printnum

    call io_print
    .asciz " R"

    mov ax, revision
    call io_printnum

    call io_printenter
    
    call io_print
    .asciz "Copyright (c) "
    
    mov si, #copyright_year
    call io_printsi
    
    call io_print
    .asciz ", "
    
    mov si, #author
    call io_printsi
    
    call io_printenter
    
    call io_print
    .asciz "License: "
    
    mov si, #license
    call io_printsi
    
    call io_printenter
    ret


kbanner_extension:
    call kernel_print
    .asciz "HUSIS Kernel Extension - "
    call kbanner_application
    ret

kbanner_application:
    mov si, #name
    call kernel_printsi

    call kernel_print
    .asciz " v"

    mov ax, version
    call kernel_printnum

    call kernel_print
    .asciz "."

    mov ax, sub_version
    call kernel_printnum

    call kernel_print
    .asciz " R"

    mov ax, revision
    call kernel_printnum

    call kernel_printenter
    
    call kernel_print
    .asciz "Copyright (c) "
    
    mov si, #copyright_year
    call kernel_printsi
    
    call kernel_print
    .asciz ", "
    
    mov si, #author
    call kernel_printsi
    
    call kernel_printenter
    
    call kernel_print
    .asciz "License: "
    
    mov si, #license
    call kernel_printsi
    
    call kernel_printenter
    ret



libh86_end: