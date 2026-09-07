package platform
import "vendor:x11/xlib"

x11_init :: proc() -> X11State {
    x11: X11State
    x11.display = xlib.OpenDisplay(nil)
    assert(x11.display != nil)


    x11.screen_number = xlib.DefaultScreen(x11.display)
    x11.root = xlib.RootWindow(x11.display, x11.screen_number)

    x11.screen_width = xlib.DisplayWidth(x11.display, x11.screen_number)
    x11.screen_height = xlib.DisplayHeight(x11.display, x11.screen_number)

    attrs: xlib.XSetWindowAttributes
    attrs.event_mask = {
            .Exposure,
            .KeyPress,
            .StructureNotify,
    }
    attrs.background_pixel = 0x000000;

    window := xlib.CreateSimpleWindow(
        x11.display,
        x11.root,
        0,
        0,
        800,
        600,
        1,
        xlib.BlackPixel(x11.display, x11.screen_number),
        xlib.WhitePixel(x11.display, x11.screen_number)
    )

    x11.window = xlib.CreateWindow(
        x11.display,
        x11.root,
        0,
        0,
        u32(x11.screen_width),
        u32(x11.screen_height),
        0,
        0, // CopyFromParent para depth
            .InputOutput,
        nil, // CopyFromParent para visual
        {.CWBackPixel, .CWEventMask},
            &attrs,
    )
    

    x11.delete_window = xlib.InternAtom(x11.display, cstring("WM_DELETE_WINDOW"), true);
    xlib.SetWMProtocols(x11.display, x11.window, &x11.delete_window, 1)

    return x11
}

x11_release :: proc(x11: ^X11State) {
    xlib.DestroyWindow(x11.display, x11.window);
    xlib.CloseDisplay(x11.display);
}


x11_show_window :: proc(x11: ^X11State) {
    xlib.MapWindow(x11.display, x11.window);
    xlib.Flush(x11.display);
}
