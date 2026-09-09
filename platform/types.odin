package platform

import "vendor:egl"
import "core:c"
import "vendor:x11/xlib"
X11_State :: struct {
    screen_number: i32,
    display : ^xlib.Display,
    root : xlib.Window,
    window: xlib.Window,
    screen_width: i32,
    screen_height: i32,

    delete_window: xlib.Atom,
}

EGL_State :: struct {
    display: egl.Display,
    config: egl.Config,
    surface: egl.Surface,
    ctxt: egl.Context
}


Hints :: struct {
    flags: c.ulong,
    functions: c.ulong,
    decorations: c.ulong,
    input_mode: c.long,
    status: c.ulong,
}

Platform_State :: struct {
    x11: X11_State
}

Event_Kind :: enum {
    None,
    Text_Input,
    Backspace,
    Enter,
    Escape,
    Resize,
    Redraw,
    Close,
}

Event :: struct {
    kind: Event_Kind,
    text: [32]u8,
    text_len: int,

    width: u32,
    height: u32,
}

MWM_HINTS_DECORATIONS :: c.ulong(1 << 1)
XA_ATOM :: xlib.Atom(4)



