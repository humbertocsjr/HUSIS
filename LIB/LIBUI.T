! HUSIS Library
! Humberto Costa dos Santos Junior, 2022
! License: 0BSD or Public Domain

! ==========================================================================
! User Interface API
! ==========================================================================


const SCREEN_CONTROL = 0;

ui_new(control, uitype) t.int86ax(0x81, 300,control,uitype,0, 0,0);
ui_render(control) t.int86ax(0x81, 301,control,0,0, 0,0);
ui_destroy(control) t.int86ax(0x81, 302,control,0,0, 0,0);
ui_attach(control, parent) t.int86ax(0x81, 303,control,parent,0, 0,0);
ui_attach_window(control) t.int86ax(0x81, 304,control,0,0, 0,0);
ui_show(control) t.int86ax(0x81, 305,control,0,0, 0,0);
ui_hide(control) t.int86ax(0x81, 306,control,0,0, 0,0);

ui_new_uitype(uitype,ptr_render,ptr_focus,ptr_key,ptr_mouse)
    t.int86ax(0x81, 307,uitype,ptr_render,ptr_focus, ptr_key,ptr_mouse);

! ==========================================================================
! User Interface UIType API
! ==========================================================================


struct OBJ_CONTROL =  
    CONTROL_SEG,
    CONTROL_WINDOW_PTR,
    CONTROL_PARENT_PTR,
    CONTROL_TYPE_SEG,
    CONTROL_TYPE_PTR,
    CONTROL_TYPE_RENDER_PTR,
    CONTROL_TYPE_MOUSE_PTR,
    CONTROL_TYPE_KEYBOARD_PTR,
    CONTROL_TYPE_FOCUS_PTR,
    CONTROL_FOCUS,
    CONTROL_SHOW,
    CONTROL_CASCADE_HIDE,
    CONTROL_NEXT_PTR,
    CONTROL_CHILD_PTR,
    CONTROL_CONTENT_PTR,
    CONTROL_CONTENT_AUX_PTR,
    CONTROL_VALUE_1,
    CONTROL_VALUE_2,
    CONTROL_VALUE_3,
    CONTROL_VALUE_4,
    CONTROL_ACTION_PTR,
    CONTROL_ACTION_AUX_PTR,
    CONTROL_ACTION_ENTER_PTR,
    CONTROL_ACTION_EXIT_PTR,
    CONTROL_X,
    CONTROL_Y,
    CONTROL_WIDTH,
    CONTROL_HEIGHT,
    CONTROL_MARGIN_X,
    CONTROL_MARGIN_Y,
    CONTROL_MARGIN_WIDTH,
    CONTROL_MARGIN_HEIGHT,
    CONTROL_CALC_X,
    CONTROL_CALC_Y,
    CONTROL_CALC_WIDTH,
    CONTROL_CALC_HEIGHT;
    
struct OBJ_UITYPE = 
    UITYPE_SEG,
    UITYPE_RENDER_PTR,
    UITYPE_FOCUS_PTR,
    UITYPE_KEYBOARD_PTR,
    UITYPE_MOUSE_PTR;

uitype_window(uitype) t.int86ax(0x81, 400,uitype,0,0, 0,0);
uitype_label(uitype) t.int86ax(0x81, 401,uitype,0,0, 0,0);
