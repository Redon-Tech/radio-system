-- Redon Tech Radio System

local main = {}
main.__index = main

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

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
			sendHistory = textEvents:remoteEvent("sendHistory"),
		},
		voiceEvents = {
			activateVoice = voiceEvents:remoteEvent("activateVoice")
		}
	}
	local self = setmetatable(data, main)

	self.channels = self:setupChannels()
	self:setupAudio()


	self.textEvents.clientMessage:connect(function(...)
		self:receiveMessage(...)
	end)
	self.textEvents.authorize = textEvents:remoteFunction("authorize", self, "authorizeClient")

	self.voiceEvents.activateVoice:connect(function(...)
		self:activateVoice(...)
	end)

	print("Initialized Radio System")
	return self
end

function main:authorizeClient(player: Player)
	local authorizedChannels = {}
	for id,channel in pairs(self.channels) do
		if channel:addPlayerWithChecks(player) then
			table.insert(authorizedChannels, id)
		end
	end

	return authorizedChannels
end

function main:receiveMessage(player: Player, message: string, channelId: number)
	local channel = self.channels[channelId]
	if channel == nil then
		warn("Received message for non-existant channel")
		return
	end
	channel:receiveMessage(player, message)
end

function main:activateVoice(player: Player, channelId: number)
	local channel = self.channels[channelId]
	if channel == nil then
		warn("Received activate voice for non-existant channel")
		return
	end
	channel:activateVoice(player)
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


function main:characterAdded(input: AudioDeviceInput, character: Model)
	-- local emitter = Instance.new("AudioEmitter")
	-- emitter.Parent = character

	-- local wire = Instance.new("Wire")
	-- wire.SourceInstance = input
	-- wire.TargetInstance = emitter
	-- wire.Parent = emitter

	local emitter = Instance.new("AudioEmitter")
	emitter.Name = "emitterForListener"
	emitter.AudioInteractionGroup = "RadioSystem"
	emitter.Parent = character

	local wire = Instance.new("Wire")
	wire.SourceInstance = input
	wire.TargetInstance = emitter
	wire.Parent = emitter

	local radioEmitter = Instance.new("AudioEmitter")
	radioEmitter.Name = "RSEmitter"
	radioEmitter.Parent = character
	local radioListener = Instance.new("AudioListener")
	radioListener.Name = "RSListener"
	radioListener.AudioInteractionGroup = "RadioSystem"
	radioListener.Parent = character.HumanoidRootPart
end

function main:setupAudio()
	print("Setting up voice system")
	-- if VoiceChatService.EnableDefaultVoice == true then
	-- 	warn("VoiceChatService must have EnableDefaultVoice set to false for the voice system to work")
	-- 	return
	-- end
	-- if VoiceChatService.UseAudioApi ~= Enum.AudioApiRollout.Enabled then
	-- 	warn("VoiceChatService must have UseAudioApi set to Enabled for the voice system to work")
	-- 	return
	-- end

	local function playerAdded(player: Player)
		-- local input = Instance.new("AudioDeviceInput")
		-- input.Player = player
		-- input.Parent = player
		local input = player:WaitForChild("AudioDeviceInput")

		player.CharacterAdded:Connect(function(character)
			self:characterAdded(input, character)
		end)
		if player.Character ~= nil then self:characterAdded(input, player.Character) end
	end

	Players.PlayerAdded:Connect(playerAdded)
	for _,player in pairs(Players:GetPlayers()) do playerAdded(player) end

	print("Voice setup")
end

return main