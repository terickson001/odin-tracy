package profile

import rt "core:runtime"
import "core:strings"

@private
tracy_location :: proc(loc: rt.Source_Code_Location, name := "") -> ^___tracy_source_location_data
{
    tr_loc := new(___tracy_source_location_data);
    tr_loc.function = strings.clone_to_cstring(loc.procedure);
    tr_loc.file = strings.clone_to_cstring(loc.file_path);
    tr_loc.line = u32(loc.line);
    
    return tr_loc;
}

@(deferred_out=scoped_zone_end)
scoped_zone :: proc(name := "", loc:= #caller_location) -> ___tracy_c_zone_context
{
    return scoped_zone_begin(name, loc);
}

scoped_zone_begin :: proc(name := "", loc:= #caller_location) -> ___tracy_c_zone_context
{
    @static loc_map: map[u64]^___tracy_source_location_data;
    tr_loc := loc_map[loc.hash];
    if tr_loc == nil
    {
        tr_loc = tracy_location(loc, name);
        loc_map[loc.hash] = tr_loc;
    }
    return ___tracy_emit_zone_begin(tr_loc, 1);
}

scoped_zone_end :: proc(ctx: ___tracy_c_zone_context)
{
    ___tracy_emit_zone_end(ctx);
}