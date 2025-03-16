DiscordRelay.Commands.RegisterCommand("rcon", DiscordRelay.Enums.CommandPermissionLevels.STAFF_ONLY, function(Author, Member, Arguments)
	local Command = Arguments[1]
	if not isstring(Command) then return end

	if IsConCommandBlocked(Command) then return end

	DiscordRelay.Util.WebhookAutoSend({
		["username"] = "RCon Results",
		["embeds"] = {
			DiscordRelay.Util.CreateEmbed(
				Color(0, 255, 0),
				"Ran Command on Server",

				Format("```\n%s\n```", table.concat(Arguments, " "))
			)
		}
	})

	RunConsoleCommand(unpack(Arguments))
end)
