local TYPES = {"gib","item_*","debris","helicopter_chunk","weapon_*","prop_combine_ball","prop_ragdoll"}
local Count = 0

local cleanGibsCmd = ulx.command(TASUtils.Category, "ulx cleangibs", function(calling_ply)
    for _, class in ipairs(TYPES) do
        for _, ent in ipairs(ents.FindByClass(class)) do
            SafeRemoveEntity(ent)
            Count = Count + 1
        end
    end
    ulx.fancyLogAdmin(calling_ply, "#A cleaned up #i gibs", Count)
end, "!cleangibs")

cleanGibsCmd:defaultAccess(ULib.ACCESS_ADMIN)
cleanGibsCmd:help("Cleans up all gibs on the map")