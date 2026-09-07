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
    arena : mem.Arena
    data := make([]u8, 4 * mem.Megabyte)
    mem.arena_init(&arena, data)
    fmt.println("Arena initialized")
    when false {
        running := true
        x11 := platform.x11_init()
        defer xlib.CloseDisplay(x11.display)
        egl_state := platform.egl_init(&x11)

        xlib.MapWindow(x11.display, x11.window)
        xlib.Flush(x11.display)
        xlib.SelectInput(x11.display, x11.window, xlib.EventMask{.KeyPress, .StructureNotify})
        gl.load_up_to(4, 6, egl.gl_set_proc_address)

        fmt.println("GL Version: ", string(gl.GetString(gl.VERSION)))
        fmt.println("GL Renderer: ", string(gl.GetString(gl.RENDERER)))

        gfx.init(800, 600)
        gfx.resize(800,600)
        
        
        for running {
            event : xlib.XEvent
            xlib.NextEvent(x11.display, &event)
            #partial switch event.type {
                case .KeyPress:
                key := xlib.LookupKeysym(&event.xkey, 0)
                fmt.printfln("tecla: %v\n", key)

                case .ConfigureNotify:
                configure := event.xconfigure
                gfx.resize(configure.width, configure.height)
                gfx.renderer_clear()
                // Main box
                gfx.draw_rect(100, 50, 600, 500, gfx.RED)
                gfx.draw_rect(120, 70, 560, 120, gfx.BLACK)
                gfx.draw_rect(120, 210, 560, 120, gfx.BLACK)
                gfx.draw_rect(120, 350, 560, 120, gfx.WHITE)
                egl.SwapBuffers(egl_state.display, egl_state.surface)

                case .ClientMessage:
                if xlib.Atom(event.xclient.data.l[0]) == x11.delete_window do running = false
                
            }
        }
        fmt.println("Adios!")
        platform.egl_release(&egl_state)
        platform.x11_release(&x11)
    }
}
