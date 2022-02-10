local cmd = ulx.command(TASUtils.Category, "ulx workshop", function(plr)
	if not IsValid(plr) then return end
	plr:ChatPrint("https://steamcommunity.com/sharedfiles/filedetails/?id=2609504551")
end, "!workshop")
cmd:defaultAccess(ULib.ACCESS_ALL)
cmd:help("Prints the server's Workshop collection")
