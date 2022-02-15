-- This MAY fix issues with buggy spawning
hook.Add("PlayerSelectSpawn", "TASUtils.SpawnHandler", function(plr)
	local spawns = ents.FindByClass("info_player_start")
	return spawns[math.random(#spawns)]
end)
