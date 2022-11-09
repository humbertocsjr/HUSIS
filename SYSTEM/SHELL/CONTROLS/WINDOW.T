! ==========================================================================
! Window UIType
! ==========================================================================

window_render(control) far do
    var tmp::10, i, color_window;
    term_calc_pos(control[CONTROL_CALC_X], control[CONTROL_CALC_Y]);

    term_color_fore(t.fargetw(t.local(), @ThemeWindowTitleText));
    term_color_back(t.fargetw(t.local(), @ThemeWindowTitleBack));

    term_write_char('\e');
    term_write_char('r');
    str_from_num_fixed(tmp, 2, control[CONTROL_CALC_WIDTH]);
    term_writes(tmp);
    term_write_char(FONT_HORIZONTAL_LINES);

    term_calc_pos(control[CONTROL_CALC_X] + 4, control[CONTROL_CALC_Y]);
    if(control[CONTROL_CONTENT_PTR] \= 0)
        term_write(control[CONTROL_CONTENT_PTR], (str_len(control[CONTROL_CONTENT_PTR]) + 5) >= control[CONTROL_WIDTH] ->  (control[CONTROL_WIDTH] - 5) : str_len(control[CONTROL_CONTENT_PTR]));

    term_calc_pos(control[CONTROL_CALC_X], control[CONTROL_CALC_Y]);
    term_color_fore(t.fargetw(t.local(), @ThemeWindowClose));
    term_write_char_force(FONT_CLOSE);
    ie(control[CONTROL_VALUE_1])
        term_color_fore(t.fargetw(t.local(), @ThemeWindowMinimize));
    else
        term_color_fore(t.fargetw(t.local(), @ThemeWindowButtonDisable));
    term_write_char_force(FONT_MINIMIZE);
    ie(control[CONTROL_VALUE_1])
        term_color_fore(t.fargetw(t.local(), @ThemeWindowMaximize));
    else
        term_color_fore(t.fargetw(t.local(), @ThemeWindowButtonDisable));
    term_write_char_force(FONT_MAXIMIZE);

    term_calc_pos(control[CONTROL_CALC_X], control[CONTROL_CALC_Y]+1);

    term_color_fore(t.fargetw(t.local(), @ThemeWindowBorder));
    term_color_back(t.fargetw(t.local(), @ThemeControl));

    term_write_char(FONT_FRAME_UP_LEFT);
    term_write_char('\e');
    term_write_char('r');
    str_from_num_fixed(tmp, 2, control[CONTROL_CALC_WIDTH]-2);
    term_writes(tmp);
    term_write_char(FONT_FRAME_UP);
    term_write_char(FONT_FRAME_UP_RIGHT);
    str_from_num_fixed(tmp, 2, control[CONTROL_CALC_WIDTH]-2);
    for(i = 2, control[CONTROL_CALC_HEIGHT]-1) do
        term_calc_pos(control[CONTROL_CALC_X], control[CONTROL_CALC_Y]+i);
        term_write_char(FONT_FRAME_LEFT);
        term_write_char('\e');
        term_write_char('r');
        term_writes(tmp);
        term_write_char(' ');
        term_write_char(FONT_FRAME_RIGHT);
    end
    term_calc_pos(control[CONTROL_CALC_X], control[CONTROL_CALC_Y]+control[CONTROL_CALC_HEIGHT]-1);
    term_write_char(FONT_FRAME_DOWN_LEFT);
    term_write_char('\e');
    term_write_char('r');
    str_from_num_fixed(tmp, 2, control[CONTROL_CALC_WIDTH]-2);
    term_writes(tmp);
    term_write_char(FONT_FRAME_DOWN);
    term_write_char_force(FONT_FRAME_DOWN_RIGHT);

    control[CONTROL_MARGIN_X] := 1;
    control[CONTROL_MARGIN_Y] := 2;
    control[CONTROL_MARGIN_WIDTH] := 1;
    control[CONTROL_MARGIN_HEIGHT] := 1;
    interface_render_all(control);
end

window_focus(control, focus) far do
end

window_keyboard(control, press, ascii, scancode) far do
end

window_mouse(control, primary_click, secondary_click, scroll) far do
end

window_new(uitype) do
    interface_new_uitype
    (
        uitype, 
        t.local(), 
        @window_render,
        @window_focus,
        @window_keyboard,
        @window_mouse
    );
end