if SERVER then
	local fontColour = Color(230, 230, 230)

	hook.Add("PlayerConnect", "TAS.JoinAndLeaveMsgs", function(name)
		TASUtils.Broadcast(fontColour, string.format("%s is connecting to the server...", name))
	end)

	hook.Add("PlayerSpawn", "TAS.JoinAndLeaveMsgs", function(plr)
		-- TODO: Player team is invalid here, need a way to solve that
		TASUtils.Broadcast(team.GetColor(plr:Team()), plr:Nick(), fontColour, " just joined the server")
	end)

	hook.Add("PlayerDisconnected", "TAS.JoinAndLeaveMsgs", function(plr)
		TASUtils.Broadcast(team.GetColor(plr:Team()), plr:Nick(), fontColour, " left the server")
	end)
else
	hook.Add("ChatText", "TAS.JoinAndLeaveMsgs", function(_, _, _, mode)
		if mode == "joinleave" then
			return true
		end
	end)
end