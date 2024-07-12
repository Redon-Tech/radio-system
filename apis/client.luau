--[[
	 _____               _                     _______                 _
	|  __ \             | |                   |__   __|               | |
	| |__) |   ___    __| |   ___    _ __        | |      ___    ___  | |__
	|  _  /   / _ \  / _  |  / _ \  |  _ \       | |     / _ \  / __| |  _ \
	| | \ \  |  __/ | (_| | | (_) | | | | |      | |    |  __/ | (__  | | | |
	|_|  \_\  \___|  \__,_|  \___/  |_| |_|      |_|     \___|  \___| |_| |_|
	Radio System
	Client API

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

local client = {}
client.__index = client

function client.init()
	local apiEvents = comm.new("api")
	local data = {
		apiEvents = apiEvents,
		clientApi = apiEvents:bindableEvent("clientApi"),
		connections = {
			clientMessageRecieved = {},
			systemMessageRecieved = {},
			messageHistoryRecieved = {},
			voiceRecieve = {},
			sendMessage = {},
		},
	}
	local self = setmetatable(data, client)

	self._mainConnection = self.clientApi:connect(function(message: string, ...)
		if self.connections[message] then
			for _, connection in pairs(self.connections[message]) do
				connection(...)
			end
		end
	end)

	return self
end

function client:cleanup()
	table.clear(self.connections)
	self._mainConnection:Disconnect()
end

function client:_connect(message: string, func: (...any) -> nil): ScriptConnection
	table.insert(self.connections[message], func)
	local connection = {}
	function connection.disconnect()
		table.remove(self.connections[message], self.connections[message]:find(func))
	end
	return connection
end

function client:clientMessageRecieved(
	func: (channelId: number, player: Player, message: string) -> nil
): ScriptConnection
	return self:_connect("clientMessageRecieved", func)
end

function client:systemMessageRecieved(func: (
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
) -> nil): ScriptConnection
	return self:_connect("systemMessageRecieved", func)
end

function client:panicButtonActivated(
	func: (channelId: number | boolean, player: Player, message: string) -> nil
): ScriptConnection
	return self:_connect("panicButtonActivated", func)
end

function client:messageHistoryRecieved(func: (channelId: number, history: {}) -> nil): ScriptConnection
	return self:_connect("messageHistoryRecieved", func)
end

function client:voiceRecieve(func: (channelId: number, player: Player) -> nil): ScriptConnection
	return self:_connect("voiceRecieve", func)
end

function client:sendMessage(func: (channelId: number, message: string) -> nil): ScriptConnection
	return self:_connect("sendMessage", func)
end

function client:textActivateChanged(func: (active: boolean) -> nil): ScriptConnection
	return self:_connect("textActivateChanged", func)
end

function client:voiceActivateChanged(func: (active: boolean) -> nil): ScriptConnection
	return self:_connect("voiceActivateChanged", func)
end

function client:getEnabled(): boolean
	return self.apiEvents.folder:WaitForChild("clientApiFunction"):Invoke("getEnabled")
end

function client:setEnabled(enabled: boolean)
	self.clientApi:fire("setEnabled", enabled)
end

return client
