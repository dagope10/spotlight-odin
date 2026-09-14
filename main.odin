package main

import "core:fmt"
import "core:os"
import vmem "core:mem/virtual"
import "platform"
import "vendor:x11/xlib"
import gl "vendor:OpenGL"
import egl "vendor:egl"
import "gfx"


main :: proc() {
    persistent_arena: vmem.Arena
    scratch_arena: vmem.Arena
    results: [6]Desktop_Entry

    if err := vmem.arena_init_static(&persistent_arena); err != nil {
        fmt.panicf("Error initiating arena: %v", err)
    }
    if err := vmem.arena_init_static(&scratch_arena); err != nil {
        fmt.panicf("Error initiating scratch arena: %v", err)
    }

    persistent_alloc := vmem.arena_allocator(&persistent_arena)
    scratch_alloc := vmem.arena_allocator(&scratch_arena)

    entries := search_files(&scratch_arena, persistent_alloc)


    // Initializers
    
    app := init_app_state()
    platform_state := platform.init(720, 420)
    egl_state := platform.egl_init(&platform_state)
    platform.show_window(&platform_state)

    gl.load_up_to(4, 6, egl.gl_set_proc_address)

    fmt.println("GL Version: ", string(gl.GetString(gl.VERSION)))
    fmt.println("GL Renderer: ", string(gl.GetString(gl.RENDERER)))

    font := gfx.init_font_atlas(&persistent_arena, Font_Bytes)

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
            filter_entries(entries, &app)
            draw_results(&renderer, &font, &app)
            platform.egl_present(&egl_state)
        }
        
    }
    fmt.println("Adios!")

}
