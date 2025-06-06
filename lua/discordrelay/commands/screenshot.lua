util.AddNetworkString("DiscordRelay::Screenshot")

DiscordRelay.NetStream.Receive("DiscordRelay::Screenshot", function(Data, Sender)
	if not DiscordRelay.Util.GetFromObject(Sender, "Screenshot::Waiting") then
		return
	end

	DiscordRelay.Util.StoreOnObject(Sender, "Screenshot::Waiting", false)

	local Username = Sender:GetName()

	if DiscordRelay.Config.FilterUsernames then
		Username = DiscordRelay.Util.ASCIIFilter(Username)
		Username = DiscordRelay.Util.MarkdownEscape(Username)
	end

	local Size = string.len(Data)

	if Size <= 1 then
		DiscordRelay.Util.WebhookAutoSend({
			["username"] = "Screenshot",
			["content"] = Format("Got invalid screenshot data from %s (%s)", Username, Sender:SteamID())
		})

		return
	end

	local Payload = { -- Build util not this advanced yet
		["content"] = "",
		["embeds"] = {
			{
				["title"] = Sender:SteamID(),
				["description"] = Format("Screenshot from %s (%s)", Username, string.NiceSize(Size)),
				["image"] = { ["url"] = "attachment://screenshot.jpeg" }
			}
		}
	}

	local Parts = {}

	table.insert(Parts, "------DiscordRelayBoundary")
	table.insert(Parts, "Content-Disposition: form-data; name=\"payload_json\"\r\n")
	table.insert(Parts, util.TableToJSON(Payload))

	table.insert(Parts, "------DiscordRelayBoundary")
	table.insert(Parts, "Content-Disposition: form-data; name=\"file\"; filename=\"screenshot.jpeg\"")
	table.insert(Parts, "Content-Type: image/jpeg\r\n")
	table.insert(Parts, Data)
	table.insert(Parts, "------DiscordRelayBoundary--\r\n" )

	local Body = table.concat(Parts, "\r\n")

	DiscordRelay.Util.GetWebhook(DiscordRelay.Config.ChannelID, function(MessageURL)
		CHTTP({
			["url"] = MessageURL,
			["method"] = "POST",

			["headers"] = {
				["Content-Type"] = "multipart/form-data; boundary=----DiscordRelayBoundary",
				["Content-Length"] = string.len(Body)
			},

			["body"] = Body,

			["success"] = DiscordRelay.Util.NoOp,
			["failed"] = DiscordRelay.Util.NoOp
		})
	end)
end)

local function ScreenshotCmd(Author, Member, Arguments)
	local Username = Arguments[1]
	if not isstring(Username) then return end

	local Target = DiscordRelay.Util.FindPlayer(Username)

	if not IsValid(Target) then
		if DiscordRelay.Config.FilterUsernames then
			Username = DiscordRelay.Util.ASCIIFilter(Username)
		end

		DiscordRelay.Util.WebhookAutoSend({
			["username"] = "Screenshot",
			["embeds"] = {
				DiscordRelay.Util.CreateEmbed(
					Color(255, 0, 0),
					"Target Not Found",
					Format("Target %s could not be found", Username)
				)
			}
		})

		return
	end

	DiscordRelay.Util.StoreOnObject(Target, "Screenshot::Waiting", true)

	net.Start("DiscordRelay::Screenshot")
	net.Send(Target)
end

DiscordRelay.Commands.RegisterCommand("screenshot", "Takes a screenshot of a player's game.", DiscordRelay.Enums.CommandPermissionLevels.STAFF_ONLY, ScreenshotCmd)
DiscordRelay.Commands.RegisterAlias("screenshot", "ss")
