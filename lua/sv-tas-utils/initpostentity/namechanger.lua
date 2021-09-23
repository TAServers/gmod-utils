local defaultName = "[TAS] Total Anarchy Server (Wire, StarfallEx, CSLua and more) | "
local rootName = CreateConVar("root_hostname", defaultName, FCVAR_ARCHIVE, "Server name to use before appending msg")
local delay = CreateConVar("hostname_change_delay", 300, FCVAR_ARCHIVE, "Time to wait before changing hostname", 1)

local names = {
	"Site under construction",
	"PotatoOS has probably broken the relay again",
	"Better than s&box",
	"Complaining about Lua",
	"No crashes, just surprise restarts",
	"Yes we're a programming server",
	"Advancing the field of GMod light transport solutions",
	"Powered by LinuxGSM",
	"Overengineering addons"
}

local function chooseName()
	local choice = names[math.random(#names)]
	RunConsoleCommand("hostname", rootName:GetString() .. choice)
end

chooseName()
timer.Create("TAS.NameChanger", delay:GetFloat(), 0, chooseName)
