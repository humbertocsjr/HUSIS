! ==========================================================================
! Label UIType
! ==========================================================================

label_render(control) far do
    var tmp::20;
    term_calc_pos(control[CONTROL_CALC_X], control[CONTROL_CALC_Y]);
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
end

label_focus(control, focus) far do
end

label_keyboard(control, press, ascii, scancode) far do
end

label_mouse(control, primary_click, secondary_click, scroll) far do
end

label_new(uitype) do
    interface_new_uitype
    (
        uitype, 
        t.local(), 
        @label_render,
        @label_focus,
        @label_keyboard,
        @label_mouse
    );
end
