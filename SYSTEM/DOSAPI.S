| HUSIS DOS API
| Humberto Costa dos Santos Junior, 2022
| 3-Clause BSD license
| DOS API

| PRG Header
.asciz "HUSIS"      | 00w-02w: Signature
.word  1            | 03w    : Version API
.word  start        | 04w    : Start function
.word  end          | 05w    : Size of Code Area
.word  0            | 06w    : Size of Data Extended Area

| Import LIBH86
.include ../LIB/LIBH86.S

| Info Header
name:
    .asciz "DOS API"
version:
    .word 0
sub_version:
    .word 1
revision:
    .word 0
copyright_year:
    .asciz "2022"
author:
    .asciz "Humberto Costa dos Santos Junior"
license:
    .asciz "3-Clause BSD"


int20:
    xor bx,bx
    movb bl, al
    mov ax, #2
    int #0x79

int21:
    cmpb ah, #0x40
    je int21_40
    cmpb ah, #0x3F
    je int21_3f
    cmpb ah, #0x4C
    je int32_4c
    iret
int21_40: 
    jmp write
int21_3f: 
    jmp read
int32_4c: 
    jmp exit

write:
    cmp bx, #1
    je write_sysout
    cmp bx, #2
    je write_syserr
    xor ax,ax
    iret
    write_sysout:
        mov bx, dx
        mov ax, #102
        int #0x81
        iret
    write_syserr:
        mov bx, dx
        mov ax, #104
        mov dx, #4
        int #0x81
        iret

read:
    cmp bx, #0
    je read_sysin
    xor ax,ax
    iret
    read_sysin:
        mov bx, dx
        mov ax, #114
        int #0x81
        iret

exit:
    xor bx, bx
    movb bl, al
    xor ax, ax
    int #0x79



start:
    | Print @msg
    call kbanner_extension
    
    | Set Interrupt Handler
    push es
    xor ax, ax
    mov es, ax
    mov di, #0x20 * 4
    mov ax, #int20
    stosw
    mov ax, cs
    stosw
    mov ax, #int21
    stosw
    mov ax, cs
    stosw
    pop es

    | Exit
    call husis_exit_main

end:

