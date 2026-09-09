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
    platform_state := platform.init(720, 420)
    egl_state := platform.egl_init(&platform_state)
    platform.show_window(&platform_state)

    gl.load_up_to(4, 6, egl.gl_set_proc_address)

    fmt.println("GL Version: ", string(gl.GetString(gl.VERSION)))
    fmt.println("GL Renderer: ", string(gl.GetString(gl.RENDERER)))

    font := gfx.init_font_atlas(&arena, Font_Bytes)

    renderer := gfx.init()

    
    
    for app.running {
        event_flags: Event_Flags = {}
        event := platform.next_event(&platform_state)
        event_flags |= process_event(&app, &platform_state, event)

        for xlib.Pending(platform_state.x11.display) > 0 {
            event = platform.next_event(&platform_state)
            event_flags |= process_event(&app, &platform_state, event)
        }

        if .Resize in event_flags {
            gfx.resize(&renderer, app.width, app.height)
        }
        if .Exit in event_flags {
            app.running = false
        }

        if .Redraw in event_flags {
            gfx.begin_frame(&renderer)
            draw_input(&renderer, &font, app.buffer[:app.buffer_len])
            platform.egl_present(&egl_state)
        }
        
    }
    fmt.println("Adios!")

}







