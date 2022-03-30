local restartTime = CreateConVar(
	"tasutils_time_to_restart", 60 * 30,
	FCVAR_ARCHIVE,
	"How long to wait after the server is empty to restart (seconds)",
	600
)

hook.Add("PlayerDisconnected", "TAS.Restart", function()
	if player.GetCount() == 0 then
		timer.Create("TAS.Restart", restartTime:GetInt(), 1, function()
			DiscordRelay.CachePost({type = "custom", body = "Resetting the server..."})
			RunConsoleCommand("relay_stop")
			RunConsoleCommand("changelevel", game.GetMap())
		end)
	end
end)

hook.Add("PlayerConnect", "TAS.Restart", function()
	if timer.Exists("TAS.Restart") then
		timer.Remove("TAS.Restart")
	end
end)
