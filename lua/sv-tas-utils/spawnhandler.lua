-- This MAY fix issues with buggy spawning
local gm = gmod.GetGamemode()

hook.Add("PlayerSelectSpawn", "TASUtils.SpawnHandler", function(plr)
	local spawns = ents.FindByClass("info_player_start")
	return spawns[math.random(#spawns)]
end)

hook.Add("PlayerSpawn", "TASUtils.SpawnHandler", function(plr, transition)
	local spawnent = hook.Call("PlayerSelectSpawn", gm, plr, transition)
	timer.Simple(0, function()
		if spawnent and IsEntity(spawnent) and spawnent:IsValid() then
			plr:SetPos(spawnent:GetPos())
			plr:SetEyeAngles(spawnent:GetAngles())
		end
	end)
end)
