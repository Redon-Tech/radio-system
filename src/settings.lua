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

settings.channels = {
	[1] = {
		["name"] = "default",
	},
}

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
	},
}

settings.users = {
	[1234567890] = true,
	["Player1"] = true,
}

--\ DEVELOPER /--
settings.v = "0.1-alpha.1"
settings.debug = true

return settings