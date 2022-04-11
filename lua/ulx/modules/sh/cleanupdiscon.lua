local cleanupCmd = ulx.command(TASUtils.Category, "ulx cleanupdiscon", function(calling_ply)
	if NADMOD then
		NADMOD.CDP(calling_ply, "", {})
	end
	ulx.fancyLogAdmin(calling_ply, "#A cleaned up disconnected players props")
end, "!cleanupdiscon")
cleanupCmd:defaultAccess(ULib.ACCESS_ADMIN)
cleanupCmd:help("Removes all props owned by disconnected players")