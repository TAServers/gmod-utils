local function plural(value, noun)
	return value ~= 1 and noun .. "s" or noun
end

local startTime = CurTime()
local uptimeCommand = ulx.command("Chat", "ulx uptime", function()
	local uptime = string.FormattedTime(CurTime() - startTime)
	if uptime.h < 1 and uptime.m < 1 then
		ulx.fancyLog(
			"Server has been running for #i #s",
			uptime.s,
			plural(uptime.s, "second")
		)
	elseif uptime.h < 1 then
		ulx.fancyLog(
			"Server has been running for #i #s and #i #s",
			uptime.m,
			plural(uptime.m, "minute"),
			uptime.s,
			plural(uptime.s, "second")
		)
	else
		ulx.fancyLog(
			"Server has been running for #i #s and #i #s",
			uptime.h,
			plural(uptime.h, "hour"),
			uptime.m,
			plural(uptime.m, "minute")
		)
	end
end, "!uptime")

uptimeCommand:defaultAccess(ULib.ACCESS_ALL)
uptimeCommand:help("Prints the server uptime")
