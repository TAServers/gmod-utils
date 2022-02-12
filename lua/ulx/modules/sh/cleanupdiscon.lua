local cleanupCmd = ulx.command(TASUtils.Category, "ulx cleanupdiscon", function(calling_ply)
    if NADMOD then
        NADMOD.CDP(calling_ply, "", {})
    end
end, "!cleanupdiscon")
cleanupCmd:defaultAccess(ULib.ACCESS_ADMIN)
cleanupCmd:help("Removes all props owned by disconnected players")
