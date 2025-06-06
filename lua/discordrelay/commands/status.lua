DiscordRelay.Commands.RegisterCommand("status", "Shows server information.", DiscordRelay.Enums.CommandPermissionLevels.ALL_USERS, function(Author, Member, Arguments)
	local Uptime = RealTime()
	local MapTime = CurTime()

	Uptime = DiscordRelay.Util.FormatTime(Uptime)
	MapTime = DiscordRelay.Util.FormatTime(MapTime)

	DiscordRelay.Util.WebhookAutoSend({
		["username"] = "Server Status",
		["embeds"] = {
			DiscordRelay.Util.CreateEmbed( -- TODO: This needs those section thingies
				Color(255, 255, 0),
				GetHostName(),

				Format(
					"**IP**: %s\n**Gamemode**: %s\n**Map**: %s (v%d)\n**Player Count**: %d / %d\n**Uptime**: %s\n**Map Time**: %s",

					game.GetIPAddress(),
					gmod.GetGamemode().Name,
					game.GetMap(),
					game.GetMapVersion(),
					player.GetCount(),
					game.MaxPlayers(),
					Uptime,
					MapTime
				)
			)
		}
	})
end)
