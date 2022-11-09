! ==========================================================================
! Main
! ==========================================================================


splash_screen() do
    var buffer::512, tmp::256, stream[OBJ_STREAM];
    ie(open_file("/System/Splash.txt", stream)) do
        stream_buffer_init(buffer, 512);
        while(stream_readln(stream, buffer, tmp, 256)) do
            term_writefln(tmp);
        end
        stream_close(stream);
    end
    else do
        term_kwriteln("\eb00\ec\ef04SPLASHSCREEN NOT FOUND\ef07");
    end
end

progress(perc, text) do
    var txt::20;
    if(perc > 100) perc := 100;
    if(perc < 0) perc := 0;
    term_writes("\ex13\ey");
    str_from_num_fixed(txt, 2, term_get_height() - 5);
    term_writes(txt);
    str_from_num_fixed(txt, 2, perc >> 1);
    term_writes("\ef03[\eR");
    term_writes(txt);
    term_writes("1E");
    str_from_num_fixed(txt, 2, 50 - (perc >> 1));
    term_writes("\ef07\eR");
    term_writes(txt);
    term_writes("1E");
    term_writes("\ef03]\ef07\n\ex14");
    str_from_num_fixed(txt, 2, (50 - str_len(text)) / 2);
    term_writes("\eb00\ef07\er");
    term_writes(txt);
    term_writes(" ");
    term_writes(text);
    term_writes("\ex13\ey");
    str_from_num_fixed(txt, 2, term_get_height() - 7);
    term_writes(txt);
    term_writes("License:\ef03 3-Clause BSD\ef07");
    term_writes("\ex13\ey");
    str_from_num_fixed(txt, 2, term_get_height() - 6);
    term_writes(txt);
    term_writes("Version:\ef03 ");
    term_writenum(husis_get_version());
    term_writes(".");
    term_writenum(husis_get_sub_version());
    term_writes(" R");
    term_writenum(husis_get_revision());
    term_writes("\ef07");
end

do
    var i;
    for(i = 0, WINDOW_CAPACITY) do
        WindowList[i] := 0;
    end
    ! Set Theme Colors
    ThemeControl := LIGHT_GRAY;
    ThemeText := BLACK;
    ThemeWindowBorder := BLACK;
    ThemeWindowTitleBack := BLACK;
    ThemeWindowTitleText := WHITE;
    ThemeScreenBack := DARK_CYAN;
    ThemeScreenText := BLACK;
    ThemeWindowClose := LIGHT_RED;
    ThemeWindowMinimize := LIGHT_YELLOW;
    ThemeWindowMaximize := LIGHT_GREEN;
    ThemeWindowButtonDisable := LIGHT_GRAY;
    ! Initialize Terminal
    term_init();
    term_cls();
    husis_int_set(Int81Old, 0x81, @int81);
    progress(30, "Loading Fonts");
    if(load_font("/System/Default.fon", Font8x8, 0))
        video_set_font8x8(Font8x8);
    progress(50, "Loading Splash Screen");
    splash_screen();
    progress(70, "Loading Application Manager");
    husis_exec_com("/System/AppMan.com", "");
end