local defaultName = "Total Anarchy Server [Wire|SfEx|CSLua] - "
local rootName = CreateConVar("root_hostname", defaultName, FCVAR_ARCHIVE, "Server name to use before appending msg")
local delay = CreateConVar("hostname_change_delay", 300, FCVAR_ARCHIVE, "Time to wait before changing hostname", 1)

--	"----------------------"  How long one of these entries can be assuming we're using the default name above
local names = {
	"Better than s&box",
	"Complaining about Lua",
	"Surprise restarts",
	"Powered by LinuxGSM",
	"Overengineering addons",
	"63charhostnamelimitwhy",
	"Under construction",
	"Squashing bugs",
	"StarfallEx > E2"
}

-- Verify name lengths
for _, name in ipairs(names) do
	local length = #rootName:GetString() + #name
	if length > 63 then
		print(string.format("WARNING | Name %s is %i longer than the maximum number of characters allowed", name, length - 63))
	end
end

local changeTime = CurTime()
hook.Add("Think", "TAS.NameChanger", function()
	local time = CurTime()
	if time >= changeTime then
		local choice = names[math.random(#names)]
		RunConsoleCommand("hostname", rootName:GetString() .. choice)

		changeTime = time + delay:GetFloat()
	end
end)
