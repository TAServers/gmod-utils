local BLACKLIST = {
	god = true,
	getip = true
}

local BUILDMODE_ONLY = {
	applyforce = true,
	setpos = true,
	--setang = true, Allowed for aimbots
	noclip = true,
	sethealth = true,
	setarmor = true,
	setspeed = true,
	setrunspeed = true,
	setwalkspeed = true,
	ignite = true
}

hook.GetTable().PlyCoreCommand.ULX_PlyCore_Access = nil
hook.Add("PlyCoreCommand", "TASUtils.PlyCorePerms", function(caller, target, command)
	print("TEST")
	if BLACKLIST[command] then return true end
	if BUILDMODE_ONLY[command] and (not caller:HasBuildMode() or not target:HasBuildMode()) then return true end
end)
