! ==========================================================================
! Font Manipulation
! ==========================================================================


var Font8x8::4096;

load_font(font_file, font_dest, start)do
    var buffer::BUFFER_SIZE, tmp::128, stream[OBJ_STREAM], type, stage,
        i, x, y, ptr, value, count;
    ie(open_file(font_file, stream)) do
        stream_buffer_init(buffer, BUFFER_SIZE);
        stage := 0;
        type := 0;
        count := 0;
        while(stream_readln(stream, buffer, tmp, 256)) do
            ie(str_equal(tmp, "END")) do
                leave;
            end
            else ie(stage = 0) do ! Detect type
                ie(str_equal(tmp, "FONTBASE")) do
                    stage := 1;
                    type := 1;
                end
                else ie(str_equal(tmp, "FONTUTF8")) do
                    stage := 1;
                    type := 2;
                end
                else ie(str_equal(tmp, "FONTCUSTOM")) do
                    stage := 1;
                    type := 3;
                end
                else return 0;
            end
            else ie(stage = 1) do ! Read width
                x := str_to_num(tmp);
                stage := 2;
                if(x \= 8) return 0;
            end
            else ie(stage = 2) do ! Read height
                y := str_to_num(tmp);
                stage := 3;
                if((y < 6) | (y > 32)) return 0;
            end
            else ie(type = 1) do ! Read FONTBASE
                ie(stage = 3) do ! Read Position
                    ptr := str_to_hex(tmp) * y + start;
                    if(ptr > 4096) return 0;
                    stage := 4;
                    i := 0;
                end
                else ie(stage = 4) do ! Read Character line
                    value := str_to_binary(tmp);
                    font_dest::ptr := value;
                    ptr := ptr + 1;
                    i := i + 1;
                    if(i = y) stage := 3;
                end
                else return 0;
            end
            else return 0;
        end
        stream_close(stream);
        return ptr + 1;
    end
    else do
        return 0;
    end
end