local function transformRelayEmoteToSChatEmoji(relayEmote)
	return {
		id = relayEmote:GetName(),
		uri = relayEmote:GetUrl(),
		numericId = relayEmote:GetId(),
	}
end

hook.Add("Relay.InfoPayloadUpdated", "LoadCustomEmotesIntoSChat", function()
	local relayEmotes = Relay.GetEmotes()
	local schatEmotes = {}

	for _, relayEmote in pairs(relayEmotes) do
		table.insert(schatEmotes, transformRelayEmoteToSChatEmoji(relayEmote))
	end

	SChat.Settings:SetEmojis(schatEmotes, "Relay")
end)
