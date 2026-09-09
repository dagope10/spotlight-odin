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
    arena: mem.Arena
    data := make([]u8, 4 * mem.Megabyte)
    mem.arena_init(&arena, data)


    // Initializers
    
    app := init_app_state()
    x11 := platform.init(720, 420)
    egl_state := platform.egl_init(&x11)

    platform.show_window(&x11)

    gl.load_up_to(4, 6, egl.gl_set_proc_address)

    fmt.println("GL Version: ", string(gl.GetString(gl.VERSION)))
    fmt.println("GL Renderer: ", string(gl.GetString(gl.RENDERER)))

    font := gfx.init_font_atlas(&arena, Font_Bytes)

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
            gfx.begin_frame(&renderer)
            draw_input(&renderer, &font)
            platform.egl_present(&egl_state)
        }
        
    }
    fmt.println("Adios!")

}


init_app_state :: proc() -> App_State {
    return App_State{
        running = true,
        width = 720,
        height = 420,
    }
}

process_event :: proc(app: ^App_State, x11: ^platform.X11_State, event: ^xlib.XEvent) ->Event_Flags {
    event_flags: Event_Flags = {}
    #partial switch event.type {
        case .KeyPress:
        key := xlib.LookupKeysym(&event.xkey, 0)
        if key == .XK_Escape do app.running = false 
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


draw_input :: proc(r: ^gfx.Renderer, font: ^gfx.Font) {
    box_x: f32 = 24.0
    box_y: f32 = 24.0
    box_width: f32 = 672.0
    box_height: f32 = 64.0

    gfx.draw_rect(
        r,
        u32(box_x), u32(box_y),
        u32(box_width), u32(box_height),
        gfx.COLOR_INPUT,
        14,
    )

    font_height := font.ascent - font.descent
    
    // Center baseline 
    baseline_y := box_y + (box_height - font_height) * 0.5 + font.ascent
    

    gfx.draw_text(r, "Hello world!", 50.0, baseline_y, gfx.WHITE, font)
}





