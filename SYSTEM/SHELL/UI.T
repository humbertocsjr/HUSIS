! ==========================================================================
! User Interface
! ==========================================================================

var ThemeControl, ThemeText, ThemeWindowBorder, ThemeWindowTitleBack,
    ThemeWindowTitleText, ThemeScreenBack, ThemeScreenText, 
    ThemeWindowClose, ThemeWindowMaximize, ThemeWindowMinimize,
    ThemeWindowButtonDisable;

const WINDOW_CAPACITY = 32;

var WindowList[WINDOW_CAPACITY];

interface_new_control(control, uitype) do
    control[CONTROL_SEG] := t.stack();
    control[CONTROL_PARENT_PTR] := -1;
    control[CONTROL_WINDOW_PTR] := control;
    control[CONTROL_TYPE_SEG] := uitype[UITYPE_SEG];
    control[CONTROL_TYPE_PTR] := uitype;
    control[CONTROL_TYPE_RENDER_PTR] := uitype[UITYPE_RENDER_PTR];
    control[CONTROL_TYPE_MOUSE_PTR] := uitype[UITYPE_MOUSE_PTR];
    control[CONTROL_TYPE_KEYBOARD_PTR] := uitype[UITYPE_KEYBOARD_PTR];
    control[CONTROL_TYPE_FOCUS_PTR] := uitype[UITYPE_FOCUS_PTR];
    control[CONTROL_SHOW] := FALSE;
    control[CONTROL_CASCADE_HIDE] := FALSE;
    control[CONTROL_NEXT_PTR] := 0;
    control[CONTROL_CHILD_PTR] := 0;
    control[CONTROL_CONTENT_PTR] := 0;
    control[CONTROL_CONTENT_AUX_PTR] := 0;
    control[CONTROL_VALUE_1] := 0;
    control[CONTROL_VALUE_2] := 0;
    control[CONTROL_VALUE_3] := 0;
    control[CONTROL_VALUE_4] := 0;
    control[CONTROL_ACTION_PTR] := 0;
    control[CONTROL_ACTION_AUX_PTR] := 0;
    control[CONTROL_ACTION_ENTER_PTR] := 0;
    control[CONTROL_ACTION_EXIT_PTR] := 0;
    control[CONTROL_X] := 0;
    control[CONTROL_Y] := 0;
    control[CONTROL_WIDTH] := 0;
    control[CONTROL_HEIGHT] := 0;
    control[CONTROL_MARGIN_X] := 0;
    control[CONTROL_MARGIN_Y] := 0;
    control[CONTROL_MARGIN_WIDTH] := 0;
    control[CONTROL_MARGIN_HEIGHT] := 0;
    control[CONTROL_CALC_X] := 0;
    control[CONTROL_CALC_Y] := 0;
    control[CONTROL_CALC_WIDTH] := 0;
    control[CONTROL_CALC_HEIGHT] := 0;
end

interface_render(control) do
    var ptr::T3X.PTRSIZE, i, win_ptr;
    if(control = -1) return;
    if(control[CONTROL_PARENT_PTR] = -1) return;
    if(control = SCREEN_CONTROL) do
        term_color_fore(t.fargetw(t.local(), @ThemeScreenText));
        term_color_back(t.fargetw(t.local(), @ThemeScreenBack));
        term_cls();
        win_ptr := t.fargetw(t.local(), @WindowList);
        for(i = 0, WINDOW_CAPACITY) do
            if(t.fargetw(t.local(), win_ptr + (i << 1)) \= 0) do
                if
                (
                    t.fargetw(t.local(), 
                        t.fargetw(t.local(), win_ptr + (i << 1)) + 
                        CONTROL_SHOW
                    )
                )
                interface_render(t.fargetw(t.local(), win_ptr + (i << 1)));
            end
        end
        return;
    end
    if(control[CONTROL_WINDOW_PTR][CONTROL_FOCUS]) return;
    if(control[CONTROL_TYPE_SEG] = 0) return;
    if(control[CONTROL_TYPE_RENDER_PTR] = 0) return;
    ie(control[CONTROL_PARENT_PTR] = SCREEN_CONTROL) do
        control[CONTROL_CALC_X] := control[CONTROL_X];
        control[CONTROL_CALC_Y] := control[CONTROL_Y];
        control[CONTROL_CALC_WIDTH] := control[CONTROL_WIDTH];
        control[CONTROL_CALC_HEIGHT] := control[CONTROL_HEIGHT];
    end
    else do 
        if(control[CONTROL_PARENT_PTR][CONTROL_SHOW] = FALSE) return;
        if(control[CONTROL_PARENT_PTR][CONTROL_CASCADE_HIDE]) return;
    end
    t.setptr(ptr, control[CONTROL_TYPE_SEG], control[CONTROL_TYPE_RENDER_PTR]);
    callfar ptr(control);
end

interface_calc_child(control) do
    var parent;
    if(control[CONTROL_PARENT_PTR] = SCREEN_CONTROL) do
        control[CONTROL_CALC_X] := control[CONTROL_X];
        control[CONTROL_CALC_Y] := control[CONTROL_Y];
        control[CONTROL_CALC_WIDTH] := control[CONTROL_WIDTH];
        control[CONTROL_CALC_HEIGHT] := control[CONTROL_HEIGHT];
        return TRUE;
    end
    if(control[CONTROL_SHOW] = FALSE) return FALSE;
    parent := control[CONTROL_PARENT_PTR];
    control[CONTROL_CALC_X] := control[CONTROL_X] + parent[CONTROL_CALC_X] + parent[CONTROL_MARGIN_X];
    control[CONTROL_CALC_Y] := control[CONTROL_Y] + parent[CONTROL_CALC_Y] + parent[CONTROL_MARGIN_X];
    control[CONTROL_CALC_WIDTH] := control[CONTROL_WIDTH];
    control[CONTROL_CALC_HEIGHT] := control[CONTROL_HEIGHT];
    if((control[CONTROL_X] + parent[CONTROL_MARGIN_X] + control[CONTROL_CALC_WIDTH]) >= (parent[CONTROL_CALC_WIDTH] - parent[CONTROL_MARGIN_WIDTH])) do
        control[CONTROL_CALC_WIDTH] := parent[CONTROL_CALC_WIDTH] - parent[CONTROL_MARGIN_WIDTH] - parent[CONTROL_MARGIN_X] - control[CONTROL_X];
    end
    if((control[CONTROL_Y] + control[CONTROL_CALC_HEIGHT]) >= (parent[CONTROL_CALC_HEIGHT] - parent[CONTROL_MARGIN_HEIGHT])) do
        control[CONTROL_CALC_HEIGHT] := parent[CONTROL_CALC_HEIGHT] - parent[CONTROL_MARGIN_HEIGHT] - parent[CONTROL_MARGIN_Y] - control[CONTROL_Y];
    end
    return TRUE;
end

interface_calc_all(parent) do
    var child;
    child := parent[CONTROL_CHILD_PTR];
    while(child \= 0) do
        interface_calc_child(child);
        child := child[CONTROL_NEXT_PTR];
    end
end

interface_render_child(control) do
    if(interface_calc_child(control))
        interface_render(control);
end

interface_render_all(parent) do
    var child;
    child := parent[CONTROL_CHILD_PTR];
    while(child \= 0) do
        interface_render_child(child);
        child := child[CONTROL_NEXT_PTR];
    end
end

interface_destroy(control) do
    var current, i, win_ptr;
    control[CONTROL_SHOW] := FALSE;
    interface_render(control[CONTROL_PARENT_PTR]);
    ie(control[CONTROL_PARENT_PTR] = SCREEN_CONTROL) do
        win_ptr := t.fargetw(t.local(), @WindowList);
        for(i = 0, WINDOW_CAPACITY) do
            if(t.fargetw(t.local(), win_ptr + (i << 1)) = control) 
                t.farsetw(t.local(), win_ptr + (i << 1), 0);
        end
    end
    else do
        if(control[CONTROL_PARENT_PTR][CONTROL_CHILD_PTR] = control) do
            control[CONTROL_PARENT_PTR][CONTROL_CHILD_PTR] := control[CONTROL_NEXT_PTR];
            return;
        end
        current := control[CONTROL_PARENT_PTR][CONTROL_CHILD_PTR];
        while(current[CONTROL_NEXT_PTR] \= 0) do
            if(current[CONTROL_NEXT_PTR] = control) do
                current[CONTROL_NEXT_PTR] := control[CONTROL_NEXT_PTR];
                leave;
            end
            current := current[CONTROL_NEXT_PTR];
        end
    end
end

interface_attach(control, parent) do
    var current;
    control[CONTROL_SHOW] := TRUE;
    control[CONTROL_PARENT_PTR] := parent;
    ie(parent[CONTROL_CHILD_PTR] = 0) do
        parent[CONTROL_CHILD_PTR] := control;
        control[CONTROL_WINDOW_PTR] := parent[CONTROL_WINDOW_PTR];
    end
    else do
        current := parent[CONTROL_CHILD_PTR];
        while(current[CONTROL_NEXT_PTR] \= 0) do
            current := current[CONTROL_NEXT_PTR];
        end
        current[CONTROL_NEXT_PTR] := control;
        control[CONTROL_WINDOW_PTR] := parent[CONTROL_WINDOW_PTR];
    end
end

interface_attach_window(control) do
    var i, win_ptr, window;
    win_ptr := t.fargetw(t.local(), @WindowList);
    control[CONTROL_PARENT_PTR] := SCREEN_CONTROL;
    control[CONTROL_WINDOW_PTR] := control;
    for(i = 0, WINDOW_CAPACITY) do
        window := t.fargetw(t.local(), win_ptr + (i << 1));
        window[CONTROL_FOCUS] := FALSE;
        if(t.fargetw(t.local(), win_ptr + (i << 1)) = 0) do
            t.farsetw(t.local(), win_ptr + (i << 1), control);
            window[CONTROL_FOCUS] := TRUE;
        end
    end
end

interface_cascade(control, show) do
    var child;
    control[CONTROL_CASCADE_HIDE] := \show;
    child := control[CONTROL_CHILD_PTR];
    while(child \= 0) do
        child[CONTROL_CASCADE_HIDE] := \show;
        if(child[CONTROL_CHILD_PTR] \= 0)
            interface_cascade(control, show);
        child := child[CONTROL_NEXT_PTR];
    end
end

interface_show(control) do
    if(control \= SCREEN_CONTROL) do
        control[CONTROL_SHOW] := TRUE;
        interface_cascade(control, TRUE);
    end
    interface_render(control);
end

interface_hide(control) do
    if(control \= SCREEN_CONTROL) do
        control[CONTROL_SHOW] := FALSE;
        interface_cascade(control, FALSE);
    end
    interface_render(control[CONTROL_PARENT_PTR]);
end

interface_new_uitype(uitype, seg, ptr_render, ptr_focus, ptr_key, ptr_mouse) do
    uitype[UITYPE_SEG] := seg;
    uitype[UITYPE_RENDER_PTR] := ptr_render;
    uitype[UITYPE_FOCUS_PTR] := ptr_focus;
    uitype[UITYPE_KEYBOARD_PTR] := ptr_key;
    uitype[UITYPE_MOUSE_PTR] := ptr_mouse;
end