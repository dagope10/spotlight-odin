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
    atlas_location: i32,
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


COLOR_WHITE :: Color{1.00, 1.00, 1.00, 1.00}
COLOR_BLACK :: Color{0.00, 0.00, 0.00, 1.00}

COLOR_RED ::       Color{1.00, 0.00, 0.00, 1.00}
COLOR_GREEN ::     Color{0.00, 1.00, 0.00, 1.00}
COLOR_BLUE ::      Color{0.00, 0.00, 1.00, 1.00}

COLOR_GRAY_100 ::  Color{0.10, 0.10, 0.10, 1.00}
COLOR_GRAY_200 ::  Color{0.15, 0.15, 0.15, 1.00}
COLOR_GRAY_300 ::  Color{0.20, 0.20, 0.20, 1.00}
COLOR_GRAY_400 ::  Color{0.30, 0.30, 0.30, 1.00}
COLOR_GRAY_500 ::  Color{0.50, 0.50, 0.50, 1.00}
COLOR_GRAY_700 ::  Color{0.70, 0.70, 0.70, 1.00}
COLOR_GRAY_900 ::  Color{0.90, 0.90, 0.90, 1.00}


COLOR_BACKGROUND ::  Color{0.055, 0.055, 0.065, 1.0}
COLOR_SURFACE ::     Color{0.085, 0.085, 0.095, 1.0}
COLOR_INPUT ::       Color{0.115, 0.115, 0.130, 1.0}
COLOR_SELECTED ::    Color{0.165, 0.165, 0.185, 1.0}
COLOR_HOVER ::       Color{0.135, 0.135, 0.150, 1.0}

COLOR_TEXT ::        Color{0.94, 0.94, 0.96, 1.0}
COLOR_TEXT_MUTED ::  Color{0.58, 0.58, 0.62, 1.0}

COLOR_ACCENT ::      Color{0.30, 0.45, 0.95, 1.0}
