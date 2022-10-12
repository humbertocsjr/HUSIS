! HUSIS - Nucleo
! Humberto Costa dos Santos Junior, 2022
! 3-Clause BSD license

var _dos;

!
! Texto e Caractere
!

c_eh_numero(c) return (c >= '0') & (c <= '9');
c_eh_mai(c) return (c >= 'A') & (c <= 'Z');
c_eh_min(c) return (c >= 'a') & (c <= 'z');
c_eh_letra(c) return c_eh_mai(c) | c_eh_min(c);
c_eh_alfanum(c) return c_eh_numero(c) | c_eh_letra(c);

txt_tam(txt) 
    return t.memscan(txt, 0, 2048);

txt_copia(origem, destino) 
    t.memcopy(destino, origem, txt_tam(origem)+1);

txt_concat(origem, destino)
    t.memcopy(@destino::txt_tam(destino), origem, txt_tam(origem)+1);

txt_igual(txt1, txt2)
    return t.memcomp(txt1, txt2, txt_tam(txt1)+1) = 0;

rtxt_tam(seg, txt) 
    return t.farscan(seg, txt, 0, 2048);

rtxt_copia(sego, origem, segd, destino) 
    t.farcopy(segd, destino, sego, origem, txt_tam(origem)+1);

rtxt_concat(sego, origem, segd, destino)
    t.farcopy(
        segd, 
        @destino::rtxt_tam(segd, destino), 
        sego,
        origem, 
        rtxt_tam(sego, origem)+1);

rtxt_igual(seg1, txt1, seg2, txt2)
    return t.farcomp(seg1, txt1, seg2, txt2, rtxt_tam(seg1, txt1)+1) = 0;

!
! Terminal
!

var _term_atrib, _term_x, _term_y, _term_pos, _term_seg, _term_etapa, 
    _term_valor, _term_cmd;

struct CORES = COR_PRETO, COR_AZUL, COR_VERDE, COR_CIANO, COR_VERMELHO,
               COR_MAGENTA, COR_MARROM, COR_CINZA_CLARO, COR_CINZA,
               COR_AZUL_CLARO, COR_VERDE_CLARO, COR_CIANO_CLARO, 
               COR_VERMELHO_CLARO, COR_MAGENTA_CLARO, COR_AMARELO, COR_BRANCO;

term_inicia() do
    ! Ocultando cursor
    t.int86ax(0x10, 0x100,0,0x2020,0,0,0);
    _term_etapa := 0;
    _term_x := 0;
    _term_y := 0;
    _term_pos := 0;
    _term_atrib := 7 << 8;
    _term_seg := 0xb800;
end

term_limpa() do
    var i;
    _term_etapa := 0;
    _term_y := 0;
    _term_x := 0;
    _term_pos := 0;
    for(i=0,25*80) do
        t.farsetw(_term_seg, i<<1, ' ' | (_term_atrib << 8));
    end
end

term_va_para(x, y) do
    _term_x := x;
    _term_y := y;
    _term_pos := (_term_y * 80 + _term_x) << 1;
    if(_term_x > 79) do
        _term_x := _term_x - 80;
        _term_y := _term_y + 1;
    end
    if(_term_y > 24) do
        _term_pos := 0;
        _term_y := 0;
    end
end

term_cor_fundo(cor) do
    _term_atrib := (_term_atrib & 0x0f00) | (cor << 12);
end

term_cor_texto(cor) do
    _term_atrib := (_term_atrib & 0xf000) | (cor << 8);
end

term_cores(texto, fundo) do
    _term_atrib := (fundo << 12) | (texto << 8);
end

term_escreva_c(c) do
    var i;
    if(c = '\e') do
    _term_etapa := 1;
    return;
    end
    if(_term_etapa > 0) do
        ie(_term_etapa = 1) do
            _term_valor := 0;
            _term_etapa := 0;
            _term_cmd := c;
            ie(c = 'l') term_limpa();
            else ie(c = 'f') _term_etapa := 2;
            else ie(c = 't') _term_etapa := 2;
            else ie(c = 'x') _term_etapa := 2;
            else ie(c = 'y') _term_etapa := 2;
            else ie(c = 'r') _term_etapa := 2;
            else _term_etapa := 0;
        end 
        else ie(_term_etapa = 2) do
            _term_etapa := 3;
            if(\c_eh_numero(c)) _term_etapa := 0;
            _term_valor := (c - '0') * 10;
        end
        else ie(_term_etapa = 3) do
            _term_etapa := 0;
            if(\c_eh_numero(c)) return;
            _term_valor := (c - '0') + _term_valor;
            ie(_term_cmd = 'x') term_va_para(_term_valor, _term_y);
            else ie(_term_cmd = 'y') term_va_para(_term_x, _term_valor);
            else ie(_term_cmd = 'r') _term_etapa := 4;
            else ie(_term_cmd = 't') term_cor_texto(_term_valor);
            else ie(_term_cmd = 'f') term_cor_fundo(_term_valor);
            else _term_etapa := 0;
        end
        else ie(_term_etapa = 4) do
            _term_etapa := 0;
            if(_term_cmd = 'r') for(i=0,_term_valor) term_escreva_c(c);
        end
        else _term_etapa := 0;
        return;
    end
    if(c = 13) do
        term_va_para(0, _term_y);
        return;
    end
    if(c = 10) do
        term_va_para(0, _term_y + 1);
        return;
    end
    if(c = 8) do
        ie(_term_x = 0)
            term_va_para(79, _term_y - 1);
        else
            term_va_para(_term_x - 1, _term_y);
        return;
    end
    if(c = 9) do
        c := ' ';
    end
    t.farsetw(_term_seg, _term_pos, c | _term_atrib);
    _term_pos := _term_pos + 2;
    _term_x := _term_x + 1;
    if(_term_x > 79) do
        _term_x := 0;
        _term_y := _term_y + 1;
    end
    if(_term_y > 24) do
        _term_pos := 0;
        _term_y := 0;
    end
end

term_escreva(txt) do
    var i, etapa;
    etapa := 0;
    for(i=0,txt_tam(txt)) do
    ie(etapa = 0) do
        if(txt::i = '\\') do
        etapa := 1;
        loop;
        end
        term_escreva_c(txt::i);
    end
    else do
        ie(txt::i = 'n') term_escreva_c('\n');
        else ie(txt::i = 'r') term_escreva_c('\r');
        else ie(txt::i = 'q') term_escreva_c('\q');
        else ie(txt::i = 'e') term_escreva_c('\e');
        else term_escreva_c(txt::i);
        etapa := 0;
    end
    end
end

term_escreval(txt) do
    term_escreva(txt);
    term_escreva_c(13);
    term_escreva_c(10);
end

term_escreva_em(x, y, texto) do 
    var tmp_x, tmp_y, tmp_pos;
    tmp_x := _term_x;
    tmp_y := _term_y;
    tmp_pos := _term_pos;
    term_va_para(x, y);
    term_escreva(texto);
    _term_x := tmp_x;
    _term_y := tmp_y;
    _term_pos := tmp_pos;
end

term_escreva_int(valor) do
    var tmp, tmp2;
    if(valor < 0) do
        term_escreva_c('-');
        valor := -valor;
    end
    tmp := valor mod 10;
    tmp2 := valor / 10;
    if (tmp2 > 0) term_escreva_int(tmp2);
    term_escreva_c(tmp + '0'); 
end

term_escreva_hex(valor) do
    var tmp, tmp2;
    if(valor < 0) do
        term_escreva_c('-');
        valor := -valor;
    end
    tmp := valor mod 16;
    tmp2 := valor / 16;
    if (tmp2 > 0) term_escreva_hex(tmp2);
    ie (tmp < 10) term_escreva_c(tmp + '0'); 
    else term_escreva_c(tmp + 'a' - 10);
end

term_leia_scan() do
    return t.int86ax(0x16, 0,0,0,0, 0,0);
end

term_leia_c() do
    return term_leia_scan() & 0xff;
end

term_disp() do
    return (t.int86z(0x16, 0x100,0,0,0, 0,0) = 1) -> 0 : 1;
end

term_leia(dest, tam) do
    var pos, c;
    pos := 0;
    dest::pos := 0;
    term_escreva_c('_');
    while(%1) do
        c := term_leia_c();
        if (c = 0xd) leave;
        if (c = 0xa) leave;
        ie (c = 0x8) do
            if (pos = 0) loop;
            term_escreva_c(c);
            term_escreva_c(c);
            term_escreva("_ ");
            term_escreva_c(c);
            pos := pos - 1;
        end
        else do
            if ((pos + 2) > tam) loop;
            dest::pos := c;
            term_escreva_c(8);
            term_escreva_c(c);
            term_escreva_c('_');
            pos := pos + 1;
        end
        dest::pos := 0;
    end
    term_escreva_c(8);
    term_escreva_c(' ');
    term_escreva_c(13);
    term_escreva_c(10);
    return pos;
end 

!
! Unidades
!

const ST_UNIDADE_VAZIO = 0;
const ST_UNIDADE_DESMONTADO = 1;
const ST_UNIDADE_MONTADO = 2;
const ST_UNIDADE_FIM = 255;

const UNIDADE_STATUS = 0;
const UNIDADE_ID = 1;
const UNIDADE_DISCO = 2;
const UNIDADE_PTR_LEIA = 3;
const UNIDADE_SEG_LEIA = 4;
const UNIDADE_PTR_ESCREVA = 5;
const UNIDADE_SEG_ESCREVA = 6;
const UNIDADE_PTR_ITEM = 7;
const UNIDADE_SEG_ITEM = 8;
const UNIDADE_PTR_DESMONTA = 9;
const UNIDADE_SEG_DESMONTA = 10;
const UNIDADE_CILINDROS = 11;
const UNIDADE_CABECAS = 12;
const UNIDADE_SETORES = 13;

const UNIDADE_TOTAL_ITENS = 14;
const UNIDADE_TOTAL_BLOCOS = 15;
const UNIDADE_MAPA_ITENS = 16;
const UNIDADE_MAPA_BLOCOS = 17;
const UNIDADE_LISTA_ITENS = 18;

const CAP_ENDERECO = 128;

const TAM_ITEM = 48;
const ITEM_ID = 0;
const ITEM_PTR_ABRA = 2;
const ITEM_SEG_ABRA = 4;
const ITEM_TIPO = 6;
const ITEM_RESERVADO = 7;
const ITEM_NOME = 8;

var _unidades, _unidade_atual, _endereco::CAP_ENDERECO;


unidade_inicia() do
    txt_copia("/", _endereco);
    _unidade_atual := 0;
    _unidades := 
    [
        [ST_UNIDADE_VAZIO,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
        [ST_UNIDADE_VAZIO,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
        [ST_UNIDADE_VAZIO,2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
        [ST_UNIDADE_VAZIO,3,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
        [ST_UNIDADE_VAZIO,4,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
        [ST_UNIDADE_VAZIO,5,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
        [ST_UNIDADE_VAZIO,6,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
        [ST_UNIDADE_VAZIO,7,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
        [ST_UNIDADE_FIM]
    ];
end

unidade_reserva() do
    var i;
    i := 0;
    while(_unidades[i][UNIDADE_STATUS] \= ST_UNIDADE_FIM) do
    if(_unidades[i][UNIDADE_ID] = ST_UNIDADE_VAZIO) do
        _unidades[i][UNIDADE_STATUS] := ST_UNIDADE_DESMONTADO; 
        return i;
    end
    i := i + 1;
    end
    return %1;
end

unidade_leia(unid, cil, cab, set, destino) do
    var ptr::T3X.PTRSIZE;
    if(_unidades[unid][UNIDADE_STATUS] = ST_UNIDADE_VAZIO) return 1=0;
    if(_unidades[unid][UNIDADE_SEG_LEIA] = 0) return 1=0;
    t.setptr(ptr, 
        _unidades[unid][UNIDADE_SEG_LEIA],
        _unidades[unid][UNIDADE_PTR_LEIA]);
    callfar ptr(_unidades[unid][UNIDADE_DISCO], cil, cab, set, destino);
    return 1=1;
end

unidade_escreva(unid, cil, cab, set, destino) do
    var ptr::T3X.PTRSIZE;
    if(_unidades[unid][UNIDADE_STATUS] = ST_UNIDADE_VAZIO) return 1=0;
    if(_unidades[unid][UNIDADE_SEG_ESCREVA] = 0) return 1=0;
    t.setptr(ptr, 
        _unidades[unid][UNIDADE_SEG_ESCREVA],
        _unidades[unid][UNIDADE_PTR_ESCREVA]);
    callfar ptr(_unidades[unid][UNIDADE_DISCO], cil, cab, set, destino);
    return 1=1;
end

unidade_item(unid, acima, pos, destino) do
    var ptr::T3X.PTRSIZE, status[1];
    if(_unidades[unid][UNIDADE_STATUS] = ST_UNIDADE_VAZIO) return 1=0;
    if(_unidades[unid][UNIDADE_SEG_ITEM] = 0) return 1=0;
    t.setptr(ptr, 
        _unidades[unid][UNIDADE_SEG_ITEM],
        _unidades[unid][UNIDADE_PTR_ITEM]);
    callfar ptr(_unidades[unid][UNIDADE_DISCO], acima, pos, destino, status);
    return status[0];
end

!
! Disco
!

disco_redefine(disco) do
    return  (t.int86c(0x13, 0,0,0,disco, 0,0) = 1) -> 0 : 1;
end

disco_leia(disco, cil, cab, set, destino) far do
    var ax, bx, cx, dx, ret, i;
    ax := 0x201;
    bx := destino;
    cx := (cil << 8) | set | ((cil >> 8) << 6);
    dx := disco | (cab << 8);
    for(i=0,3) do
        if(t.int86c(0x13, ax,bx,cx,dx, 0,0) = 0) return 1;
        disco_redefine(disco);
    end
    return 0;
end

disco_escreva(disco, cil, cab, set, origem) far do
    var ax, bx, cx, dx, ret, i;
    ax := 0x301;
    bx := origem;
    cx := (cil << 8) | set | ((cil >> 8) << 6);
    dx := disco | (cab << 8);
    for(i=0,3) do
        if(t.int86c(0x13, ax,bx,cx,dx, 0,0) = 0) return 1;
        disco_redefine(disco);
    end
    return 0;
end

disco_registra(disco, cil, cab, set) do
    var unidade;
    unidade := unidade_reserva();
    _unidades[unidade][UNIDADE_PTR_LEIA] := @disco_leia;
    _unidades[unidade][UNIDADE_SEG_LEIA] := t.local();
    _unidades[unidade][UNIDADE_PTR_ESCREVA] := @disco_escreva;
    _unidades[unidade][UNIDADE_SEG_ESCREVA] := t.local();
    _unidades[unidade][UNIDADE_CILINDROS] := cil;
    _unidades[unidade][UNIDADE_CABECAS] := cab;
    _unidades[unidade][UNIDADE_SETORES] := set;
    _unidades[unidade][UNIDADE_DISCO] := disco;
    _unidade_atual := unidade;
end

!
! Sistema de Arquivos Minix
!

minixfs_leia_bloco(unidade, posicao, destino) do
    var cil, cab, set, set_tot, cab_tot, cil_tot;
    posicao := posicao << 1;
    cil_tot := _unidades[unidade][UNIDADE_CILINDROS];
    cab_tot := _unidades[unidade][UNIDADE_CABECAS];
    set_tot := _unidades[unidade][UNIDADE_SETORES];
    cil := posicao / (cab_tot * set_tot);
    cab := (posicao / set_tot) mod cab_tot;
    set := (posicao mod set_tot) + 1;
    if(cil >= cil_tot) return 0;
    unidade_leia(unidade, cil, cab, set, destino);
    posicao := posicao + 1;
    cil := posicao / (cab_tot * set_tot);
    cab := (posicao / set_tot) mod cab_tot;
    set := (posicao mod set_tot) + 1;
    if(cil >= cil_tot) return 0;
    unidade_leia(unidade, cil, cab, set, @destino::512);
    return 1;
end

minixfs_escreva_bloco(unidade, posicao, origem) do
    var cil, cab, set, set_tot, cab_tot, cil_tot;
    posicao := posicao << 1;
    cil_tot := _unidades[unidade][UNIDADE_CILINDROS];
    cab_tot := _unidades[unidade][UNIDADE_CABECAS];
    set_tot := _unidades[unidade][UNIDADE_SETORES];
    cil := posicao / (cab_tot * set_tot);
    cab := (posicao / set_tot) mod cab_tot;
    set := (posicao mod set_tot) + 1;
    if(cil >= cil_tot) return 0;
    unidade_escreva(unidade, cil, cab, set, origem);
    posicao := posicao + 1;
    cil := posicao / (cab_tot * set_tot);
    cab := (posicao / set_tot) mod cab_tot;
    set := (posicao mod set_tot) + 1;
    if(cil >= cil_tot) return 0;
    unidade_escreva(unidade, cil, cab, set, @origem::512);
    return 1;
end

minixfs_leia_lista(unidade, id, registro) do
    var bloco::1024, atual, ret, pos_reg;
    ret := id < _unidades[unidade][UNIDADE_TOTAL_ITENS];
    if(\ret) return ret;
    atual := _unidades[unidade][UNIDADE_LISTA_ITENS];
    pos_reg := (id mod 32) * 32;
    if(id > 32) do
        atual := atual + (id / 32);
    end
    ret := minixfs_leia_bloco(unidade, atual, bloco);
    if(\ret) return ret;
    t.memcopy(registro, @bloco::pos_reg, 32);
    return ret;
end

minixfs_lista_item(unidade, acima, pos, destino, status) far do
    var registro[16];
    status[0] := minixfs_leia_lista(unidade, acima, registro);
    if(\status[0]) return;

    if(registro[16])

    status[0] := 1=0;
    
end

minixfs_monta(unidade) do
    var bloco::1024, assinatura, pos;
    if(minixfs_leia_bloco(unidade, 1, bloco) = 0) return 1=0;
    assinatura := bloco::16 | (bloco::17 << 8);
    if(assinatura \= 5007) return 1=0;
    _unidades[unidade][UNIDADE_TOTAL_ITENS] := bloco::0 | (bloco::1 << 8);
    _unidades[unidade][UNIDADE_TOTAL_BLOCOS] := bloco::2 | (bloco::3 << 8);
    pos := 2;
    _unidades[unidade][UNIDADE_MAPA_ITENS] := pos;
    pos := pos + (bloco::4 | (bloco::5 << 8));
    _unidades[unidade][UNIDADE_MAPA_BLOCOS] := pos;
    pos := pos + (bloco::6 | (bloco::7 << 8));
    _unidades[unidade][UNIDADE_LISTA_ITENS] := pos;
    _unidades[unidade][UNIDADE_SEG_ITEM] := t.local();
    _unidades[unidade][UNIDADE_PTR_ITEM] := @minixfs_lista_item;
    return 1=1;
end



!
! Manipuladores de Interrupcao
!


int_registra(ptr_ant, int, funcao) do
    t.setptr(ptr_ant, t.fargetw(0, int*4+2), t.fargetw(0, int*4));
    t.farsetw(0, int*4, funcao);
    t.farsetw(0, int*4+2, t.local());
end

int_restaura(ptr_ant, int) do
    t.farsetw(0, int*4, t.getoff(ptr_ant));
    t.farsetw(0, int*4+2, t.getseg(ptr_ant));
end

debug_int(int,ax,bx,cx,dx,ds,si,es,di) do
    term_escreva("[INT 0x");
    term_escreva_hex(int);
    term_escreva(" AX ");
    term_escreva_int(ax);
    term_escreva(" AH 0x");
    term_escreva_hex(ax >> 8);
    term_escreva(" BX ");
    term_escreva_int(bx);
    term_escreva(" CX ");
    term_escreva_int(cx);
    term_escreva(" DX ");
    term_escreva_int(dx);
    term_escreva(" DS ");
    term_escreva_int(es);
    term_escreva(" SI ");
    term_escreva_int(si);
    term_escreva(" ES ");
    term_escreva_int(es);
    term_escreva(" DI ");
    term_escreva_int(di);
    term_escreva("]\r\n");
end

int79(ax,bx,cx,dx,ds,si,es,di,ss,sp) farint do
    ax := %5;
    term_escreva("Oiee");
    return 0;
end

int20(ax,bx,cx,dx,ds,si,es,di,ss,sp) farint do
    debug_int(0x20, ax,bx,cx,dx,ds,si,es,di);
end

int21(ax,bx,cx,dx,ds,si,es,di,ss,sp) farint do
    var funcao,i,qtd,atrib,tmp;
    funcao := ax >> 8;
    ie(funcao = 0x1) do
        tmp := term_leia_c();
        term_escreva_c(tmp);
        ax := (funcao << 8) | tmp;
    end
    else ie(funcao = 0x2) term_escreva_c(ax & 0xff);
    else ie(funcao = 0x6) do
        ie((dx&0xff) = 0xff) do
            tmp := 0;
            if(term_disp()) tmp := term_leia_c();
            ax := (funcao << 8) | tmp;
        end
        else term_escreva_c(dx & 0xff);
    end
    else ie(funcao = 0x7) ax := (funcao << 8) | term_leia_c();
    else ie(funcao = 0x8) ax := (funcao << 8) | term_leia_c();
    else ie(funcao = 0x9) do ! Escreva string
        for(i=0,3072) do 
            if(dx::i = '$') leave;
            term_escreva_c(dx::i);
        end
    end
    else ie(funcao = 0xa) do ! Leia string
        i := term_leia(@dx::2, dx::0);
        dx::1 := i;
        dx::i := 0xd;
    end
    else ie(funcao = 0xb) ax := (funcao << 8) | (term_disp() -> 0xff:0);
    else ie(funcao = 0xc) ax := (funcao << 8) | term_leia_c();
    else ie(funcao = 0x40) do ! Escreva bloco
        ie(bx = 1) do
            for(i=0,cx) do 
                if(dx::i = 0) leave;
                term_escreva_c(dx::i);
            end
        end
        else ie(bx = 2) do
            atrib := _term_atrib;
            term_cor_texto(COR_VERMELHO);
            for(i=0,cx) do 
                if(dx::i = 0) leave;
                term_escreva_c(dx::i);
            end
            _term_atrib := atrib;
        end
        else do
            term_escreva("[0x40 em ");
            term_escreva_int(bx);
            term_escreva("]");
        end
    end
    else do
        debug_int(0x21, ax,bx,cx,dx,ds,si,es,di);
        ax := 0;
    end
end

separa_linha(linha, tam, cmd, cmd_tam, args, args_tam) do
    var i, etapa, pos;
    cmd::0 := 0;
    args::0 := 0;
    etapa := 0;
    pos := 0;
    for(i=0,tam) do
        if (linha::i = 0) leave;
        ie (etapa = 0) do
            if (pos >= cmd_tam) leave;
            if (linha::i = ' ') do
                etapa := 1;
                pos := 0;
                loop;
            end
            cmd::pos := linha::i;
            pos := pos + 1;
            cmd::pos := 0;
        end
        else do
            if (pos = 0) if(linha::i = ' ') loop;
            if (pos >= args_tam) leave;
            args::pos := linha::i;
            pos := pos + 1;
            args::pos := 0;
        end
    end
end

cmd_cls(args) do
    term_cor_texto(COR_CINZA_CLARO);
    term_limpa();
end

cmd_echo(args) do
    term_escreval(args);
end

cmd_ver(args) do
    term_escreva("HUSIS");
    term_cor_texto(COR_VERMELHO);
    term_escreval(" 2022");
    term_cor_texto(COR_CINZA_CLARO);
    term_escreval("Copyright (c) 2022, Humberto Costa dos Santos Junior");
end

cmd_regdisco(args) do
    ie (txt_igual(args, "a1440")) disco_registra(0, 80, 2, 18);
    else ie (txt_igual(args, "a1200")) disco_registra(0, 80, 2, 15);
    else ie (txt_igual(args, "a720")) disco_registra(0, 40, 2, 18);
    else ie (txt_igual(args, "a360")) disco_registra(0, 40, 2, 9);
    else ie (txt_igual(args, "b1440")) disco_registra(1, 80, 2, 18);
    else ie (txt_igual(args, "b1200")) disco_registra(1, 80, 2, 15);
    else ie (txt_igual(args, "b720")) disco_registra(1, 40, 2, 18);
    else ie (txt_igual(args, "b360")) disco_registra(1, 40, 2, 9);
    else do
        term_escreval("Disco nao suportado.");
        term_escreval("Aceito:");
        term_escreval(" A:     a360, a720, a1200, a1440");
        term_escreval(" B:     b360, b720, b1200, b1440");
        return 1=0;
    end
    return 1=1;
end

cmd_sistema(args) do
    var registro::TAM_ITEM, busca, encontrado;
    if(cmd_regdisco(args)) do
        if(\minixfs_monta(_unidade_atual)) do
            term_cor_texto(COR_VERMELHO);
            term_escreval("Disco corrompido");
            return;
        end
        term_cor_texto(COR_CIANO);
        term_escreva("Buscando");
        busca := 0;
        encontrado := 0;
        while(unidade_item(_unidade_atual, 0, busca, registro)) do
            term_escreva(" .");
            busca := busca + 1;
        end
        if(encontrado = 0) do
            term_escreval(" [ NAO ENCONTRADO ]");
        end
    end
end

cmd_muda(args) do
    ie(c_eh_mai(args::0)) _unidade_atual := args::0 - 'A';
    else ie(c_eh_min(args::0)) _unidade_atual := args::0 - 'a';
    else term_escreval("Unidade desconhecida");
end

exec(cmd, args) do
    ie (txt_igual(cmd, "cls")) cmd_cls(args);
    else ie (txt_igual(cmd, "echo")) cmd_echo(args);
    else ie (txt_igual(cmd, "ver")) cmd_ver(args);
    else ie (txt_igual(cmd, "regdisco")) cmd_regdisco(args);
    else ie (txt_igual(cmd, "sistema")) cmd_sistema(args);
    else ie (txt_igual(@cmd::1, ":") & txt_igual(args, "")) cmd_muda(cmd);
    else do
        term_cor_texto(COR_VERMELHO);
        term_escreva("Comando \q");
        term_cor_texto(COR_CINZA_CLARO);
        term_escreva(cmd);
        term_cor_texto(COR_VERMELHO);
        term_escreval("\q desconhecido");
    end
end


do
    var linha::128, cmd::32, args::128, i;
    var int79ant[T3X.PTRSIZE], int20ant[T3X.PTRSIZE], int21ant[T3X.PTRSIZE];
    int_registra(int79ant, 0x79, @int79);
    int_registra(int20ant, 0x20, @int20);
    int_registra(int21ant, 0x21, @int21);
    unidade_inicia();
    term_inicia();
    term_cores(COR_CIANO, COR_PRETO);
    term_limpa();
    cmd_ver("");
    _dos := t.fargetw(t.local(), 10) \= 1989;
    ie(_dos) do
        ! Executando a partir do DOS
        term_escreval("Modo limitado, preservando estruturas do DOS.");
    end
    else do
        ! Executando independente
    end
    term_escreva("\er80=");
    if(t.getarg(1, linha, 128) > 0) do
        cmd_sistema(linha);
    end
    while(%1) do
        term_cor_texto(COR_CIANO);
        term_escreva_c('[');
        term_escreva_c(_unidade_atual + 'A');
        term_escreva_c(']');
        term_escreva(_endereco);
        term_escreva("# ");
        term_cor_texto(COR_CINZA_CLARO);
        term_leia(linha, 128);
        separa_linha(linha, 128, cmd, 32, args, 128);
        if(txt_igual("sair", cmd)) leave;
        if(txt_igual("exit", cmd)) leave;
        if(txt_igual("", cmd)) loop;
        exec(cmd, args);
    end
    term_cores(COR_CINZA_CLARO, COR_PRETO);
    term_limpa();
    term_escreva("\ey13\ex33[ \et03Encerrado\et07 ]");
    int_restaura(int79ant, 0x79);
    int_restaura(int20ant, 0x20);
    int_restaura(int21ant, 0x21);
end