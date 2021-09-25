local curtimeRestartThresh = CreateConVar("curtime_restart_thresh", 43200, FCVAR_ARCHIVE, "CurTime at which to attempt to restart the server", 3600)
hook.Add("Think", "TAS.CurTimeRestart", function()
	if CurTime() > curtimeRestartThresh:GetInt() and player.GetCount() == 0 then
		DiscordRelay.CachePost({type = "custom", body = "Restarting to reduce CurTime..."})
		RunConsoleCommand("relay_stop")
		RunConsoleCommand("changelevel", game.GetMap())
	end
end)
