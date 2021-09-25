-- Adds a cleanup command using NADMOD
local CATEGORY = "TAS Utilities" -- Really should be exposed in TASUtils as a constant

if NADMOD == nil then
    ErrorNoHalt("Couldn't create the cleanup command! (NO NADMOD!)")
end

local function cleanupLogic(calling_ply, targets)
    for k , ply in pairs(targets) do
        if IsValid(ply) then
            NADMOD.CleanPlayer(calling_ply, ply)
        end
    end

    ulx.fancyLogAdmin(calling_ply, "#A cleaned up #T's props", targets)
end

local cleanupCmd = ulx.command(CATEGORY, "ulx cleanup", cleanupLogic, "!cleanup")
cleanupCmd:addParam({type = ULib.cmds.PlayersArg})
cleanupCmd:defaultAccess(ULib.ACCESS_ADMIN)
cleanupCmd:help("Cleans up props owned by target(s)")