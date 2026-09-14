package main

import "platform"
import "core:fmt"
import "core:os"

init_app_state :: proc() -> App_State {
    return App_State{
        running = true,
        width = 720,
        height = 420,
        buffer_len = 0,
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

    case .Up:
        if app.selected_index > 0 {
            app.selected_index -= 1
            event_flags |= {.Redraw}
        }

    case .Down:
        if app.selected_index < app.results_len {
            app.selected_index += 1
            event_flags |= {.Redraw}
        }

    case .Enter:
    if app.results_len > 0 && app.selected_index < app.results_len {
        fmt.println("Selected")
        selected_app := app.results[app.selected_index].exec
        process, err := os.process_start(os.Process_Desc{
            command = []string{selected_app},
        })

        if err == nil do app.running = false
    }


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

