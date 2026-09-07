package main

import "core:fmt"
import "core:os"
import "core:mem"
import "platform"
import "vendor:x11/xlib"
import gl "vendor:OpenGL"
import egl "vendor:egl"
import "gfx"


main :: proc() {

    // if true do return
    // Initializers
    arena: mem.Arena
    data := make([]u8, 4 * mem.Megabyte)
    mem.arena_init(&arena, data)
    
    app := init_app_state()
    x11 := platform.init(800, 600)
    egl_state := platform.egl_init(&x11)

    platform.show_window(&x11)

    gl.load_up_to(4, 6, egl.gl_set_proc_address)

    fmt.println("GL Version: ", string(gl.GetString(gl.VERSION)))
    fmt.println("GL Renderer: ", string(gl.GetString(gl.RENDERER)))

    renderer := gfx.init()

    
    
    for app.running {
        event_flags: Event_Flags = {}
        event : xlib.XEvent
        xlib.NextEvent(x11.display, &event)
        event_flags |= process_event(&app, &x11, &event)

        for xlib.Pending(x11.display) > 0 {
            xlib.NextEvent(x11.display, &event)
            event_flags |= process_event(&app, &x11, &event)

        }

        if .Resize in event_flags {
            gfx.resize(&renderer, app.width, app.height)
        }
        if .Exit in event_flags {
            app.running = false
        }

        if .Redraw in event_flags {
            draw(&renderer, &app)
            platform.egl_present(&egl_state)
        } 
        
    }
    fmt.println("Adios!")

}


init_app_state :: proc() -> App_State {
    return App_State{
        running = true,
        width = 800,
        height = 600
    }
}

process_event :: proc(app: ^App_State, x11: ^platform.X11_State, event: ^xlib.XEvent) ->Event_Flags {
    event_flags: Event_Flags = {}
    #partial switch event.type {
        case .KeyPress:
        key := xlib.LookupKeysym(&event.xkey, 0)
        fmt.printfln("tecla: %v\n", key)

        case .ConfigureNotify:
        configure := event.xconfigure
        app.width = u32(configure.width)
        app.height = u32(configure.height)
        
        event_flags |= {.Resize}
        event_flags |= {.Redraw}

        case .ClientMessage:
        if xlib.Atom(event.xclient.data.l[0]) == x11.delete_window do app.running = false

        case .Expose:
        event_flags |= {.Redraw}         
    }
    return event_flags
}


draw :: proc(r: ^gfx.Renderer, app: ^App_State) {
    gfx.resize(r, app.width, app.height)
    gfx.renderer_clear()

    gfx.draw_rect(r, 100, 50, 600, 500, gfx.WHITE)
    gfx.draw_rect(r, 120, 70, 560, 120, gfx.WHITE)
    gfx.draw_rect(r, 120, 210, 560, 120, gfx.WHITE)
    gfx.draw_rect(r, 120, 350, 560, 120, gfx.WHITE)

}
