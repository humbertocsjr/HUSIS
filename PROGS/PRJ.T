! Project Compiler
! Humberto Costa dos Santos Junior, 2022
! 3-Clause BSD license
! Compile file .prj in .t


const TRUE = %1;
const FALSE = 0;

str_len(txt) 
! Get ASCIZ string length
    return t.memscan(txt, 0, 2048);

str_copy(dest, orig) 
! Copy string contents to another
    t.memcopy(dest, orig, str_len(orig)+1);

str_concat(dest, orig)
! Concat string
    t.memcopy(@dest::str_len(dest), orig, str_len(orig)+1);

str_equal(txt1, txt2)
! Compare strings returning true if equals
    return t.memcomp(txt1, txt2, str_len(txt1)+1) = 0;

buffer_init(buffer, total_len) do
    if(total_len < 10) return FALSE;
    buffer[0] := total_len - 6;
    buffer[1] := 0;
    buffer[2] := 0;
    buffer[3] := 0;
    return TRUE;
end
readln(file, buffer, dest, dest_len) do
    var i, j, contents;
    if(buffer[1] = 0) do
        buffer[1] := t.read(file, @buffer[3], buffer[0]);
        if(buffer[1] = 0) return FALSE;
        buffer[2] := 0;
    end
    dest::0 := 0;
    contents := @buffer[3];
    j := buffer[2];
    for(i=0,dest_len-1) do
        if(j >= buffer[1]) do
            ie(buffer[1] = buffer[0])do
                buffer[1] := t.read(file, @buffer[3], buffer[0]);
                if(buffer[1] = 0)do
                    ie(i > 0)
                        return TRUE;
                    else
                        return FALSE;
                end
                buffer[2] := 0;
                j := 0;
            end
            else return (i > 0);
        end
        if(contents::j = 0) ie(i > 0) leave; else return FALSE;
        if(contents::j = '\n')do
            buffer[2] := j + 1;
            leave;
        end
        ie(contents::j \= '\r') do
            dest::i := contents::j;
            dest::(i+1) := 0;
        end
	    else i := i - 1;
        j := j + 1;
        buffer[2] := j;
    end
    return TRUE;
end

do
    var file_in, file_out, name_in::128, name_out::128, name_import::128,
        buffer::1024, file_import, contents::1024, len;
    if(t.getarg(1, name_in, 100) = FALSE) halt 1;
    if(t.getarg(2, name_out, 100) = FALSE) halt 1;
    buffer_init(buffer, 1024);
    file_in := t.open(name_in, T3X.OREAD);
    file_out := t.open(name_out, T3X.OWRITE);
    while(readln(file_in, buffer, name_import, 128)) do
        if(str_len(name_import) > 0) do
            t.write(file_out, "\n! DONT EDIT THIS FILE\n", 23);
            t.write(file_out, "! DONT EDIT THIS FILE\n", 22);
            t.write(file_out, "! DONT EDIT THIS FILE\n", 22);
            t.write(file_out, "! DONT EDIT THIS FILE\n", 22);
            t.write(file_out, "! DONT EDIT THIS FILE\n", 22);
            t.write(file_out, "! DONT EDIT THIS FILE\n", 22);
            t.write(file_out, "! DONT EDIT THIS FILE\n", 22);
            t.write(file_out, "! DONT EDIT THIS FILE\n", 22);
            t.write(file_out, "! DONT EDIT THIS FILE\n", 22);
            t.write(file_out, "! DONT EDIT THIS FILE\n", 22);
            t.write(file_out, "! DONT EDIT THIS FILE\n", 22);
            t.write(file_out, "! DONT EDIT THIS FILE\n", 22);
            t.write(file_out, "! DONT EDIT THIS FILE\n", 22);
            t.write(file_out, "! DONT EDIT THIS FILE\n", 22);
            t.write(file_out, "! DONT EDIT THIS FILE\n", 22);
            t.write(file_out, "! DONT EDIT THIS FILE\n", 22);
            t.write(file_out, "\n!#IMPORT ", 10);
            t.write(file_out, name_import, str_len(name_import));
            t.write(file_out, "\n", 1);
            file_import := t.open(name_import, T3X.OREAD);
            if(file_import < 0) do
                t.write(T3X.SYSOUT, "Error: ", 7);
                t.write(T3X.SYSOUT, name_import, str_len(name_import));
                t.write(T3X.SYSOUT, " not found.", 11);
                halt 2;
            end
            len := 1;
            while(len > 0) do
                len := t.read(file_import, contents, 1024);
                t.write(file_out, contents, len);
            end
            t.close(file_import);
        end
    end
    t.close(file_in);
    t.close(file_out);
end