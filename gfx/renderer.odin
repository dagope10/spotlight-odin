package gfx



import gl "vendor:OpenGL"
import "core:fmt"
import "core:os"



// Indexes for EBO
indexes := [6]u32{
    0,1,2,
    2,1,3 
}

init :: proc() -> Renderer {

    vao, vbo, ebo: u32
    // We define a callback function for when it is resized
    
    
    gl.GenVertexArrays(1, &vao)
    gl.BindVertexArray(vao)


    // Gen Buffers
    gl.GenBuffers(1, &vbo)
    gl.GenBuffers(1, &ebo)

    // Bind buffers
    gl.BindBuffer(gl.ARRAY_BUFFER, vbo)
    // 64 bytes, size of Vertex
    gl.BufferData(gl.ARRAY_BUFFER, 4 * size_of(Vertex), nil, gl.DYNAMIC_DRAW)

    gl.BindBuffer(gl.ELEMENT_ARRAY_BUFFER, ebo)
    gl.BufferData(gl.ELEMENT_ARRAY_BUFFER, size_of(indexes), &indexes, gl.STATIC_DRAW)
    // Define a vertex with layout 0, two dots , type Float, no normalization and from position 0 in the VBO
    gl.VertexAttribPointer(0, 2, gl.FLOAT, gl.FALSE, size_of(Vertex), 0)
    gl.VertexAttribPointer(1, 2, gl.FLOAT, gl.FALSE, size_of(Vertex), offset_of(Vertex, uv))

    // Enable both defined vertex
    gl.EnableVertexAttribArray(0)
    gl.EnableVertexAttribArray(1)

    vertex_shader := string(#load("shaders/vertex.glsl"))
    color_shader := string(#load("shaders/fragments.glsl"))

    // Load .glsl
    program_id, program_ok := gl.load_shaders_source(vertex_shader, color_shader)
    if !program_ok {
        fmt.println("Error: Failed to load and compile shaders"); os.exit(1)
    }

    color_location := gl.GetUniformLocation(program_id, "uColor")
    dimensions_location := gl.GetUniformLocation(program_id, "uDimensions")
    radius_location := gl.GetUniformLocation(program_id, "uRadius")
    atlas_location := gl.GetUniformLocation(program_id, "atlasText")
    gl.Enable(gl.BLEND)
    gl.BlendFunc(gl.SRC_ALPHA, gl.ONE_MINUS_SRC_ALPHA)
    gl.UseProgram(program_id)

    return Renderer {
        vao = vao,
        vbo = vbo,
        ebo = ebo,
        width = 720,
        height = 420,
        program_id = program_id,
        color_location = color_location,
        dimensions_location = dimensions_location,
        radius_location = radius_location,
        atlas_location = atlas_location,
    }

}

draw_atlas :: proc(r: ^Renderer, x, y, width, height: u32, color: Color, font: ^Font) {
    gl.ActiveTexture(gl.TEXTURE0)
    gl.BindTexture(gl.TEXTURE_2D, font.texture)
    assert(r.atlas_location != -1)
    gl.Uniform1i(r.atlas_location, 0)

    draw_rect(r, x, y, width, height, color)
}

draw_rect :: proc(r: ^Renderer,
                  x, y, width, height: u32,
                  color: Color,
                  radius: f32 = 0,
                 ) {

    vertices := calculate_vertices(r, x, y, width, height)
    gl.BindBuffer(gl.ARRAY_BUFFER, r.vbo)
    gl.BufferSubData(gl.ARRAY_BUFFER, 0, size_of(vertices), &vertices)
    
    gl.BindVertexArray(r.vao)
    gl.Uniform4f(r.color_location,
                 color.r,
                 color.g,
                 color.b,
                 color.a,
                )
    gl.Uniform1f(r.radius_location, radius)
    gl.Uniform2f(r.dimensions_location, f32(width), f32(height))
    gl.DrawElements(gl.TRIANGLES, 6, gl.UNSIGNED_INT, nil)
}


renderer_clear :: proc() {
    gl.Clear(gl.COLOR_BUFFER_BIT)
}

resize :: proc(r: ^Renderer, w, h : u32) {
    r.width = w
    r.height = h
    gl.Viewport(0, 0, i32(w), i32(h))
}


begin_frame :: proc(renderer: ^Renderer) 
{
    gl.Clear(gl.COLOR_BUFFER_BIT);
    gl.UseProgram(renderer.program_id);
    gl.BindVertexArray(renderer.vao);    
}


@(private)
calculate_vertices :: proc(r: ^Renderer, x, y, width, height : u32) -> [4]Vertex {
    left, right, top, bottom := x, x + width, y, y + height
    left_gl := (f32(left) / f32(r.width)) * 2 - 1
    right_gl := (f32(right) / f32(r.width)) * 2 - 1
    top_gl := 1 - (f32(top) / f32(r.height)) * 2
    bottom_gl := 1 - (f32(bottom) / f32(r.height)) * 2

    return [4]Vertex{
        { pos = {left_gl, bottom_gl}, uv = {0, 1} },
        { pos = {left_gl, top_gl}, uv = {0, 0} },
        { pos = {right_gl, bottom_gl}, uv = {1, 1} },
        { pos = {right_gl, top_gl}, uv = {1, 0} },
    }
}
