local curtimeRestartThresh = CreateConVar(
	"curtime_restart_thresh",
	43200,
	FCVAR_ARCHIVE,
	"CurTime at which to attempt to restart the server",
	3600
)

local curtimeRestartMap = CreateConVar(
	"curtime_restart_map",
	"gm_construct",
	FCVAR_ARCHIVE,
	"The map to restart to when resetting CurTime"
)

hook.Add("Think", "TAS.CurTimeRestart", function()
	if CurTime() > curtimeRestartThresh:GetInt() and player.GetCount() == 0 then
		RunConsoleCommand("changelevel", curtimeRestartMap:GetString())
	end
end)
