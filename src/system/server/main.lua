-- Redon Tech Radio System

local main = {}
main.__index = main

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local shared = ReplicatedStorage:WaitForChild("radioShared")
local systemSettings = require(shared:WaitForChild("settings"))
local comm = require(shared:WaitForChild("comm"))

local print = function(...)
	if systemSettings.debug then print(`[RTRS Server]: `, ...) end
end
local warn = function(...)
	if systemSettings.debug then warn(`[RTRS Server]: `, ...) end
end

function main.init()
	print("Initializing Radio System")
	local textEvents = comm.new("text")
	local voiceEvents = comm.new("voice")
	local data = {
		textEvents = {
			clientMessage = textEvents:remoteEvent("clientMessage"),
			systemMessage = textEvents:remoteEvent("systemMessage"),
		}
	}
	local self = setmetatable(data, main)

	self.channels = self:setupChannels()


	self.textEvents.clientMessage:connect(function(...)
		self:receiveMessage(...)
	end)

	print("Initialized Radio System")
	return self
end

function main:receiveMessage(player: Player, message: string, channelId: number)
	local channel = self.channels[channelId]
	if channel == nil then
		warn("Received message for non-existant channel")
		return
	end
	channel:receiveMessage(player, message)
end

function main:setupChannels()
	print("Setting up channels")

	local channels = {}
	for id,channel in pairs(systemSettings.channels) do
		channels[id] = require(script.Parent:WaitForChild("channel")).init(self, id)
	end

	print("Channels set up")
	return channels
end

return main