local TYPES = {"gib","item_*","debris","helicopter_chunk","weapon_*","prop_combine_ball"}
local Count = 0

-- dead npc's dont have ondie functions

local cleanGibsCmd = ulx.command(TASUtils.Category, "ulx cleangibs", function(calling_ply)
    for _, class in ipairs(TYPES) do
        for _, ent in ipairs(ents.FindByClass(class)) do
            if ent:IsValid() and ent:GetOwner() ~= NULL then -- i understand null is undefined, but it works :person_shrugging:
                SafeRemoveEntity(ent)
                Count = Count + 1
            end
        end
    end
    ulx.fancyLogAdmin(calling_ply, "#A cleaned up #i gibs", Count)
end, "!cleangibs")

cleanGibsCmd:defaultAccess(ULib.ACCESS_ADMIN)
cleanGibsCmd:help("Cleans up all gibs on the map")