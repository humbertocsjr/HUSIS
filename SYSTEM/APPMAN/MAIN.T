! Application Manager
! Humberto Costa dos Santos Junior, 2022
! 3-Clause BSD license
! Cooperative multitask manager

var WindowType[OBJ_UITYPE], LabelType[OBJ_UITYPE];

var MainWindow[OBJ_CONTROL],
    CounterLabel[OBJ_CONTROL];

initialize_types() do
    ! Import control types
    uitype_window(WindowType);
    uitype_label(LabelType);
end


do
    var i, counter_txt::30, number::11;

    ! Import and initialize types
    initialize_types();

    ! Renderize Screen
    ui_render(SCREEN_CONTROL);

    ! Create main window
    ui_new(MainWindow, WindowType);
    MainWindow[CONTROL_X] := 5;
    MainWindow[CONTROL_Y] := 5;
    MainWindow[CONTROL_WIDTH] := 20;
    MainWindow[CONTROL_HEIGHT] := 10;
    MainWindow[CONTROL_CONTENT_PTR] := "Window Test"; ! Content = Title

    ! Attach main window to screen
    ui_attach_window(MainWindow);

    ! Create Label
    ui_new(CounterLabel, LabelType);
    CounterLabel[CONTROL_X] := 2;
    CounterLabel[CONTROL_Y] := 4;
    CounterLabel[CONTROL_WIDTH] := 20;
    CounterLabel[CONTROL_HEIGHT] := 1;
    str_copy(counter_txt, "Test");
    CounterLabel[CONTROL_CONTENT_PTR] := counter_txt; ! Content = Text

    ! Attach label to window
    ui_attach(CounterLabel, MainWindow);

    ! Show Main Window
    ui_show(MainWindow);
    while(TRUE) do
        ! Update Counter
        str_copy(counter_txt, "Counter: ");
        str_from_num_fixed(number, 6, i);
        str_concat(counter_txt, number);
        ! Render counter
        ui_render(CounterLabel);
        i := i + 1;
    end
end