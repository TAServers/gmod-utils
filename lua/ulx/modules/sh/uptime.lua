local startTime = CurTime()
local uptimeCommand = ulx.command("Chat", "ulx uptime", function()
	local uptimeSeconds = CurTime() - startTime
	local uptimeFormatted = string.format(
		"%02i:%02i:%02i",
		math.floor(uptimeSeconds / 3600),
		math.floor(uptimeSeconds % 3600 / 60),
		math.floor(uptimeSeconds % 60)
	)
	ulx.fancyLog("Server has been running for #s", uptimeFormatted)
end, "!uptime")

uptimeCommand:defaultAccess(ULib.ACCESS_ALL)
uptimeCommand:help("Prints the server uptime")
