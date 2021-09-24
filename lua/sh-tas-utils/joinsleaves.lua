if SERVER then
	local fontColour = Color(230, 230, 230)

	hook.Add("PlayerConnect", "TAS.JoinAndLeaveMsgs", function(name)
		TASUtils.Broadcast(fontColour, string.format("%s is connecting to the server...", name))
	end)

	hook.Add("PlayerInitialSpawn", "TAS.JoinAndLeaveMsgs", function(plr)
		-- Single tick timer isn't the cleanest way to wait for ulx to set the player's team (cause it uses the same hook as this), but can't think of anything better rn
		timer.Simple(0, function()
			TASUtils.Broadcast(team.GetColor(plr:Team()), plr:Nick(), fontColour, " just joined the server")
		end)
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
