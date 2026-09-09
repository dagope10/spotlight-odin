package main

App_State :: struct {
    running: bool,
    width: u32,
    height: u32,
    buffer: [256]u8,
    buffer_len: int,
}

App_Event :: struct {
    kind: App_Event_Kind
}

App_Event_Kind :: enum {
    None,
    Text_Input,
    Backspace,
    Enter,
    Escape,
    Resize,
}



Event_Flag :: enum {
    Redraw,
    Exit,
    Resize
}

Event_Flags :: distinct bit_set[Event_Flag]
Font_Bytes :: #load("assets/fonts/NotoSans-Regular.ttf", []u8)
