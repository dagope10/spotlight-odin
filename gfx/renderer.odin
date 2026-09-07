package gfx


import gl "vendor:OpenGL"
import "core:fmt"
import "core:os"



// Indexes for EBO
indexes := [6]u32{
    0,1,2,
    2,1,3 
}
// Types
VAO :: u32
VBO :: u32
ShaderProgram :: u32
EBO :: u32

// Global variables
global_shader : ShaderProgram
global_vao : VAO
global_uniform_location : i32

global_vbo : VBO
global_ebo : EBO

framebuffer_width : i32
framebuffer_height : i32

init :: proc(w, h : i32) {
    // We define a callback function for when it is resized
    gl.GenVertexArrays(1, &global_vao)
    gl.BindVertexArray(global_vao)

    framebuffer_width, framebuffer_height = w, h
    


    // Gen Buffers
    gl.GenBuffers(1, &global_vbo)
    gl.GenBuffers(1, &global_ebo)

    // Bind buffers
    gl.BindBuffer(gl.ARRAY_BUFFER, global_vbo)
    gl.BufferData(gl.ARRAY_BUFFER, 8 * size_of(f32), nil, gl.DYNAMIC_DRAW)

    gl.BindBuffer(gl.ELEMENT_ARRAY_BUFFER, global_ebo)
    gl.BufferData(gl.ELEMENT_ARRAY_BUFFER, size_of(indexes), &indexes, gl.STATIC_DRAW)
    // Define a vertex with layout 0, two dots , type Float, no normalization and from position 0 in the VBO
    gl.VertexAttribPointer(0, 2, gl.FLOAT, gl.FALSE, 2 * size_of(f32), 0)

    // Enable both defined vertex
    gl.EnableVertexAttribArray(0)

    program_ok : bool
    vertex_shader := string(#load("shaders/vertex.glsl"))
    color_shader := string(#load("shaders/fragments.glsl"))

    // Load .glsl
    global_shader, program_ok = gl.load_shaders_source(vertex_shader, color_shader)
    if !program_ok {
        fmt.println("Error: Failed to load and compile shaders"); os.exit(1)
    }

    global_uniform_location = gl.GetUniformLocation(global_shader, "uColor")
    gl.UseProgram(global_shader)

}

draw_rect :: proc(x, y, width, height : u32, color : Color) {

    vertices := calculate_vertices(x, y, width, height)
    gl.BindBuffer(gl.ARRAY_BUFFER, global_vbo)
    gl.BufferSubData(gl.ARRAY_BUFFER, 0, size_of(vertices), &vertices)
    
    gl.BindVertexArray(global_vao)
    defer gl.BindVertexArray(0)
    gl.Uniform4f(global_uniform_location, color.r, color.g, color.b, color.a)
    gl.DrawElements(gl.TRIANGLES, 6, gl.UNSIGNED_INT, nil)
}


renderer_clear :: proc() {
    gl.Clear(gl.COLOR_BUFFER_BIT)
}

resize :: proc(w, h : i32) {
    framebuffer_width = w
    framebuffer_height = h
    gl.Viewport(0, 0, w, h)
}


@(private)
calculate_vertices :: proc(x, y, width, height : u32) -> [8]f32 {
    left, right, top, bottom := x, x + width, y, y + height
    left_gl := (f32(left) / f32(framebuffer_width)) * 2 - 1
    right_gl := (f32(right) / f32(framebuffer_width)) * 2 - 1
    top_gl := 1 - (f32(top) / f32(framebuffer_height)) * 2
    bottom_gl := 1 - (f32(bottom) / f32(framebuffer_height)) * 2

    return [8]f32{
        left_gl, bottom_gl,
        left_gl, top_gl,
        right_gl, bottom_gl,
        right_gl, top_gl,
    }
}
