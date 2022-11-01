| CGA Video Controller
| Humberto Costa dos Santos Junior, 2022
| 3-Clause BSD license
| Video Controller

.include VIDEOAPI.S


| Info Header
name:
    .asciz "CGA Video Controller"
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


_x:
    .word 0
_y:
    .word 0
_ptr:
    .word 0
_colors:
    .word 0x0700

| Video APIs

video_can_customize: | __cga0
    mov ax, #FALSE
    ret

| bx = X
| cx = Y
video_goto: | __cga1
    push ax
    push bx
    push cx
    push dx
    seg cs
    mov _x, bx
    seg cs
    mov _y, cx
    __cga1XLoop:
        seg cs
        cmp _x, #80
        jb __cga1XOk
            seg cs
            inc _y
            seg cs
            sub _x, #80
            jmp __cga1XLoop
    __cga1XOk:
    seg cs
    cmp _y, #25
    jb __cga1YOk
        seg cs
        mov _y, #0
    __cga1YOk:
    mov ax, #80
    seg cs
    mul _y
    seg cs
    add ax, _x
    shl ax
    seg cs
    mov _ptr, ax
    pop dx
    pop cx
    pop bx
    pop ax
    ret

| bx = Char
video_write_char: | __cga2
    push ax
    push bx
    push cx
    push dx
    push es
    push di
    seg cs
    mov di, _ptr
    mov ax, #0xb800
    mov es, ax
    mov ax, bx
    and ax, #0xff
    seg cs
    or ax, _colors
    stosw
    seg cs
    mov bx, _x
    seg cs
    mov cx, _y
    call video_goto
    pop di
    pop es
    pop dx
    pop cx
    pop bx
    pop ax
    ret

| bx = String
video_write_string: | __cga3
    push ax
    push bx
    push cx
    push dx
    push si
    mov si, bx
    __cga3Loop:
        lodsb
        cmpb al, #0
        je __cga3End
        mov bx, ax
        call video_write_char
        jmps __cga3Loop
    __cga3End:
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret

video_cls: | __cga4
    push ax
    push bx
    push cx
    push dx
    push es
    push di
    mov ax, #0xb800
    mov es, ax
    xor di, di
    mov cx, #80*25*2
    seg cs
    mov ax, _colors
    or ax, #' '
    rep
    stosw
    pop di
    pop es
    pop dx
    pop cx
    pop bx
    pop ax
    ret

| bx = Foreground
| cx = Background
video_set_color: | __cga5
    push ax
    push bx
    push cx
    and bx, #0xf
    and cx, #0xf
    mov ax, cx
    mov cx, #12
    shl ax, cl
    mov cx, #8
    shl bx, cl
    or ax, bx
    seg cs
    mov _colors, ax
    pop cx
    pop bx
    pop ax
    ret

video_can_show_colors: | __cga6
    mov ax, #TRUE
    ret

video_set_font8x8: | __cga7
    mov ax, #FALSE
    ret

video_initialize: | __cga8
    mov ax, #0x100
    xor bx,bx
    mov cx, #0x2020
    xor dx, dx
    int #0x10
    ret

video_get_height: | __cga9
    mov ax, #25
    ret

video_get_width: | __cga10
    mov ax, #80
    ret

| bx = Char and Colors
video_write_char_color: | __cga11
    push ax
    push bx
    push cx
    push dx
    push es
    push di
    seg cs
    mov di, _ptr
    mov ax, #0xb800
    mov es, ax
    mov ax, bx
    stosw
    seg cs
    mov bx, _x
    seg cs
    mov cx, _y
    call video_goto
    pop di
    pop es
    pop dx
    pop cx
    pop bx
    pop ax
    ret

end: