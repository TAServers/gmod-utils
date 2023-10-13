local NAME_FORMAT =
	"[TAS] Total Anarchy Servers ${region} | E2,SF,ACF | ${message}"
local MAX_HOSTNAME_LENGTH = 63
local SV_LOCATION_CONVAR = GetConVar("sv_location")

local delay = CreateConVar(
	"hostname_change_delay",
	300,
	FCVAR_ARCHIVE,
	"Time to wait before changing hostname",
	1
)

local MESSAGES = {
	------------------ How long one of these entries can be
	"Better than s&box",
	"Surprise restarts",
	"Powered by Docker",
	"Overengineering",
	"Squashing bugs",
	"StarfallEx > E2",
	"100% furry free",
	"No admin bypass",
	"Tracing rays",
	"Spamming cubes",
}

local function getFormattedHostname(message)
	---@type string
	local region = SV_LOCATION_CONVAR:GetString():upper()

	-- Redundant local to avoid returning gsub count
	local formatted = NAME_FORMAT:gsub("${region}", region)
		:gsub("${message}", message)
	return formatted
end

for _, message in ipairs(MESSAGES) do
	local name = getFormattedHostname(message)
	local length = #name

	if length > MAX_HOSTNAME_LENGTH then
		print(
			string.format(
				"WARNING | Name '%s' is %i longer than the maximum number of characters allowed (%i)",
				name,
				length - MAX_HOSTNAME_LENGTH,
				MAX_HOSTNAME_LENGTH
			)
		)
	end
end

local changeTime = CurTime()
hook.Add("Think", "TAS.NameChanger", function()
	local time = CurTime()
	if time >= changeTime then
		local choice = MESSAGES[math.random(#MESSAGES)]
		RunConsoleCommand("hostname", getFormattedHostname(choice))

		changeTime = time + delay:GetFloat()
	end
end)
