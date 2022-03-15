-- This MAY fix issues with buggy spawning
local gm = gmod.GetGamemode()

hook.Add("PlayerSelectSpawn", "TASUtils.SpawnHandler", function(plr)
	local spawns = ents.FindByClass("info_player_start")
	return spawns[math.random(#spawns)]
end)

hook.Add("PlayerSpawn", "TASUtils.SpawnHandler", function(plr, transition)
	timer.Simple(0, function()
		-- For some reason, some unknown addon or cursed LGSM bug sets the movetype to a frozen one - causing the player to be frozen
		plr:SetMoveType(MOVETYPE_WALK)
	end)
end)
