package gfx


Shader :: struct {
    
}

Renderer :: struct {
    vao: u32,
    vbo: u32,
    ebo: u32,
    program_id: u32,
    width: u32,
    height: u32,
    color_location: i32,
    dimensions_location: i32,
    radius_location: i32,
    text_mode_location: i32,
}
Vec2 :: struct {
    x: f32,
    y: f32
}

Vertex :: struct {
    pos: Vec2,
    uv: Vec2
}

Rect :: struct {
    x: f32,
    y: f32,
    width: f32,
    height: f32
}



Color :: struct {
    r : f32,
    g : f32,
    b : f32,
    a : f32
}

WHITE :: Color{1.0, 1.0, 1.0, 1.0}
BLACK :: Color{0.0, 0.0, 0.0, 1.0}
RED :: Color{1.0, 0.0, 0.0, 1.0}
