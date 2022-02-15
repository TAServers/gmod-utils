local BLACKLIST = {
	plyGod = true
}

local BUILDMODE_ONLY = {
	plyApplyForce = true,
	plySetPos = true,
	--plySetAng = true, Allowed for writing aimbots
	plyNoclip = true,
	plySetHealth = true,
	plySetArmor = true,
	plySetSpeed = true
}

hook.Add("PlyCoreCommand", "TASUtils.PlyCorePerms", function(caller, target, command)
	if BLACKLIST[command] then return true end
	if BUILDMODE_ONLY[command] and (not caller:HasBuildMode() or not target:HasBuildMode()) then return true end
end)
