package platform

import "vendor:egl"
import "vendor:x11/xlib"
X11State :: struct {
    screen_number: i32,
    display : ^xlib.Display,
    root : xlib.Window,
    window: xlib.Window,
    screen_width: i32,
    screen_height: i32,

    delete_window: xlib.Atom,
}

EGLState :: struct {
    display: egl.Display,
    config: egl.Config,
    surface: egl.Surface,
    ctxt: egl.Context
}






