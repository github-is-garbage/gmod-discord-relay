-- Not a normal event but 2bad2sad

gameevent.Listen("player_disconnect")
hook.Add("player_disconnect", "DiscordRelay::OnDisconnect", function(Data)
	local SteamID = Data.networkid
	local SteamID64 = util.SteamIDTo64(SteamID)
	local Username = Data.name
	local Reason = Data.reason

	if DiscordRelay.Config.FilterUsernames then
		Username = DiscordRelay.Util.ASCIIFilter(Username)
	end

	Reason = DiscordRelay.Util.ASCIIFilter(Reason)
	Reason = DiscordRelay.Util.MarkdownEscape(Reason)

	local Description = Format("%s disconnected (%s)", Username, Reason)

	DiscordRelay.Util.WebhookAutoSend({
		["username"] = string.Left(Username, 32),
		["embeds"] = {
			DiscordRelay.Util.CreateEmbed(Color(255, 0, 0), SteamID, Description)
		}
	}, SteamID64, function()
		DiscordRelay.Util.UnCache(SteamID64)
	end)
end)
