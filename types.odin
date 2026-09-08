package main

App_State :: struct {
    running: bool,
    width: u32,
    height: u32
}

Event_Flag :: enum {
    Redraw,
    Exit,
    Resize
}

Event_Flags :: distinct bit_set[Event_Flag]
Font_Bytes :: #load("assets/fonts/NotoSans-Regular.ttf", []u8)
