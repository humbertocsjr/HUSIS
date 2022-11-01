| HUSIS VIDEO COMMON CODE API
| Humberto Costa dos Santos Junior, 2022
| 3-Clause BSD license
| VIDEO API

| PRG Header
.asciz "HUSIS"      | 00w-02w: Signature
.word  1            | 03w    : Version API
.word  start        | 04w    : Start function
.word  end          | 05w    : Size of Code Area
.word  0            | 06w    : Size of Data Extended Area

| Import LIBH86
.include ../LIBH86.S


int82: | __videoapi0
    cmp ax, #1
    je __videoapi0_1
    cmp ax, #2
    je __videoapi0_2
    cmp ax, #3
    je __videoapi0_3
    cmp ax, #4
    je __videoapi0_4
    cmp ax, #5
    je __videoapi0_5
    cmp ax, #6
    je __videoapi0_6
    cmp ax, #7
    je __videoapi0_7
    cmp ax, #8
    je __videoapi0_8
    cmp ax, #9
    je __videoapi0_9
    cmp ax, #10
    je __videoapi0_10
    mov ax, #FALSE
    iret
    __videoapi0_1:
        call video_can_customize
        iret
    __videoapi0_2:
        call video_can_show_colors
        iret
    __videoapi0_3:
        call video_cls
        iret
    __videoapi0_4:
        call video_write_char
        iret
    __videoapi0_5:
        call video_write_string
        iret
    __videoapi0_6:
        call video_goto
        iret
    __videoapi0_7:
        call video_set_font8x8
        iret
    __videoapi0_8:
        call video_get_height
        iret
    __videoapi0_9:
        call video_get_width
        iret
    __videoapi0_10:
        call video_write_char_color
        iret


old_int82:
    .word 0
    .word 0

start:
    
    | Set Interrupt Handler
    mov bx, #old_int82
    push cs
    pop cx
    mov dx, #0x82
    mov si, #int82
    call husis_int_set

    call video_initialize

    call kbanner_extension

    | Exit
    call husis_exit_main
