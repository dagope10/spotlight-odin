package gfx

import "core:mem"
import "core:fmt"
import stbtt "vendor:stb/truetype"
import gl "vendor:OpenGL"


Font :: struct {
    texture: u32,
    baked_chars: [96]stbtt.bakedchar,
    atlas_width: i32,
    atlas_height: i32,
    size: f32
}


init_font_atlas :: proc(arena: ^mem.Arena, font_bytes: []u8) -> Font {
    font := Font{
        atlas_width = 512,
        atlas_height = 512,
    }
    temp_region := mem.begin_arena_temp_memory(arena)
    defer mem.end_arena_temp_memory(temp_region)
    temp_bitmap, err := mem.arena_alloc_bytes_non_zeroed(arena, 256 * mem.Kilobyte)

       
    if err != nil {
        panic("(init_font_atlas)Error allocating data for Font type")
    }
    bake_result := stbtt.BakeFontBitmap(
        raw_data(font_bytes),
        0,
        32.0,
        raw_data(temp_bitmap[:]),
        i32(font.atlas_width), i32(font.atlas_height),
        32,96,
        raw_data(font.baked_chars[:]));
    assert(bake_result > 0)

    gl.GenTextures(1, &font.texture)
    gl.BindTexture(gl.TEXTURE_2D, font.texture)
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
    gl.PixelStorei(gl.UNPACK_ALIGNMENT, 1)

    fmt.println("Font loaded")

    return font
}
