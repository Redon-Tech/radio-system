-- Redon Tech Radio System

local main = {}
main.__index = main

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local localPlayer = Players.LocalPlayer
local shared = ReplicatedStorage:WaitForChild("radioShared")
local Fusion = require(shared:WaitForChild("Fusion"))
local systemSettings = require(shared:WaitForChild("settings"))
local comm = require(shared:WaitForChild("comm"))
local components = script.Parent:WaitForChild("components")
local audio = require(script.Parent:WaitForChild("audio"))

local New, Children, Value, ForPairs, Observer = Fusion.New, Fusion.Children, Fusion.Value, Fusion.ForPairs, Fusion.Observer
local radioTopbar = require(components:WaitForChild("radioTopbar"))
local radioChannels = require(components:WaitForChild("radioChannels"))
local radioChannel = require(components:WaitForChild("radioChannel"))
local messages = require(components:WaitForChild("messages"))
local message = require(components:WaitForChild("message"))

local print = function(...)
	if systemSettings.debug then print(`[RTRS Client]: `, ...) end
end
local warn = function(...)
	if systemSettings.debug then warn(`[RTRS Client]: `, ...) end
end

function main.init()
	print("Initializing Client")
	local textEvents = comm.new("text")
	local voiceEvents = comm.new("voice")
	local data = {
		textEvents = {
			comm = textEvents,
			clientMessage = textEvents:remoteEvent("clientMessage"),
			systemMessage = textEvents:remoteEvent("systemMessage"),
			sendHistory = textEvents:remoteEvent("sendHistory"),
		},
		voiceEvents = {
			comm = voiceEvents,
			activateVoice = voiceEvents:remoteEvent("activateVoice")
		},
		enabled = Value(false),
		authorizedChannels = Value({}),
		activeChannel = Value(1),
		activeMessages = Value({}),
		activeVoice = Value(nil),
		activeWire = Value(nil),
		textActive = Value(false),
		voiceActive = Value(false),
	}
	local self = setmetatable(data, main)

	self:setupObservers()
	self:setupEvents()
	self.channels = self:setupChannels()
	self.mainUi = self:createUi()
	self:requestAuthorizedChannels()

	self.messageRecieved = audio.new(self, systemSettings.audio.messageRecieved, false)
	self.sideTone = audio.new(self, systemSettings.audio.sideTone, true)
	self.keyDown = audio.new(self, systemSettings.audio.keyDown, false)
	self.keyUp = audio.new(self, systemSettings.audio.keyUp, false)
	if localPlayer.Character then
		self.messageRecieved:setParent(localPlayer.Character.HumanoidRootPart)
		self.sideTone:setParent(localPlayer.Character.HumanoidRootPart)
		self.keyDown:setParent(localPlayer.Character.HumanoidRootPart)
		self.keyUp:setParent(localPlayer.Character.HumanoidRootPart)
	end

	print("Initialized Client")
	return self
end

function main:setupEvents()
	self.textEvents.clientMessage:connect(function(...)
		self:receiveClientMessage(...)
	end)

	self.textEvents.sendHistory:connect(function(channelId, history: {})
		self:recieveChannelHistory(channelId, history)
	end)

	self.voiceEvents.activateVoice:connect(function(channelId, player)
		self:activateVoice(channelId, player)
	end)

	UserInputService.InputBegan:Connect(function(input, robloxProcessedEvent)
		if robloxProcessedEvent == true then return end
		if input.KeyCode == Enum.KeyCode.T then
			self.textActive:set(not self.textActive:get())
		elseif input.KeyCode == Enum.KeyCode.Y then
			self.voiceActive:set(true)
		end
	end)

	UserInputService.InputEnded:Connect(function(input, robloxProcessedEvent)
		if robloxProcessedEvent == true then return end
		if input.KeyCode == Enum.KeyCode.Y then
			self.voiceActive:set(false)
		end
	end)

	localPlayer.Chatted:Connect(function(message)
		if self.textActive:get() then
			self.textEvents.clientMessage:fire(message, self.activeChannel:get())
		end
	end)

	localPlayer:GetPropertyChangedSignal("Team"):Connect(function()
		self:requestAuthorizedChannels()
	end)

	localPlayer.CharacterAdded:Connect(function(character)
		if self.enabled:get() == true then
			character:WaitForChild("RSEmitter")
			local wire = shared:WaitForChild("wires"):WaitForChild(self.activeChannel:get())
			wire.TargetInstance = localPlayer.Character.RSEmitter
			self.activeWire:set(wire)
		end
		self.messageRecieved:setParent(localPlayer.Character.HumanoidRootPart)
		self.sideTone:setParent(localPlayer.Character.HumanoidRootPart)
		self.keyDown:setParent(localPlayer.Character.HumanoidRootPart)
		self.keyUp:setParent(localPlayer.Character.HumanoidRootPart)
	end)
end

function main:setupObservers()
	local activeChannelObserver = Observer(self.activeChannel)
	local activeMessagesObserver = Observer(self.activeMessages)
	local textActiveObserver = Observer(self.textActive)
	local voiceActiveObserver = Observer(self.voiceActive)
	local activeVoiceObserver = Observer(self.activeVoice)
	local enabledObserver = Observer(self.enabled)

	activeChannelObserver:onChange(function()
		self:activeChannelChange()
	end)

	activeMessagesObserver:onChange(function()
		local activeMessages = self.activeMessages:get()
		if #activeMessages >= 100 then
			table.remove(activeMessages, #activeMessages - 100)
		end
	end)

	textActiveObserver:onChange(function()
		local textActive = self.textActive:get()
		self.mainUi.Container.Radio.Topbar.Chat.Image = textActive and "rbxassetid://16516225857" or "rbxassetid://16516253569"
		self.mainUi.Container.Radio.Topbar.Chat.ImageColor3 = textActive and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(255, 0, 0)
	end)

	voiceActiveObserver:onChange(function()
		local voiceActive = self.voiceActive:get()
		self.mainUi.Container.Radio.Topbar.Mic.Image = voiceActive and "rbxassetid://16516224290" or "rbxassetid://16516226674"
		self.mainUi.Container.Radio.Topbar.Mic.ImageColor3 = voiceActive and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(255, 0, 0)

		if voiceActive == true and self.enabled:get() == true then
			if self.activeVoice:get() == nil then
				self.voiceEvents.activateVoice:fire(self.activeChannel:get())
				self.keyDown:play()
			else
				self.sideTone:play()
			end
		else
			if self.activeVoice:get() == localPlayer then
				self.voiceEvents.activateVoice:fire(self.activeChannel:get())
				self.keyUp:play()
			else
				self.sideTone:stop()
			end
		end
	end)

	activeVoiceObserver:onChange(function()
		local activeVoice = self.activeVoice:get()
		if activeVoice == localPlayer then
			self.activeWire:get().TargetInstance = nil
		elseif localPlayer.Character ~= nil then
			self.activeWire:get().TargetInstance = localPlayer.Character:FindFirstChild("RSEmitter")
		end
	end)

	enabledObserver:onChange(function()
		local enabled = self.enabled:get()
		if enabled == false then
			if self.activeWire:get() ~= nil then
				self.activeWire:get().TargetInstance = nil
				self.activeWire:set(nil)
			end
		end
	end)
end

function main:setupChannels()
	print("Setting up channels")

	local channels = {}
	for id,channel in pairs(systemSettings.channels) do
		local messages = Value({})
		channels[id] = messages

		local messagesObserver = Observer(messages)
		messagesObserver:onChange(function()
			local newMessages = messages:get()
			if #newMessages >= 100 then
				table.remove(newMessages, #newMessages - 100)
			end
		end)
	end

	print("Channels set up")
	return channels
end

-- Combo Features

function main:requestAuthorizedChannels()
	local authorizedChannels = {}
	for _,channelId in pairs(self.textEvents.comm:remoteFunction("authorize")) do
		authorizedChannels[channelId] = systemSettings.channels[channelId]
	end
	self.authorizedChannels:set(authorizedChannels)

	if #authorizedChannels == 0 then
		self.enabled:set(false)
		self.mainUi.Enabled = false
	else
		self.enabled:set(true)
		self.mainUi.Enabled = true
		if authorizedChannels[self.activeChannel:get()] == nil then
			for channelId,_ in pairs(authorizedChannels) do
				self.activeChannel:set(channelId)
				break
			end
		end
	end
end

function main:activeChannelChange()
	local activeChannel = self.activeChannel:get()
	self.activeMessages:set(table.clone(self.channels[activeChannel]:get()))
	if self.activeWire:get() then self.activeWire:get().TargetInstance = nil end
	if localPlayer.Character ~= nil then
		local wire = shared:WaitForChild("wires"):WaitForChild(activeChannel)
		wire.TargetInstance = localPlayer.Character.RSEmitter
		self.activeWire:set(wire)
	end
end

-- Voice Features

function main:activateVoice(channelId: number, player: Player)
	if self.activeChannel:get() == channelId then
		self.activeVoice:set(player)
		print(self.activeWire:get().Connected)
	end
end

-- Text Features

function main:recieveChannelHistory(channelId: number, history: {})
	local channel = self.channels[channelId]
	if channel == nil then
		warn("Received history for non-existant channel")
		return
	end
	local newHistory = {}
	for _,message in pairs(history) do
		table.insert(newHistory, {
			id = #newHistory + 1,
			icon = game.Players:GetUserThumbnailAsync(message.player.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48),
			iconRounded = true,
			headerText = message.player.Name,
			text = message.message,
		})
	end
	channel:set(newHistory)
	if channelId == self.activeChannel:get() then
		self:activeChannelChange()
	end
end

function main:receiveClientMessage(channelId: number, player: Player, message: string)
	local channel = self.channels[channelId]
	if channel == nil then
		warn("Received message for non-existant channel")
		return
	end

	local channelMessages = channel:get()
	local messageData = {
		id = #channelMessages + 1,
		icon = game.Players:GetUserThumbnailAsync(player.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48),
		iconRounded = true,
		headerText = player.Name,
		text = message,
	}
	table.insert(channelMessages, messageData)
	channel:set(channelMessages)

	if self.activeChannel:get() == channelId then
		local activeMessages = self.activeMessages:get()
		table.insert(activeMessages, messageData)
		self.activeMessages:set(activeMessages)
		self.messageRecieved:play()
	end
end

-- UI

function main:createUi()
	return New "ScreenGui" {
		Name = "radioClient",
		Parent = script.Parent,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,

		[Children] = {
			Container = New "Frame" {
				Name = "Container",
				Size = UDim2.fromScale(1, 1),
				BackgroundTransparency = 1,
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(0.5, 0.5),

				[Children] = {
					UIPadding = New "UIPadding" {
						PaddingTop = UDim.new(0, 30),
						PaddingBottom = UDim.new(0, 30),
						PaddingLeft = UDim.new(0, 30),
						PaddingRight = UDim.new(0, 30),
					},

					Radio = New "Frame" {
						Name = "Radio",
						Size = UDim2.fromScale(0.35, 0.3),
						BackgroundColor3 = Color3.fromRGB(40, 40, 40),
						BorderSizePixel = 0,
						AnchorPoint = Vector2.new(0, 0),
						Position = UDim2.fromScale(0, 0),

						[Children] = {
							UICorner = New "UICorner" {
								CornerRadius = UDim.new(0, 10),
							},

							Topbar = radioTopbar {},
							Channels = radioChannels {
								[Children] = {
									ForPairs(self.authorizedChannels, function(id, channel)
										return id, radioChannel {
											Id = id,
											Text = channel.name,
											activeChannel = self.activeChannel,
										}
									end, Fusion.cleanup)
								}
							},
							Messages = messages {
								[Children] = {
									ForPairs(self.activeMessages, function(id, messageData)
										return id, message {
											id = id,
											backgroundColor3 = messageData.backgroundColor3,
											icon = messageData.icon,
											iconRounded = messageData.iconRounded,
											iconColor3 = messageData.iconColor3,
											sideText = messageData.sideText,
											sideAccent = messageData.sideAccent,
											headerText = messageData.headerText,
											text = messageData.text,
											richText = messageData.richText,
										}
									end, Fusion.cleanup)
								}
							}
						},
					},
				}
			}
		}
	}
end

return main