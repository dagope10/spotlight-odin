package gfx

import "core:mem"
import "core:fmt"
import stbtt "vendor:stb/truetype"
import gl "vendor:OpenGL"
import "core:os"

Font :: struct {
    texture: u32,
    baked_chars: [96]stbtt.bakedchar,
    atlas_width: i32,
    atlas_height: i32,
    size: f32,

    ascent: f32,
    descent: f32,
    line_gap: f32,
}


init_font_atlas :: proc(arena: ^mem.Arena, font_bytes: []u8) -> Font {
    font := Font{
        atlas_width = 512,
        atlas_height = 512,
        size = 32.0,
    }
    
    temp_region := mem.begin_arena_temp_memory(arena)
    defer mem.end_arena_temp_memory(temp_region)
    temp_bitmap, err := mem.arena_alloc_bytes_non_zeroed(arena, 256 * mem.Kilobyte)
    assert(err == nil)

    stbtt.GetScaledFontVMetrics(raw_data(font_bytes),
                                0,
                                font.size,
                                &font.ascent,
                                &font.descent,
                                &font.line_gap
                               )
    fmt.printfln("ascent: %v", font.ascent)
    fmt.printfln("descent: %v", font.descent)
    fmt.printfln("line gap: %v", font.line_gap)

    ok := stbtt.BakeFontBitmap(
        raw_data(font_bytes),
        0,
        32.0,
        raw_data(temp_bitmap[:]),
        i32(font.atlas_width), i32(font.atlas_height),
        32,96,
        raw_data(font.baked_chars[:])) 
    assert(ok >= 0)


    raw_ascent, raw_descent, raw_line_gap: i32


    gl.GenTextures(1, &font.texture)
    gl.BindTexture(gl.TEXTURE_2D, font.texture)
    gl.PixelStorei(gl.UNPACK_ALIGNMENT, 1)
    gl.TexImage2D(gl.TEXTURE_2D,
                  0,
                  gl.R8,
                  i32(font.atlas_width), i32(font.atlas_height),
                  0,
                  gl.RED,
                  gl.UNSIGNED_BYTE,
                  raw_data(temp_bitmap[:])
                 )
    gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.LINEAR)
    gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.LINEAR)

    fmt.println("Font loaded")

    return font
}
