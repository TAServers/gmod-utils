local TYPES = {"gib","item_*","debris","helicopter_chunk","weapon_*","prop_combine_ball"}
-- Currently we dont remove dead bodies, but a thing to note is dead npc's do not have ondie functions

local cleanGibsCmd = ulx.command(TASUtils.Category, "ulx cleangibs", function(calling_ply)
	local Count = 0
	for _, class in ipairs(TYPES) do
		for _, ent in ipairs(ents.FindByClass(class)) do
			if ent:IsValid() and not ent:GetOwner():IsValid() then
				SafeRemoveEntity(ent)
				Count = Count + 1
			end
		end
	end
	ulx.fancyLogAdmin(calling_ply, "#A cleaned up #i gib(s)", Count)
end, "!cleangibs")

cleanGibsCmd:defaultAccess(ULib.ACCESS_ADMIN)
cleanGibsCmd:help("Cleans up all gibs on the map")