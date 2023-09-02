local function transformRelayEmoteToSChatEmoji(relayEmote)
	return { relayEmote:GetName(), relayEmote:GetUrl() }
end

hook.Add("Relay.InfoPayloadUpdated", "LoadCustomEmotesIntoSChat", function()
	local relayEmotes = Relay.GetEmotes()
	local schatEmotes = {}

	for _, relayEmote in pairs(relayEmotes) do
		table.insert(schatEmotes, transformRelayEmoteToSChatEmoji(relayEmote))
	end

	SChat.Settings:SetEmojis(schatEmotes, "Relay")
end)
