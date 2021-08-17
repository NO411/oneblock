local modname = minetest.get_current_modname()
local S = minetest.get_translator(modname)

oneblock = {
    items = {},
}

local wait_time = 60
local timer = 0
local clock = 0
local timer_hud = {}
local item_pos = { x = 0, y = 0.5, z = 0 }
local mcl_core_mod = minetest.get_modpath("mcl_core")

local function set_ppos(player)
    player:set_pos(item_pos)
end

minetest.register_on_mods_loaded(function()
    for item, def in pairs(minetest.registered_items) do
        if item ~= "" and item ~= "air" and item ~= "ignore" and item ~= "unknown" 
        and def and def.description and def.description ~= ""
        and def.groups.not_in_creative_inventory ~= 1 then
            table.insert(oneblock.items, item)
        end
    end
end)

minetest.register_on_joinplayer(function(player)
    timer_hud[player] = player:hud_add({
        hud_elem_type = "text",
        text = "",
        position = { x = 0.5, y = 0.05 },
        alignment = { x = 0, y = 0 },
        offset = { x = -5, y = -5 },
        z_index = 1001,
        number = 0xFFEE00,
    })
end)

minetest.register_on_newplayer(function(player)
    set_ppos(player)
end)

minetest.register_on_leaveplayer(function(player)
    timer_hud[player] = nil
end)

minetest.register_on_respawnplayer(function(player)
    set_ppos(player)
    return true
end)

minetest.register_globalstep(function(dtime)
    timer = timer + dtime
    clock = clock + dtime
    if clock >= 1 then
        local time = tostring((timer - wait_time) * -1)
        local split = time:find("%.")
        if split then
            time = time:sub(1, split - 1)
        end
        for _, player in pairs(minetest.get_connected_players()) do
            player:hud_change(timer_hud[player], "text", S("Next item in: @1 s", time))
        end
        clock = 0
    end
    if timer >= wait_time then
        minetest.add_item(item_pos, oneblock.items[math.random(#oneblock.items)])
        timer = 0
    end
end)

if not mcl_core_mod then
    minetest.register_node("oneblock:oneblock", {
        description = "oneblock",
        tiles = { "blank.png" },
    })
end

minetest.register_on_generated(function(minp, maxp, blockseed)
    local node
    if mcl_core_mod then
        node = "mcl_core:bedrock"
    else
        node = "oneblock:oneblock"
    end
    minetest.set_node({ x = 0, y = 0, z = 0 }, { name = node })
end)
