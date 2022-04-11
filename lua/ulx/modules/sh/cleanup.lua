-- Adds a cleanup command using NADMOD

local function cleanupLogic(calling_ply, targets)
    for _, ply in pairs(targets) do
        if IsValid(ply) and NADMOD then
            NADMOD.CleanPlayer(calling_ply, ply)
        end
    end

    ulx.fancyLogAdmin(calling_ply, "#A cleaned up #T's props", targets)
end

local cleanupCmd = ulx.command(TASUtils.Category, "ulx cleanup", cleanupLogic, "!cleanup")
cleanupCmd:defaultAccess(ULib.ACCESS_ADMIN)
cleanupCmd:help("Cleans up props owned by target(s)")
cleanupCmd:addParam({
    type = ULib.cmds.PlayersArg,
    default = "^",
    ULib.cmds.optional
})