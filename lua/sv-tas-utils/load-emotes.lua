local function transformRelayEmoteToSChatEmoji(relayEmote)
	local uri = relayEmote:GetUrl()

	return {
		id = relayEmote:GetName(),
		uri = uri,
		numericId = relayEmote:GetId(),
		isAnimated = uri:sub(-4, -1) == ".gif",
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
