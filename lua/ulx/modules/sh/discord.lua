local cmd = ulx.command(TASUtils.Category, "ulx discord", function(plr)
	if not IsValid(plr) then return end
	plr:ChatPrint("discord.gg/XqxhqzS72R")
end, "!discord")
cmd:defaultAccess(ULib.ACCESS_ALL)
cmd:help("Prints the Discord server invite")
