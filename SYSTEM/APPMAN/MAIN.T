! Application Manager
! Humberto Costa dos Santos Junior, 2022
! 3-Clause BSD license
! Cooperative multitask manager

var WindowType[OBJ_UITYPE], 
    LabelType[OBJ_UITYPE],
    TextBoxType[OBJ_UITYPE];

var MainWindow[OBJ_CONTROL],
    CounterLabel[OBJ_CONTROL],
    CounterTxt::30,
    VersionLabel[OBJ_CONTROL],
    VersionTxt::30,
    TestTextBox[OBJ_CONTROL],
    TestTxt::30;


initialize_types() do
    ! Import control types
    uitype_window(WindowType);
    uitype_label(LabelType);
    uitype_textbox(TextBoxType);
end


do
    var i, number::11;

    ! Import and initialize types
    initialize_types();

    ! Renderize Screen
    ui_render(SCREEN_CONTROL);

    ! Create main window
    ui_new(MainWindow, WindowType);
    MainWindow[CONTROL_X] := 5;
    MainWindow[CONTROL_Y] := 5;
    MainWindow[CONTROL_WIDTH] := 35;
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
    str_copy(CounterTxt, "Test");
    CounterLabel[CONTROL_CONTENT_PTR] := CounterTxt; ! Content = Text

    ! Attach label to window
    ui_attach(CounterLabel, MainWindow);

    ! Create Label
    ui_new(VersionLabel, LabelType);
    VersionLabel[CONTROL_X] := 2;
    VersionLabel[CONTROL_Y] := 3;
    VersionLabel[CONTROL_WIDTH] := 20;
    VersionLabel[CONTROL_HEIGHT] := 1;
    str_copy(VersionTxt, "HUSIS v");
    str_from_num_fixed(number, 4, husis_get_version());
    str_concat(VersionTxt, number);
    str_concat(VersionTxt, ".");
    str_from_num_fixed(number, 2, husis_get_sub_version());
    str_concat(VersionTxt, number);
    str_concat(VersionTxt, " R");
    str_from_num_fixed(number, 2, husis_get_revision());
    str_concat(VersionTxt, number);
    VersionLabel[CONTROL_CONTENT_PTR] := VersionTxt; ! Content = Text

    ! Attach label to window
    ui_attach(VersionLabel, MainWindow);

    ! Create textbox
    ui_new(TestTextBox, TextBoxType);
    TestTextBox[CONTROL_X] := 2;
    TestTextBox[CONTROL_Y] := 6;
    TestTextBox[CONTROL_WIDTH] := 20;
    TestTextBox[CONTROL_HEIGHT] := 1;
    str_copy(TestTxt, "ABX");
    TestTextBox[CONTROL_CONTENT_PTR] := TestTxt; ! Content = Text
    TestTextBox[TEXTBOX_LEN] := 30;

    ! Attach textbox to window
    ui_attach(TestTextBox, MainWindow);

    ! Show Main Window
    ui_show(MainWindow);
    while(TRUE) do
        ! Update Counter
        str_copy(CounterTxt, "Counter: ");
        str_from_num_fixed(number, 6, i);
        str_concat(CounterTxt, number);
        ! Render counter
        ui_render(CounterLabel);
        i := i + 1;
    end
end