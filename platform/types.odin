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

MWM_HINTS_DECORATIONS :: c.ulong(1 << 1)
XA_ATOM :: xlib.Atom(4)



