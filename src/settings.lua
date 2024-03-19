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
	[1234567890] = true,
	["Player1"] = true,
}

--\ UI /--

--[[
	Where should the UI be positioned?
	TopLeft, TopRight, BottomLeft, BottomRight
--]]
settings.uiPosition = "TopLeft"

settings.overrideUiPosition = nil -- Set to a UDim2 to override the position

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
	Basically this means only the input bar will be visible no matter what when the player is on a team with radio access.

	Removes the chat window, this makes it easier to use the radio when in the TopLeft position.
--]]
settings.overrideWindowEnabled = true

--[[
	Enabled bubble chat. Text will appear above the player is what it means.
	If you already have bubble chat enabled this can be ignored.
--]]
settings.forceBubbleChat = true

--\ DEVELOPER /--
settings.v = "0.1-alpha.1"
settings.debug = true

return settings