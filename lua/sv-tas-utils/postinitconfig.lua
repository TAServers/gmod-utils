-- This should contain all the configs to be run after lua has finished initialising

hook.Add("InitPostEntity", "TAS.PostInitConfig", function()
	-- Enable relay
	RunConsoleCommand("relay_connection", "localhost:7676")
	RunConsoleCommand("relay_start")
end)
