package main

import "platform"


init_app_state :: proc() -> App_State {
    return App_State{
        running = true,
        width = 720,
        height = 420,
        buffer_len = 0
    }
}


process_event :: proc(app: ^App_State, p: ^platform.Platform_State, event: platform.Event) ->Event_Flags {
    event_flags: Event_Flags = {}

    switch event.kind {
    case .Text_Input:
        if app.buffer_len + event.text_len <= len(app.buffer) {
            text := event.text
            copy(app.buffer[app.buffer_len:], text[:event.text_len])
            app.buffer_len += event.text_len
            event_flags |= {.Redraw}
        } 
    

    case .Backspace:
    if app.buffer_len > 0 {
        app.buffer_len -= 1
        app.buffer[app.buffer_len] = 0
        event_flags |= {.Redraw}
    }

    case .Enter:


    case .Escape, .Close:
    app.running = false

    case .Resize:
        event_flags |= {.Redraw, .Resize}

    case .None:

    case .Redraw:
        event_flags |= {.Redraw}
    

    }
    return event_flags
}

