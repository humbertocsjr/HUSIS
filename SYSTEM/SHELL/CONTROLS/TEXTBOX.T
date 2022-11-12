! ==========================================================================
! TextBox UIType
! ==========================================================================

textbox_render(control) far do
    var tmp::20;
    term_calc_pos(control[CONTROL_CALC_X], control[CONTROL_CALC_Y]);
    term_color_fore(t.fargetw(t.local(), @ThemeEditorText));
    term_color_back(t.fargetw(t.local(), @ThemeEditorBack));
    ie(control[CONTROL_CONTENT_PTR] = 0) do
        term_write_char('\e');
        term_write_char('r');
        str_from_num_fixed(tmp, 2, control[CONTROL_CALC_WIDTH]);
        term_writes(tmp);
        term_write_char(' ');
    end
    else do
        ie(str_len(control[CONTROL_CONTENT_PTR]) < control[CONTROL_CALC_WIDTH]) do
            term_writes(control[CONTROL_CONTENT_PTR]);
            term_write_char('\e');
            term_write_char('r');
            str_from_num_fixed(tmp, 2, control[CONTROL_CALC_WIDTH] - str_len(control[CONTROL_CONTENT_PTR]));
            term_writes(tmp);
            term_write_char(' ');
        end
        else do
            term_write(control[CONTROL_CONTENT_PTR], control[CONTROL_CALC_WIDTH]);
        end
    end
    if(control[TEXTBOX_CURSOR_X] >= control[CONTROL_CALC_WIDTH]) control[TEXTBOX_CURSOR_X] := control[CONTROL_CALC_WIDTH];
    term_change_color(control[CONTROL_CALC_X] + control[TEXTBOX_CURSOR_X], control[CONTROL_CALC_Y], t.fargetw(t.local(), @ThemeEditorText), t.fargetw(t.local(), @ThemeEditorBack));
end

textbox_focus(control, focus) far do
end

textbox_keyboard(control, press, ascii, scancode) far do
end

textbox_mouse(control, primary_click, secondary_click, scroll) far do
end

textbox_new(uitype) do
    interface_new_uitype
    (
        uitype, 
        t.local(), 
        @textbox_render,
        @textbox_focus,
        @textbox_keyboard,
        @textbox_mouse
    );
end
