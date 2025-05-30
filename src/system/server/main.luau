-- Redon Tech Radio System

local main = {}
main.__index = main

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local shared = ReplicatedStorage:WaitForChild("radioShared")
local systemSettings = require(shared:WaitForChild("settings"))
local comm = require(shared:WaitForChild("comm"))

local print = function(...)
	if systemSettings.debug then
		print(`[RTRS Server]: `, ...)
	end
end
local warn = function(...)
	if systemSettings.debug then
		warn(`[RTRS Server]: `, ...)
	end
end

function main.init()
	print("Initializing Server")
	local textEvents = comm.new("text")
	local voiceEvents = comm.new("voice")
	local apiEvents = comm.new("api")
	local data = {
		textEvents = {
			systemMessage = textEvents:remoteEvent("systemMessage"),
			panicButton = textEvents:remoteEvent("panicButton"),
			sendHistory = textEvents:remoteEvent("sendHistory"),
		},
		voiceEvents = {
			activateVoice = voiceEvents:remoteEvent("activateVoice"),
		},
		apiEvents = apiEvents,
		serverApi = apiEvents:bindableEvent("serverApi"),
		panicCooldowns = {},
	}
	local self = setmetatable(data, main)

	self.channels = self:setupChannels()
	self:setupAudio()

	self.textEvents.authorize = textEvents:remoteFunction("authorize", self, "authorizeClient")
	self.textEvents.panicButton:connect(function(...)
		self:receivePanic(...)
	end)

	self.voiceEvents.activateVoice:connect(function(...)
		self:activateVoice(...)
		self.serverApi:fire("receivedActivateVoice", ...)
	end)

	self.serverApi:connect(function(...)
		self:serverApiEvent(...)
	end)

	print("Initialized Server")
	return self
end

function main:authorizeClient(player: Player)
	local authorizedChannels = {}
	for id, channel in pairs(self.channels) do
		local textChannel = channel:addPlayerWithChecks(player)
		if textChannel ~= false then
			authorizedChannels[id] = textChannel
		end
	end
	self.serverApi:fire("authorizedClient", player, authorizedChannels)

	return authorizedChannels
end

function main:activateVoice(player: Player, channelId: number)
	local channel = self.channels[channelId]
	if channel == nil then
		warn("Received activate voice for non-existant channel")
		return
	end
	channel:activateVoice(player)
end

function main:receivePanic(player: Player, channelId: number)
	if systemSettings.panicButtonEnabled ~= true then
		warn("Panic button is not enabled")
		return
	end

	if
		self.panicCooldowns[player.UserId] ~= nil
		and (os.time() - self.panicCooldowns[player.UserId]) < systemSettings.panicCooldown
	then
		warn("Panic button on cooldown for player")
		return
	end
	self.panicCooldowns[player.UserId] = os.time()

	local channel = self.channels[channelId]
	if channel == nil then
		warn("Received panic for non-existant channel")
		return
	end
	channel:receivePanic(player)
	self.serverApi:fire("receivedPanic", player, channelId)
end

function main:setupChannels()
	print("Setting up channels")

	local channels = {}
	for id, _ in pairs(systemSettings.channels) do
		channels[id] = require(script.Parent:WaitForChild("channel")).init(self, id)
	end

	print("Channels set up")
	return channels
end

function main:characterAdded(input: AudioDeviceInput, character: Model)
	character.ModelStreamingMode = Enum.ModelStreamingMode.Persistent
	local rootPart = character:WaitForChild("HumanoidRootPart")

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
	local wire2 = Instance.new("Wire")
	wire2.TargetInstance = radioEmitter
	wire2.Parent = radioEmitter
	local radioListener = Instance.new("AudioListener")
	radioListener.Name = "RSListener"
	radioListener.AudioInteractionGroup = "RadioSystem"
	radioListener.Parent = rootPart
end

function main:setupAudio()
	print("Setting up voice system")

	local function playerAdded(player: Player)
		local input = player:WaitForChild("AudioDeviceInput")

		player.CharacterAdded:Connect(function(character)
			self:characterAdded(input, character)
		end)
		if player.Character ~= nil then
			self:characterAdded(input, player.Character)
		end
	end

	Players.PlayerAdded:Connect(playerAdded)
	for _, player in pairs(Players:GetPlayers()) do
		playerAdded(player)
	end

	print("Voice setup")
end

function main:serverApiEvent(message: string, ...)
	if message == "createSystemMessage" then
		local channelId: number, data: {} = ...
		local channel = self.channels[channelId]
		if channel == nil then
			warn("Received message for non-existant channel")
			return
		end

		channel:sendSystemMessage(data)
	elseif message == "activatePlayersVoice" then
		local channelId: number, player: Player = ...
		local channel = self.channels[channelId]
		if channel == nil then
			warn("Received message for non-existant channel")
			return
		end

		channel:activateVoice(player)
	end
end

return main
