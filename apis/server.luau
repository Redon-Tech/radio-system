--[[
	 _____               _                     _______                 _
	|  __ \             | |                   |__   __|               | |
	| |__) |   ___    __| |   ___    _ __        | |      ___    ___  | |__
	|  _  /   / _ \  / _  |  / _ \  |  _ \       | |     / _ \  / __| |  _ \
	| | \ \  |  __/ | (_| | | (_) | | | | |      | |    |  __/ | (__  | | | |
	|_|  \_\  \___|  \__,_|  \___/  |_| |_|      |_|     \___|  \___| |_| |_|
	Radio System
	Server API

	MIT License
	Copyright (c) 2024 Redon Tech
--]]

-- Types

export type ScriptConnection = {
	disconnect: () -> nil,
}

-- Everything Else

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local shared = ReplicatedStorage:WaitForChild("radioShared")
local comm = require(shared:WaitForChild("comm"))

local server = {}
server.__index = server

function server.init()
	local apiEvents = comm.new("api")
	local data = {
		apiEvents = apiEvents,
		serverApi = apiEvents:bindableEvent("serverApi"),
		connections = {
			receivedClientMessage = {},
			receivedActivateVoice = {},
			authorizedClient = {},
			channelAddPlayer = {},
			channelRemovePlayer = {},
		},
	}
	local self = setmetatable(data, server)

	self._mainConnection = self.serverApi:connect(function(message: string, ...)
		if self.connections[message] then
			for _, connection in pairs(self.connections[message]) do
				connection(...)
			end
		end
	end)

	return self
end

function server:cleanup()
	table.clear(self.connections)
	self._mainConnection:Disconnect()
end

function server:_connect(message: string, func: (...any) -> nil): ScriptConnection
	table.insert(self.connections[message], func)
	local connection = {}
	function connection.disconnect()
		table.remove(self.connections[message], self.connections[message]:find(func))
	end
	return connection
end

function server:receivedClientMessage(
	func: (player: Player, message: string, channelId: number) -> nil
): ScriptConnection
	return self:_connect("receivedClientMessage", func)
end

function server:receivedActivateVoice(func: (player: Player, channelId: number) -> nil): ScriptConnection
	return self:_connect("receivedActivateVoice", func)
end

function server:receivedPanic(func: (player: Player, channelId: number) -> nil): ScriptConnection
	return self:_connect("receivedPanic", func)
end

function server:authorizedClient(func: (player: Player, authorizedChannels: { number }) -> nil): ScriptConnection
	return self:_connect("authorizedClient", func)
end

function server:channelAddPlayer(func: (id: number, player: Player) -> nil): ScriptConnection
	return self:_connect("channelAddPlayer", func)
end

function server:channelRemovePlayer(func: (id: number, player: Player) -> nil): ScriptConnection
	return self:_connect("channelRemovePlayer", func)
end

function server:createSystemMessage(
	channelId: number,
	message: {
		text: string,
		headerText: string?,
		backgroundColor3: Color3?,
		icon: string?,
		iconColor3: Color3?,
		iconRounded: boolean?,
		sideText: string?,
		sideAccent: Color3?,
	}
)
	self.serverApi:fire("createSystemMessage", channelId, message)
end

function server:activatePlayersVoice(channelId: number, player: Player)
	self.serverApi:fire("activatePlayersVoice", channelId, player)
end

return server
