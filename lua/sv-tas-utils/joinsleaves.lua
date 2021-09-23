hook.Add("PlayerConnect", "TAS.JoinAndLeaveMsgs", function(plr)
	-- Print connecting message
end)

hook.Add("PlayerSpawn", "TAS.JoinAndLeaveMsgs", function(plr)
	-- Print join message
end)

hook.Add("PlayerDisconnected", "TAS.JoinAndLeaveMsgs", function(plr)
	-- Print leave message here
end)
