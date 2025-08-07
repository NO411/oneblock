local modname = core.get_current_modname()
local S = core.get_translator(modname)

core.set_mapgen_setting("mg_name", "singlenode", true)

oneblock = {
	items = {},
}

local wait_time = 30 + 1
local timer = 0
local clock = 0
local timer_hud = {}
local item_pos = {x = 0, y = 1, z = 0}
local mcl_core_mod = core.get_modpath("mcl_core")

local function set_ppos(player)
	player:set_pos(item_pos)
end

local forbidden_items = {
	[""] = true,
	["air"] = true,
	["ignore"] = true,
	["unknown"] = true,
	["oneblock:oneblock"] = true,
	["mcl_core:bedrock"] = true,
	["mcl_commandblock:commandblock_off"] = true,
	["mcl_commandblock:commandblock_on"] = true,
}

core.register_on_mods_loaded(function()
	for item, def in pairs(core.registered_items) do
		if not forbidden_items[item]
		and def and def.description and def.description ~= ""
		and def.groups.not_in_creative_inventory ~= 1 then
			table.insert(oneblock.items, item)
		end
	end
end)

core.register_on_joinplayer(function(player)
	timer_hud[player] = player:hud_add({
		type = "text",
		text = "",
		position = {x = 0.5, y = 0.05},
		alignment = {x = 0, y = 0},
		offset = {x = -5, y = -5},
		z_index = 1001,
		number = 0xFFEE00,
	})
end)

core.register_on_newplayer(function(player)
	set_ppos(player)
end)

core.register_on_leaveplayer(function(player)
	timer_hud[player] = nil
end)

core.register_on_respawnplayer(function(player)
	set_ppos(player)
	return true
end)

core.register_globalstep(function(dtime)
	timer = timer + dtime
	clock = clock + dtime
	if clock >= 1 then
		local time = tostring((timer - wait_time) * -1)
		local split = time:find("%.")
		if split then
			time = time:sub(1, split - 1)
		end
		for _, player in pairs(core.get_connected_players()) do
			player:hud_change(timer_hud[player], "text", S("Next item in: @1 s", time))
		end
		clock = 0
	end
	if timer >= wait_time then
		core.add_item(item_pos, oneblock.items[math.random(#oneblock.items)])
		timer = 0
	end
end)

if not mcl_core_mod then
	core.register_node("oneblock:oneblock", {
		description = "oneblock",
		tiles = {"oneblock.png"},
		on_blast = function(pos, intensity) end,
	})
end

core.register_on_generated(function(minp, maxp, blockseed)
	local node
	if mcl_core_mod then
		node = "mcl_core:bedrock"
	else
		node = "oneblock:oneblock"
	end
	core.set_node({x = 0, y = 0, z = 0}, {name = node})
end)
