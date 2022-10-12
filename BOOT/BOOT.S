jmps PreInicio
.ascii "HC"
SetoresPorTrilha:
    .word ConstSetoresPorTrilha
Cabecas:
    .word ConstCabecas
Disco:
    .word 0
SegTemp:
    .word 0
SegTempItens:
    .word 0
TotalItens:
    .word 0
TotalBlocos:
    .word 0
PosItens:
    .word 0
TotalBlocosItens:
    .word 0
TamListaItens:
    .word 0
Destino:
    .word 0x600 + (256 / 16)
Chamar:
    .word 0x600
ChamarIP:
    .word 256

PreInicio: | 0
    | Realoca para o fim da memoria RAM
    cld
    xor ax, ax
    int #0x12
    movb cl, #6
    shl ax, cl
    sub ax, #5120/16
    mov es, ax
    mov ax, #0x7c0
    mov ds, ax
    xor di, di
    xor si, si
    mov cx, #256
    rep
    movsw
    | Inicia os registradores e pilha
    mov ax, es
    mov ds, ax
    cli
    mov ss, ax
    mov sp, #4096
    sti
    | Pula para o inicio
    movb Disco, dl
    push ax
    mov ax, #Inicio
    push ax
    retf

Escreva: | 1
    push bp
    mov bp, sp
    push ax
    push si
    push ds
    push cs
    pop ds
    mov si, 2[bp]
    _inicial1_loop:
        lodsb
        cmpb al, #0
        je _inicial1_fim
        movb ah, #0xe
        int #0x10
        jmps _inicial1_loop
    _inicial1_fim:
    mov 2[bp], si
    pop ds
    pop si
    pop ax
    mov sp, bp
    pop bp
    ret

|#func DiscoLeia
|#arg es:0 = Destino
|#arg dx:ax = Endereco
|#arg cx = Blocos
DiscoLeia: | 2
    push es
    push ds
    push ax
    push bx
    push cx
    push dx
    push di
    | Prepara
    xor di, di
    xor bx, bx
    _inicial2_leia:
        push ax
        push bx
        push dx
        push cx
        seg cs
        div SetoresPorTrilha
        movb cl, dl
        xor dx, dx
        seg cs
        div Cabecas
        movb ch, al
        movb dh, dl
        rorb ah
        rorb ah
        andb ah, #0x3f
        incb cl
        orb cl, ah
        mov si, #5
        seg cs
        movb dl, Disco
        xor bx, bx
        _inicial2_tenta:
            call Ponto
            mov ax, #0x201
            int #0x13
            jnc _inicial2_ok
            xor ax, ax
            int #0x13
            dec si
            cmp si, #0
            jne _inicial2_tenta
            call EscrevaCHS
            jmp Erro
        _inicial2_ok:
        mov ax, es
        add ax, #512/16
        mov es, ax
        pop cx
        pop dx
        pop bx
        pop ax
        add ax, #1
        adc dx, #0
        loop _inicial2_leia
    stc
    _inicial2_fim:
    pop di
    pop dx
    pop cx
    pop bx
    pop ax
    pop ds
    pop es
    ret

Inicio: | 3
    | Calcula posicao temporaria
    mov ax, cs
    add ax, #4096/16
    mov SegTemp, ax
    mov es, ax
    | Calcula posicao da extensao 
    mov ax, cs
    add ax, #512/16
    mov es, ax
    | Exibe mensagem
    call Escreva
    .byte 10
    .byte 13
    .asciz "MinixFS"
    | Carrega bloco extensao
    mov ax, #1
    xor dx, dx
    mov cx, #1
    call DiscoLeia
    | Carrega bloco indice do MinixFS
    mov ax, SegTemp
    mov es, ax
    mov ax, #2
    xor dx, dx
    mov cx, #1
    call DiscoLeia
    | Verifica a versao do MinixFS
    seg es
    mov ax, 16
    | Versao 1 com 30 bytes de nome
    cmp ax, #5007 
    je _inicial3_ok
        call Erro
    _inicial3_ok:
    call Ponto
    | Copia dados importantes para o carregamento
    seg es
    mov ax, 2
    mov TotalBlocos, ax
    seg es
    mov ax, 0
    mov TotalItens, ax
    mov cx, #5
    shr ax, cl
    mov TotalBlocosItens, ax
    mov ax, TotalItens
    mov cx, #5
    shl ax, cl
    mov TamListaItens, ax
    mov ax, #2
    seg es
    add ax, 4
    seg es
    add ax, 6
    mov PosItens, ax
    | Calcula posicao da lista de itens
    mov ax, cs
    mov bx, TamListaItens
    mov cx, #3
    shr bx, cl
    sub ax, bx
    mov es, ax
    mov SegTempItens, ax
    call Ponto
    | Carrega Lista de Itens
    xor dx, dx
    mov cx, TotalBlocosItens
    mov ax, PosItens
    call DiscoLeia1KiB
    call Ok
    call BuscaArq


    jmp Infinito

EscrevaUShort: | 4
    pushf
    push ax
    push dx
    xor dx, dx
    seg cs
    div _inicial4_div
    cmp ax, #0
    je _inicial4_pula
        call EscrevaUShort
    _inicial4_pula:
    movb ah, #0xe
    movb al, dl
    addb al, #'0'
    int #0x10
    pop dx
    pop ax
    popf
    ret
    _inicial4_div:
        .word 10

DiscoLeia1KiB: | 5
    push ax
    push dx
    push cx
    shl ax
    rcl dx
    shl cx
    call DiscoLeia
    pop cx
    pop dx
    pop ax
    ret

Ponto: | 6
    call Escreva
    .asciz "."
    ret

Ok: | 7
    call Escreva
    .ascii "[OK]"
    .byte 13
    .byte 10
    .byte 0
    ret

Erro: | 8
    call Escreva
    .asciz "[Erro]"

Infinito: | 9
    hlt
    jmp Infinito


Fim:
.zerob 510-Fim
.byte 0x55
.byte 0xaa
| Bloco extensao
Nome:
    .asciz "husis"
FimNome:
.zerob 542-FimNome

BuscaArq: | 10
    call Escreva
    .asciz "Busca"
    mov ax, SegTemp
    mov es, ax
    mov bx, #0
    _inicial10_loop:
        mov ax, bx
        mov ax, #1
        call CarregaBloco
        jc _inicial10_ok
        _inicial10_erro:
            call Erro
        _inicial10_ok:
        mov di, #2
        mov cx, #32
        _inicial10_busca:
            call Ponto
            push bx
            push cx
            push di
            cmp di, #1024
            ja _inicial10_erro
            mov si, #Nome
            mov cx, #30
            rep
            cmpsb
            pop di
            pop cx
            pop bx
            je _inicial10_encontrado
            add di, #32
            mov ax, di
            loop _inicial10_busca
        inc bx
        jmp _inicial10_busca
    _inicial10_encontrado:
    call Ok
    call Escreva
    .asciz "Carregando Item "
    seg es
    mov ax, -2[di]
    call EscrevaUShort
    push ax
    mov ax, Destino
    mov es, ax
    pop ax
    xor bx, bx
    _inicial10_arq:
        call CarregaBloco
        jnc _inicial10_fim
        push ax
        mov ax, es
        add ax, #1024/16
        mov es, ax
        pop ax
        inc bx
        jmp _inicial10_arq
    _inicial10_fim:
    call Ok
    seg cs
    mov ax, Chamar
    mov es, ax
    seg cs
    mov dx, Disco
    cmp dx, #0x80
    jb _inicial10_disquete
        and dx, #0x7
        seg cs
        movb ArgumentoDisco, #'1'
        seg cs
        movb ArgumentoDisco+1, #'2'
    _inicial10_disquete:
    add dx, #'0'
    seg cs
    movb ArgumentoDisco+2, dl
    mov ax, cs
    mov ds, ax
    mov si, #Argumento
    mov di, #0x81
    seg es
    movb 0x80, cl
    mov cx, #Tam_Argumento
    rep
    movsb
    seg cs
    mov ax, Chamar
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, #0xffff
    mov 0x10, #1989
    seg cs
    mov dx, Disco
    xor bx, bx
    xor dx, dx
    xor di, di
    xor si, si
    push ds
    seg cs
    push ChamarIP
    retf

| ax = Item
| bx = Zona
CarregaBloco: | 11
    push ax
    push bx
    push cx
    push dx
    push es
    push ds
    push si
    | Define o ponteiro ds:si para o item
    dec ax
    mov cx, ax
    mov ax, SegTempItens
    mov ds, ax
    mov ax, #32
    mul cx
    mov si, ax
    cmp bx, #7
    jb _inicial11_direto
    cmp bx, #7 + 512
    jb _inicial11_indireto
    call Erro
    _inicial11_direto:
        add si, #0xe
        shl bx
        mov ax, [bx_si]
        cmp ax, #0
        je _inicial11_vazio
        xor dx, dx
        mov cx, #1
        call Ponto
        |call Escreva
        |.asciz "["
        |call EscrevaUShort
        |call Escreva
        |.asciz "]"
        call DiscoLeia1KiB
        stc
        jmp _inicial11_fim
    _inicial11_indireto:
        add si, #0x1c
        sub bx, #7
        shl bx
        mov ax, [si]
        cmp ax, #0
        je _inicial11_vazio
        call Ponto
        |call Escreva
        |.asciz "[Indireto "
        push es
        seg cs
        push SegTemp
        pop es
        xor dx, dx
        mov cx, #1
        |call EscrevaUShort
        |call Escreva
        |.asciz "]"
        call DiscoLeia1KiB
        seg es
        mov ax, [bx]
        pop es
        cmp ax, #0
        je _inicial11_vazio
        xor dx, dx
        mov cx, #1
        call Ponto
        |call Escreva
        |.asciz "["
        |call EscrevaUShort
        |call Escreva
        |.asciz "]"
        call DiscoLeia1KiB
        stc
        jmp _inicial11_fim
    _inicial11_vazio:
        clc
    _inicial11_fim:
    pop si
    pop ds
    pop es
    pop dx
    pop cx
    pop bx
    pop ax
    ret

EscrevaCHS:
    push ax
    xor ax, ax
    call Escreva
    .asciz "["
    movb al, ch
    call EscrevaUShort
    call Escreva
    .asciz ":"
    movb al, dh
    call EscrevaUShort
    call Escreva
    .asciz ":"
    movb al, cl
    call EscrevaUShort
    call Escreva
    .asciz "]"
    pop ax
    ret


Fim2:
.zerob 952-Fim2
Argumento:
.ascii " "
ArgumentoDisco:
.ascii "000 "

Tam_Argumento = 72
