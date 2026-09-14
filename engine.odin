package main

import "core:os"
import "core:fmt"
import "core:strings"
import "base:runtime"
import vmem "core:mem/virtual"
Desktop_Entry :: struct {
    name: string,
    comment: string,
    exec: string,
}

search_files :: proc(scratch_arena: ^vmem.Arena, persistent_alloc: runtime.Allocator) -> []Desktop_Entry {    
    file, err := os.open("/usr/share/applications")
    entry: Desktop_Entry
    entries, alloc_error := make([dynamic]Desktop_Entry, persistent_alloc)
    assert(alloc_error == nil)
    temp_region := vmem.arena_allocator(scratch_arena)

    files, error := os.read_dir(file,0, temp_region)
    for file_info in files {
        inside_desktop_entry := false
        file, err := os.read_entire_file_from_path(file_info.fullpath, context.allocator)
        file_string := transmute(string)file
        entry: Desktop_Entry
        for line in strings.split_lines_iterator(&file_string) {
            if is_entry(line) {
                inside_desktop_entry = is_desktop_entry(line)
                if !inside_desktop_entry do continue
            }

            if !inside_desktop_entry do continue

            head, _, tail := strings.partition(line, "=")
            if head == "Name" do entry.name = tail
            
            if head == "Comment" do entry.comment = tail

            if head == "Exec" {
                exec, _, _ := strings.partition(tail, "%")
                entry.exec = exec
            }
        }
        if entry != {} do append(&entries, entry)
    }


    return entries[:]

}

is_desktop_entry :: proc(entry_name: string) -> bool {
    return "[Desktop Entry]" == entry_name
}

is_entry :: proc(line: string) -> bool {
    return strings.has_prefix(line, "[")
}


filter_entries:: proc(entries:[]Desktop_Entry, app: ^App_State) {
    app.results_len = 0
    query := string(app.buffer[:app.buffer_len])

    for entry in entries {
        if app.results_len == len(app.results) do break
        if strings.contains(strings.to_lower(entry.name), strings.to_lower(string(query))) {
            app.results[app.results_len] = entry
            app.results_len += 1
        }
    }
}

