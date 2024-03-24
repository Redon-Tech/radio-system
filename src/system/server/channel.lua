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
		teams = {},
		isDefaultChannel = (typeof(systemSettings.default) == "boolean" and systemSettings.default == true) or (typeof(systemSettings.default) == "table" and table.find(systemSettings.default, id)),
		players = {},
		activeVoice = nil,
	}
	local self = setmetatable(data, channel)

	for team,access in pairs(systemSettings.teams) do
		if (typeof(access) == "boolean" and access == true) or (typeof(access) == "table" and table.find(access, id)) then
			self.teams[team] = true
		end
	end

	self.wire = Instance.new("Wire")
	self.wire.Name = self.id
	self.wire.Parent = shared:WaitForChild("wires")

	print(`Initialized Channel {id}`)
	return self
end

-- Text Features

function channel:_addMessageToHistory(player: Player?, message: string)
	if systemSettings.channelHistory == 0 then return end

	if player == nil then
		player = "System"
	end

	table.insert(self.messages, {
		player = player,
		message = message,
	})

	if #self.messages >= systemSettings.channelHistory then
		table.remove(self.messages, #self.messages - systemSettings.channelHistory)
	end
end

function channel:receiveMessage(player: Player, message: string)
	if self.players[player] == nil then
		warn(`{player.Name} is not apart of {self.name}`)
		return
	end
	self:_addMessageToHistory(player, message)

	message = Chat:FilterStringAsync(message, player, player) -- Ideally we would filter with playerTo, but no
	self.main.textEvents.clientMessage:fireFilter(function(player: Player)
		if self.players[player] then
			return true
		end
		return false
	end, self.id, player, message)
end

function channel:sendSystemMessage(message: SystemMessage)
	self.main.textEvents.systemMessage:fireAll(self.id, message)
end

-- Voice Features

function channel:activateVoice(player: Player)
	if self.activeVoice ~= nil and self.activeVoice ~= player then warn(`{player} tried to activate voice while channel is already in use, ignoring.`) return end
	if self.players[player] == nil then
		warn(`{player.Name} is not apart of {self.name}`)
		return
	end

	self.activeVoice = if self.activeVoice == player then nil else player
	self.main.voiceEvents.activateVoice:fireAll(self.id, self.activeVoice)
	self.wire.SourceInstance = if self.activeVoice ~= nil and self.activeVoice.Character ~= nil then
		self.activeVoice.Character.HumanoidRootPart:FindFirstChild("RSListener") else nil
	print(self.activeVoice, self.wire.SourceInstance)
end

-- Player Add/Remove

function channel:addPlayer(player: Player)
	local playerHistory = {}
	for _,message in pairs(self.messages) do
		local success, filteredMessage = pcall(function()
			return Chat:FilterStringAsync(message.message, message.player, message.player)
		end)
		if success == false then
			warn("Could not filter\n", filteredMessage)
			filteredMessage = Chat:FilterStringForBroadcast(message.message, player)
		end
		table.insert(playerHistory, {
			player = message.player,
			message = filteredMessage,
		})
	end
	self.main.textEvents.sendHistory:fire(player, self.id, playerHistory)

	if self.players[player] then
		print(`[adding,debug] {player.Name} is already apart of {self.name}`)
		return
	end

	self.players[player] = true
	self.main.serverApi:fire("channelAddPlayer", self.id, player)
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
	if (typeof(systemSettings.users[player.UserId]) == "boolean" and systemSettings.users[player.UserId] == true)
	or (typeof(systemSettings.users[player.UserId]) == "table" and table.find(systemSettings.users[player.UserId], self.id))
	or (typeof(systemSettings.users[player.Name]) == "boolean" and systemSettings.users[player.Name] == true)
	or (typeof(systemSettings.users[player.Name]) == "table" and table.find(systemSettings.users[player.Name], self.id))
	or (player.Team ~= nil and self.teams[player.Team.Name] == true)
	or (self.isDefaultChannel)
	then
		self:addPlayer(player)
		return true
	end
	self:removePlayer(player)
	return false
end

return channel