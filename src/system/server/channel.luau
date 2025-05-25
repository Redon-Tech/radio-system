-- Redon Tech Radio System

type SystemMessage = {
	text: string,
	headerText: string?,
	backgroundColor3: Color3?,
	icon: string?,
	iconColor3: Color3?,
	iconRounded: boolean?,
	sideText: string?,
	sideAccent: Color3?,
}

local channel = {}
channel.__index = channel

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VoiceChatService = game:GetService("VoiceChatService")
local TextChatService = game:GetService("TextChatService")
local TextService = game:GetService("TextService")
local Players = game:GetService("Players")

local shared = ReplicatedStorage:WaitForChild("radioShared")
local systemSettings = require(shared:WaitForChild("settings"))

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

function channel.init(main: { any }, id: number)
	print(`Initializing Channel {id}`)
	local data = {
		main = main,
		id = id,
		name = systemSettings.channels[id].name,
		messages = {}, -- UNFILTERED
		teams = {},
		isDefaultChannel = (typeof(systemSettings.default) == "boolean" and systemSettings.default == true)
			or (typeof(systemSettings.default) == "table" and table.find(systemSettings.default, id)),
		players = {},
		activeVoice = nil,
	}
	local self = setmetatable(data, channel)

	for team, access in pairs(systemSettings.teams) do
		if
			(typeof(access) == "boolean" and access == true) or (typeof(access) == "table" and table.find(access, id))
		then
			self.teams[team] = true
		end
	end

	self.wire = Instance.new("Wire")
	self.wire.Name = self.id
	self.wire.Parent = shared:WaitForChild("wires")

	self.textChannel = Instance.new("TextChannel")
	self.textChannel.Name = self.name
	self.textChannel.Parent = TextChatService
	self.textChannel.ShouldDeliverCallback = function(...)
		return self:shouldDeliverCallback(...)
	end

	print(`Initialized Channel {id}`)
	return self
end

-- Text Features

function channel:_addMessageToHistory(type: string, data: { [any]: any })
	if systemSettings.channelHistory == 0 then
		return
	end

	table.insert(self.messages, {
		type = type,
		data = data,
	})

	if #self.messages >= systemSettings.channelHistory then
		table.remove(self.messages, #self.messages - systemSettings.channelHistory)
	end
end

function channel:shouldDeliverCallback(message: TextChatMessage, textSource: TextSource): boolean
	local player = Players:GetPlayerByUserId(textSource.UserId)
	if player == nil then
		warn(`{textSource.Name} is not a player`)
		return false
	end

	if self.players[player] == nil then
		warn(`{textSource.Name} is not apart of {self.name}`)
		return false
	end
	print(self.players[player], message.Text)
	if self.players[player] == message.Text then
		warn(`Recieved a duplicate message from {textSource.Name}, ignoring.`)
		return false
	end

	self:_addMessageToHistory("player", {
		player = {
			Name = player.Name,
			TeamColor = player.TeamColor,
			UserId = player.UserId,
		},
		message = message.Text,
	})
	self.players[player] = message.Text

	self.main.serverApi:fire("receivedClientMssage", player, message.Text, self.id)
	return true
end

function channel:receivePanic(player: Player)
	if self.players[player] == nil then
		warn(`{player.Name} is not apart of {self.name}`)
		return
	end

	local message = systemSettings.getPanicMessage(player)
	if typeof(message) ~= "string" then
		warn("getPanicMessage MUST return a string")
		return
	end

	self:_addMessageToHistory("panic", {
		player = {
			Name = player.Name,
			TeamColor = player.TeamColor,
			UserId = player.UserId,
		},
		message = message,
	})
	if systemSettings.panicBehavior:lower() ~= "all" then
		self.main.textEvents.panicButton:fireFilter(function(playerToFilter: Player)
			if self.players[playerToFilter] then
				return true
			end
			return false
		end, { channelId = self.id, player = player, message = message })
	else
		self.main.textEvents.panicButton:fireAll({ channelId = true, player = player, message = message })
	end
end

function channel:sendSystemMessage(message: SystemMessage)
	self:_addMessageToHistory("system", { message = message })
	self.main.textEvents.systemMessage:fireAll({ channelId = self.id, message = message })
end

-- Voice Features

function channel:activateVoice(player: Player)
	if self.activeVoice ~= nil and self.activeVoice ~= player then
		warn(`{player} tried to activate voice while channel is already in use, ignoring.`)
		return
	end
	if self.players[player] == nil then
		warn(`{player.Name} is not apart of {self.name}`)
		return
	end
	if VoiceChatService:IsVoiceEnabledForUserIdAsync(player.UserId) == false then
		warn(`{player.Name} does not have voice chat, ignoring.`)
		return
	end

	self.activeVoice = if self.activeVoice == player then nil else player
	self.main.voiceEvents.activateVoice:fireAll(self.id, self.activeVoice)
	self.wire.SourceInstance = if self.activeVoice ~= nil and self.activeVoice.Character ~= nil
		then self.activeVoice.Character.HumanoidRootPart:FindFirstChild("RSListener")
		else nil
	print(self.activeVoice, self.wire.SourceInstance)
end

-- Player Add/Remove

function channel:addPlayer(player: Player)
	local playerHistory = {}
	for _, message in pairs(self.messages) do
		if message.type == "player" then
			local messageData = message.data
			local filteredMessage = TextService:FilterStringAsync(messageData.message, player.UserId)
				:GetNonChatStringForBroadcastAsync()

			table.insert(playerHistory, {
				type = "player",
				data = {
					player = messageData.player,
					message = filteredMessage,
				},
			})
		else
			table.insert(playerHistory, message)
		end
	end
	self.main.textEvents.sendHistory:fire(player, self.id, playerHistory)

	if self.players[player] then
		print(`[adding,debug] {player.Name} is already apart of {self.name}`)
		return self.textChannel
	end

	self.players[player] = true
	self.textChannel:AddUserAsync(player.UserId)
	self.main.serverApi:fire("channelAddPlayer", self.id, player)
	return self.textChannel
end

function channel:removePlayer(player: Player)
	if self.players[player] == nil then
		print(`[removing,debug] {player.Name} is not apart of {self.name}`)
		return
	end

	self.players[player] = nil
	if self.activeVoice == player then
		self.activeVoice = nil
		self.main.voiceEvents.activateVoice:fireAll(self.id, self.activeVoice)
	end
	self.main.serverApi:fire("channelRemovePlayer", self.id, player)
end

function channel:addPlayerWithChecks(player: Player): boolean
	if
		(typeof(systemSettings.users[player.UserId]) == "boolean" and systemSettings.users[player.UserId] == true)
		or (typeof(systemSettings.users[player.UserId]) == "table" and table.find(
			systemSettings.users[player.UserId],
			self.id
		))
		or (typeof(systemSettings.users[player.Name]) == "boolean" and systemSettings.users[player.Name] == true)
		or (typeof(systemSettings.users[player.Name]) == "table" and table.find(
			systemSettings.users[player.Name],
			self.id
		))
		or (player.Team ~= nil and self.teams[player.Team.Name] == true)
		or self.isDefaultChannel
	then
		return self:addPlayer(player)
	end
	self:removePlayer(player)
	return false
end

return channel
