package main

import "gfx"




draw_input :: proc(r: ^gfx.Renderer, font: ^gfx.Font, buffer: []u8) {
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
    
    
    gfx.draw_text(r, string(buffer), 50.0, baseline_y, gfx.WHITE, font)
}
