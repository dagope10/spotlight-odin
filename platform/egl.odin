package platform

import "vendor:egl"
import "core:fmt"
egl_init :: proc(x11: ^X11State) -> EGLState {

    egl_state: EGLState
    egl_state.display = egl.GetPlatformDisplay(egl.Platform.X11_KHR, x11.display, nil)
    assert(egl_state.display != egl.NO_DISPLAY)
    assert(egl.Initialize(egl_state.display, nil, nil) != egl.FALSE)

    attrib_list := []i32{
        egl.SURFACE_TYPE, egl.WINDOW_BIT,
        egl.RED_SIZE, 8,
        egl.GREEN_SIZE, 8,
        egl.BLUE_SIZE, 8,
        egl.RENDERABLE_TYPE, egl.OPENGL_BIT,
        egl.NONE
    }
    num_config: i32
    assert(egl.ChooseConfig(egl_state.display, &attrib_list[0], &egl_state.config,1, &num_config) != egl.FALSE)
    assert(egl.BindAPI(egl.OPENGL_API) != false)
    egl_state.surface = egl.CreateWindowSurface(egl_state.display, egl_state.config, egl.NativeWindowType(uintptr(x11.window)), nil)
    assert(egl_state.surface != egl.NO_SURFACE)
    fmt.printfln("Surface created")
    attrs := []i32{
        egl.CONTEXT_MAJOR_VERSION, 4,
        egl.CONTEXT_MINOR_VERSION, 6,
        egl.NONE
    }
    egl_state.ctxt = egl.CreateContext(egl_state.display, egl_state.config, egl.NO_CONTEXT, &attrs[0])
    assert(egl_state.ctxt != egl.NO_CONTEXT)
    assert(egl.MakeCurrent(egl_state.display, egl_state.surface, egl_state.surface, egl_state.ctxt)!= false)
    return egl_state
}

egl_release :: proc(egl_state: ^EGLState) {
    egl.MakeCurrent(egl_state.display, egl.NO_SURFACE, egl.NO_SURFACE, egl.NO_CONTEXT);
    egl.DestroySurface(egl_state.display, egl_state.surface);
    egl.DestroyContext(egl_state.display, egl_state.ctxt);
    egl.Terminate(egl_state.display);
}

