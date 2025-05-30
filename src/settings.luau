--[[
	 _____               _                     _______                 _
	|  __ \             | |                   |__   __|               | |
	| |__) |   ___    __| |   ___    _ __        | |      ___    ___  | |__
	|  _  /   / _ \  / _  |  / _ \  |  _ \       | |     / _ \  / __| |  _ \
	| | \ \  |  __/ | (_| | | (_) | | | | |      | |    |  __/ | (__  | | | |
	|_|  \_\  \___|  \__,_|  \___/  |_| |_|      |_|     \___|  \___| |_| |_|
	Radio System
	Settings
--]]

local settings = {}

--\ CHANNELS /--

--[[
	This configures all avaliable channels, each team can get specific acces as configured below.
	Format:
	[id] = {
		["name"] = "channelName",
	}
--]]
settings.channels = {
	[1] = {
		["name"] = "Main",
	},
	[2] = {
		["name"] = "Tac1",
	},
	[3] = {
		["name"] = "Tac2",
	},
	[4] = {
		["name"] = "Police",
	},
	[5] = {
		["name"] = "Fire",
	},
}

--[[
	How many messages should be stored in the channel history?
	Setting this to 0 will disable history.
	This only affects when a player receives the radio gui,
	it will not change how much history is stored as the channel
	fills up. Basically player join they get x history of the channel.
--]]
settings.channelHistory = 100

--\ VOICE /--

--[[
	How should the voice chat be heard?
	"player" - Audio is from the player's character
	"camera" - Audio is from the player's camera
]]
settings.voiceType = "player"

--[[
	Audio boost
	Increase this if the audio is too quiet, max is 3
	This max is a limit of Roblox, do not report issues if you cant get over 3.
]]
settings.audioBoost = 1

--\ ACCESS /--

--[[
	All access is simply defined by either the channel numbers,
	or false for none,
	or true for all.
--]]

settings.default = false

settings.teams = {
	["Police"] = {
		1,
		2,
		3,
		4,
	},
	["Fire"] = {
		1,
		2,
		3,
		5,
	},
}

settings.users = {
	[123456789000] = true,
	["over_twenty_characters"] = true,
}

--\ PANIC /--

--[[
	Is the panic button enabled?
]]
settings.panicButtonEnabled = true

--[[
	Panic button behavior

	"all" - All channels will recieve panic
	"channel" - Only the current channel will recieve panic
]]
settings.panicBehavior = "all"

--[[
	Determins the message sent when the panic button is pressed
	Use this to give location or other information

	Function MUST return a string
]]
settings.getPanicMessage = function(player: Player): string
	return `{player.Name} has activated the panic button!`
end

--[[
	Sets the panic button cooldown in seconds
	This is per user
]]
settings.panicCooldown = 30

--\ UI /--

--[[
	Where should the UI be positioned?
	TopLeft, TopRight, BottomLeft, BottomRight
--]]
settings.uiPosition = "TopLeft"

settings.overrideUiPosition = nil -- Set to a UDim2 to override the position

--[[
	Change the size of the UI
	Must be a UDim2
]]
settings.uiSize = UDim2.fromScale(0.4, 0.35)

settings.uiMaxSize = Vector2.new(475, math.huge) -- Same as new TextChatService default

--[[
	The keybinds used to enable/disable mic/text
]]
settings.keybinds = {
	text = Enum.KeyCode.T,
	mic = Enum.KeyCode.Y,
	hide = Enum.KeyCode.H, -- You can also click the "Radio" text
}

--[[
	Until Roblox makes public audios possible you have to
	manually remake this audios...
	Default audio is from http://www.w2sjw.com/radio_sounds.html
	sideTone is MDC_Sidetone
	keyDown/keyUp/messageRecieved is MDC1200
	panic button is a free audio taken from the marketplace
	it should work without any changes.

	You can set to nil or false to disable any sounds
--]]
settings.audio = {
	messageRecieved = "rbxassetid://16800392019",
	sideTone = "rbxassetid://16800390322",
	keyDown = "rbxassetid://16800392019",
	keyUp = "rbxassetid://16800392019",
	panic = "rbxassetid://4887758282", -- This should work out of the box
}

--\ CHAT CONFIG /--

--[[
	When the player is on a team with radio access, should the chat window be force removed?

	Removes the chat window, this makes it easier to use the radio when in the TopLeft position.
	**ONLY WORKS WITH NEW TEXT CHAT SERVICE**
--]]
settings.overrideWindowEnabled = true

--[[
	Adds padding to the UI to account for the chat window
	Recommended to set to 0 if not using TopLeft position

	Default is 50
]]
settings.additionalTopPadding = 50

--[[
	Default text chat channel
	Only change this if you have TextChatService.CreateDefaultChannels set to false
]]
settings.defaultTextChannel = "RBXGeneral"

--\ DEVELOPER /--
settings.v = "1.3"
settings.debug = false

return settings
