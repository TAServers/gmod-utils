local buildCB, pvpCB

if SERVER then
	local buildModePlayers = {}

	hook.Add("PlayerNoClip", "TASUtils.BuildMode", function(plr, desiredNoClipState)
		if not buildModePlayers[plr] and desiredNoClipState then -- desiredNoClipState check in case a user somehow gets into noclip while in PVP and tries to disable it
			return false
		end
	end)

	hook.Add("EntityTakeDamage", "TASUtils.BuildMode", function(target, dmgInfo)
		-- Prevent build mode players from taking damage
		if buildModePlayers[target] then
			dmgInfo:SetDamage(0)
			return
		end

		-- Prevent entities owned by build mode players from taking damage
		if not target:IsPlayer() and target:CPPIGetOwner() and buildModePlayers[target:CPPIGetOwner()] then
			dmgInfo:SetDamage(0)
			return
		end

		-- Prevent players in build mode from dealing damage
		if buildModePlayers[dmgInfo:GetAttacker()] then
			dmgInfo:SetDamage(0)
			return
		end
	end)

	function buildCB(caller, target)
		if not IsValid(target) then return end
		if buildModePlayers[target] then return end

		buildModePlayers[target] = true
		ulx.fancyLogAdmin(caller, caller == target and "#T entered build mode" or "#A made #T enter build mode", target)
	end

	function pvpCB(caller, target)
		if not IsValid(target) then return end
		if not buildModePlayers[target] then return end

		target:SetMoveType(MOVETYPE_WALK)

		buildModePlayers[target] = nil
		ulx.fancyLogAdmin(caller, caller == target and "#T exited build mode" or "#A made #T exit build mode", target)
	end
else
	function buildCB(caller, target)
	end

	function pvpCB(caller, target)
	end
end

--[[
	Register Commands
]]

local buildCmd = ulx.command(TASUtils.Category, "ulx build", buildCB, "!build")

buildCmd:addParam({
	type = ULib.cmds.PlayerArg,
	target = "^",
	default = "^",
	ULib.cmds.optional
})

buildCmd:defaultAccess(ULib.ACCESS_ALL)
buildCmd:help("Changes the target player (or yourself if no target is specified) to Build Mode")

local pvpCmd = ulx.command(TASUtils.Category, "ulx pvp", pvpCB, "!pvp")

pvpCmd:addParam({
	type = ULib.cmds.PlayerArg,
	target = "^",
	default = "^",
	ULib.cmds.optional
})

pvpCmd:defaultAccess(ULib.ACCESS_ALL)
pvpCmd:help("Changes the target player (or yourself if no target is specified) to PVP Mode")
