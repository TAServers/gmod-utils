local function plural(value, noun)
	return value ~= 1 and noun .. "s" or noun
end

local startTime = SysTime()
local uptimeCommand = ulx.command("Chat", "ulx uptime", function()
	local time_data = string.FormattedTime(SysTime() - startTime)
	local h, m, s = time_data.h, time_data.m, time_data.s

	if h < 1 and m < 1 then
		ulx.fancyLog(
			"Server has been running for #i #s",
			s,
			plural(s, "second")
		)
	elseif h < 1 then
		ulx.fancyLog(
			"Server has been running for #i #s and #i #s",
			m,
			plural(m, "minute"),
			s,
			plural(s, "second")
		)
	else
		ulx.fancyLog(
			"Server has been running for #i #s and #i #s",
			h,
			plural(h, "hour"),
			m,
			plural(m, "minute")
		)
	end
end, "!uptime")

uptimeCommand:defaultAccess(ULib.ACCESS_ALL)
uptimeCommand:help("Prints the server uptime")
