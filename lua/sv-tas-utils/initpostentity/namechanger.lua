local defaultName = "Total Anarchy Server [Wire|SfEx|CSLua] - "
local rootName = CreateConVar("root_hostname", defaultName, FCVAR_ARCHIVE, "Server name to use before appending msg")
local delay = CreateConVar("hostname_change_delay", 300, FCVAR_ARCHIVE, "Time to wait before changing hostname", 1)

--	"-----------------------"  How long one of these entries can be assuming we're using the default name above
local names = {
	"Site under construction",
	"Better than s&box",
	"Complaining about Lua",
	"Surprise restarts",
	"Powered by LinuxGSM",
	"Overengineering addons",
	"64 char hostname limit"
}

-- Verify name lenghs
for _, name in ipairs(names) do
	local length = #rootName:GetString() + #name
	if length > 64 then
		print(string.format("WARNING | Name %s is %i longer than the maximum number of characters allowed", name, length - 64))
	end
end

local function chooseName()
	local choice = names[math.random(#names)]
	RunConsoleCommand("hostname", rootName:GetString() .. choice)
end

chooseName()
timer.Create("TAS.NameChanger", delay:GetFloat(), 0, chooseName)
