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

--\ ACCESS /--

--[[
	All access is simply defined by either the channel numbers,
	or false for none,
	or true for all.
--]]

settings.default = false

settings.teams = {
	["Police"] = {
		1, 2, 3, 4,
	},
	["Fire"] = {
		1, 2, 3, 5,
	}
}

settings.users = {
	[123456789000] = true,
	["over_twenty_characters"] = true,
}

--\ UI /--

--[[
	Where should the UI be positioned?
	TopLeft, TopRight, BottomLeft, BottomRight
--]]
settings.uiPosition = "TopLeft"

settings.overrideUiPosition = nil -- Set to a UDim2 to override the position

--[[
	The keybinds used to enable/disable mic/text
]]
settings.keybinds = {
	text = Enum.KeyCode.T,
	mic = Enum.KeyCode.Y
}

--[[
	Until Roblox makes public audios possible you have to
	manually remake this audios...
	Default audio is from http://www.w2sjw.com/radio_sounds.html
	sideTone is MDC_Sidetone
	keyDown/keyUp/messageRecieved is MDC1200

	You can set to nil or false to disable any sounds
--]]
settings.audio = {
	messageRecieved = "rbxassetid://16800392019",
	sideTone = "rbxassetid://16800390322",
	keyDown = "rbxassetid://16800392019",
	keyUp = "rbxassetid://16800392019",
}

--\ CHAT CONFIG /--

--[[
	When the player is on a team with radio access, should the chat window be force removed?

	Removes the chat window, this makes it easier to use the radio when in the TopLeft position.
	**ONLY WORKS WITH NEW TEXT CHAT SERVICE**
--]]
settings.overrideWindowEnabled = true

--\ DEVELOPER /--
settings.v = "1.0.0"
settings.debug = false

return settings