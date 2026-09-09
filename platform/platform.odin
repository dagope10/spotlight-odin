package platform
import "vendor:x11/xlib"

init :: proc(width, height: u32) -> Platform_State {
    x11: X11_State
    hints := Hints{
        flags = MWM_HINTS_DECORATIONS,
        decorations = 0
    }

    x11.display = xlib.OpenDisplay(nil)
    assert(x11.display != nil)


    x11.screen_number = xlib.DefaultScreen(x11.display)
    x11.root = xlib.RootWindow(x11.display, x11.screen_number)

    x11.screen_width = xlib.DisplayWidth(x11.display, x11.screen_number)
    x11.screen_height = xlib.DisplayHeight(x11.display, x11.screen_number)
    x := (x11.screen_width - i32(width)) / 2
    y := (x11.screen_height - i32(height)) / 2

    attrs: xlib.XSetWindowAttributes
    attrs.background_pixel = 0x000000;

    x11.window = xlib.CreateWindow(
        x11.display,
        x11.root,
        x,
        y,
        width,
        height,
        0,
        0, 
        .InputOutput,
        nil,
        {.CWBackPixel},
        &attrs,
    )
    xlib.SelectInput(x11.display, x11.window, {.Exposure, .KeyPress, .StructureNotify})
    

    x11.delete_window = xlib.InternAtom(x11.display, cstring("WM_DELETE_WINDOW"), true)

    floating: xlib.Atom = xlib.InternAtom(x11.display, "_NET_WM_WINDOW_TYPE_UTILITY" , true)
    property: xlib.Atom = xlib.InternAtom(x11.display, "_NET_WM_WINDOW_TYPE", false)
    motif_hints: xlib.Atom = xlib.InternAtom(x11.display, "_MOTIF_WM_HINTS", false)

    xlib.ChangeProperty(x11.display, x11.window, property, XA_ATOM, 32, xlib.PropModeReplace, &floating, 1)
    xlib.ChangeProperty(x11.display, x11.window, motif_hints, motif_hints, 32, xlib.PropModeReplace, &hints, 5)
    xlib.SetWMProtocols(x11.display, x11.window, &x11.delete_window, 1)

    return Platform_State{
        x11 = x11
    }
}



show_window :: proc(platform_state: ^Platform_State) {
    xlib.MapWindow(platform_state.x11.display, platform_state.x11.window);
    xlib.Flush(platform_state.x11.display);
}

next_event :: proc(p: ^Platform_State) -> Event {
    event : xlib.XEvent
    xlib.NextEvent(p.x11.display, &event)

    #partial switch event.type {
        case .KeyPress:
        text_buffer: [32]u8
        key: xlib.KeySym
        text_len := xlib.LookupString(&event.xkey, raw_data(text_buffer[:]), len(text_buffer), &key, nil)

        if key == .XK_Escape do return Event{kind = .Escape}
        if key == .XK_BackSpace do return Event{kind = .Backspace}

        if text_len > 0 {
            return Event{
                kind = .Text_Input,
                text = text_buffer,
                text_len = int(text_len),

                width = 0,
                height = 0,
            }
        }

        case .ConfigureNotify:
        return Event{
            kind = .Resize,
            width = u32(event.xconfigure.width),
            height = u32(event.xconfigure.height),
        }


        case .ClientMessage:
        if xlib.Atom(event.xclient.data.l[0]) == p.x11.delete_window do return Event{ kind = .Close }

        case .Expose:
        return Event{kind = .Redraw}
    }
    return Event{ kind = .None }

    
}

