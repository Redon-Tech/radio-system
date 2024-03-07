-- Redon Tech Radio System

local channel = {}
channel.__index = channel

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Chat = game:GetService("Chat")

local shared = ReplicatedStorage:WaitForChild("radioShared")
local systemSettings = require(shared:WaitForChild("settings"))

local print = function(...)
	if systemSettings.debug then print(`[RTRS Server]: `, ...) end
end
local warn = function(...)
	if systemSettings.debug then warn(`[RTRS Server]: `, ...) end
end

function channel.init(main:{any}, id: number)
	print(`Initializing Channel {id}`)
	local data = {
		main = main,
		id = id,
		name = systemSettings.channels[id].name,
		messages = {}, -- UNFILTERED
	}
	local self = setmetatable(data, channel)

	print(`Initialized Channel {id}`)
	return self
end

function channel:_addMessageToHistory(player: Player?, message: string)
	if systemSettings.channelHistory == 0 then return end

	if player == nil then
		player = "System"
	end

	table.insert(self.messages, {
		player = player,
		message = message,
	})

	if #self.messages >= 100 then
		table.remove(self.messages, #self.messages - 100)
	end
end

function channel:receiveMessage(player: Player, message: string)
	self:_addMessageToHistory(player, message)

	message = Chat:FilterStringAsync(message, player, player) -- Ideally we would filter with playerTo, but no
	self.main.textEvents.clientMessage:fireAll(self.id, player, message)
end

return channel