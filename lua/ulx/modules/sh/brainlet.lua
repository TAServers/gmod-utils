local function brainlet(plr, target)
	-- Fetch question from trivia API/dataset

	-- Send question to target client

	-- Log that a brainlet was initiated
end

-- Register CMD
local cmd = ulx.command("TAS Utilities", "ulx brainlet", brainlet, "!brainlet")
cmd:addParam({type = ULib.cmds.PlayerArg})
cmd:defaultAccess(ULib.ACCESS_OPERATOR)
cmd:help("Makes a player have to answer a simple trivia question to not get kicked")