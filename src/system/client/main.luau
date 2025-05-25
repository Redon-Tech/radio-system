-- Redon Tech Radio System

local main = {}
main.__index = main

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local TextChatService = game:GetService("TextChatService")

local localPlayer = Players.LocalPlayer
local shared = ReplicatedStorage:WaitForChild("radioShared")
local effects = shared:WaitForChild("effects")
local audioDistortion = effects:WaitForChild("AudioDistortion")
local audioEqualizer = effects:WaitForChild("AudioEqualizer")
local Fusion = require(shared:WaitForChild("Fusion"))
local systemSettings = require(shared:WaitForChild("settings"))
local comm = require(shared:WaitForChild("comm"))
local components = script.Parent:WaitForChild("components")
local audio = require(script.Parent:WaitForChild("audio"))

local New, Children, Value, ForPairs, Observer, OnEvent =
	Fusion.New, Fusion.Children, Fusion.Value, Fusion.ForPairs, Fusion.Observer, Fusion.OnEvent
local radioTopbarComponent = require(components:WaitForChild("radioTopbar"))
local radioChannelsComponent = require(components:WaitForChild("radioChannels"))
local radioChannelComponent = require(components:WaitForChild("radioChannel"))
local messagesComponent = require(components:WaitForChild("messages"))
local messageComponent = require(components:WaitForChild("message"))

local print = function(...)
	if systemSettings.debug then
		print(`[RTRS Client]: `, ...)
	end
end
local warn = function(...)
	if systemSettings.debug then
		warn(`[RTRS Client]: `, ...)
	end
end

function main.init()
	print("Initializing Client")
	-- We run this before everything else to prevent errors :D
	if TextChatService.ChatVersion == Enum.ChatVersion.TextChatService then
		local windowConfig = TextChatService:FindFirstChildOfClass("ChatWindowConfiguration")
		windowConfig:SetAttribute("defaultState", windowConfig.Enabled)
	end

	local textEvents = comm.new("text")
	local voiceEvents = comm.new("voice")
	local apiEvents = comm.new("api")
	local data = {
		textEvents = {
			comm = textEvents,
			systemMessage = textEvents:remoteEvent("systemMessage"),
			panicButton = textEvents:remoteEvent("panicButton"),
			sendHistory = textEvents:remoteEvent("sendHistory"),
		},
		voiceEvents = {
			comm = voiceEvents,
			activateVoice = voiceEvents:remoteEvent("activateVoice"),
		},
		apiEvents = apiEvents,
		clientApi = apiEvents:bindableEvent("clientApi"),
		enabled = Value(false),
		visible = Value(nil),
		authorizedChannels = Value({}),
		activeChannel = Value(1),
		activeMessages = Value({}),
		activeVoice = Value(nil),
		activeWire = Value(nil),
		textActive = Value(false),
		voiceActive = Value(false),
		channelConnections = {},
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
	self.panic = audio.new(self, systemSettings.audio.panic, false)
	if localPlayer.Character then
		self.messageRecieved:setParent(localPlayer.Character.HumanoidRootPart)
		self.sideTone:setParent(localPlayer.Character.HumanoidRootPart)
		self.keyDown:setParent(localPlayer.Character.HumanoidRootPart)
		self.keyUp:setParent(localPlayer.Character.HumanoidRootPart)
		self.panic:setParent(localPlayer.Character.HumanoidRootPart)
	end

	print("Initialized Client")
	return self
end

function main:setupEvents()
	self.textEvents.systemMessage:connect(function(...)
		self:receiveMessage(...)
		self.clientApi:fire("systemMessageRecieved", ...)
	end)

	self.textEvents.sendHistory:connect(function(channelId, history: {})
		self:recieveChannelHistory(channelId, history)
		self.clientApi:fire("messageHistoryRecieved", channelId, history)
	end)

	self.textEvents.panicButton:connect(function(...)
		self:recievePanicButton(...)
		self.clientApi:fire("panicButtonActivated", ...)
	end)

	self.voiceEvents.activateVoice:connect(function(channelId, player)
		self:activateVoice(channelId, player)
		self.clientApi:fire("voiceRecieve", channelId, player)
	end)

	self.clientApiFunction = self.apiEvents:bindableFunction("clientApiFunction", function(message: string)
		if message == "getEnabled" then
			return self.enabled:get()
		end
		return
	end)

	self.clientApi:connect(function(message: string, ...)
		if message == "setEnabled" and typeof(...) == "boolean" then
			self.enabled:set(...)
		end
	end)

	UserInputService.InputBegan:Connect(function(input, robloxProcessedEvent)
		if robloxProcessedEvent == true then
			return
		end
		if input.KeyCode == systemSettings.keybinds.text then
			self.textActive:set(not self.textActive:get())
		elseif input.KeyCode == systemSettings.keybinds.mic then
			self.voiceActive:set(true)
		elseif input.KeyCode == systemSettings.keybinds.hide then
			self.visible:set(not self.visible:get())
		end
	end)

	UserInputService.InputEnded:Connect(function(input, robloxProcessedEvent)
		if robloxProcessedEvent == true then
			return
		end
		if input.KeyCode == systemSettings.keybinds.mic then
			self.voiceActive:set(false)
		end
	end)

	localPlayer:GetPropertyChangedSignal("Team"):Connect(function()
		self:requestAuthorizedChannels()
	end)

	localPlayer.CharacterAdded:Connect(function(character)
		print("Character Added")
		character:WaitForChild("HumanoidRootPart")
		if self.enabled:get() == true then
			print("Radio Enabled")
			local emitterWire = character:WaitForChild("RSEmitter"):WaitForChild("Wire")
			emitterWire.SourceInstance = audioDistortion
			local wire = shared:WaitForChild("wires"):WaitForChild(self.activeChannel:get())
			wire.TargetInstance = audioEqualizer
			self.activeWire:set(wire)
		end
		self.messageRecieved:setParent(character.HumanoidRootPart)
		self.sideTone:setParent(character.HumanoidRootPart)
		self.keyDown:setParent(character.HumanoidRootPart)
		self.keyUp:setParent(character.HumanoidRootPart)
		self.panic:setParent(character.HumanoidRootPart)
	end)
end

function main:setupObservers()
	local activeChannelObserver = Observer(self.activeChannel)
	local activeMessagesObserver = Observer(self.activeMessages)
	local textActiveObserver = Observer(self.textActive)
	local voiceActiveObserver = Observer(self.voiceActive)
	local activeVoiceObserver = Observer(self.activeVoice)
	local enabledObserver = Observer(self.enabled)
	local visibleObserver = Observer(self.visible)

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
		self.clientApi:fire("textActivateChange", textActive)
		self.mainUi.Container.Radio.Topbar.Chat.Image = textActive and "rbxassetid://16516225857"
			or "rbxassetid://16516253569"
		self.mainUi.Container.Radio.Topbar.Chat.ImageColor3 = textActive and Color3.fromRGB(255, 255, 255)
			or Color3.fromRGB(255, 0, 0)

		if textActive == true and self.enabled:get() == true then
			local channel = self.authorizedChannels:get()[self.activeChannel:get()]
			TextChatService:FindFirstChildOfClass("ChatInputBarConfiguration").TargetTextChannel = channel
		else
			TextChatService:FindFirstChildOfClass("ChatInputBarConfiguration").TargetTextChannel =
				TextChatService:FindFirstChild(systemSettings.defaultTextChannel, true)
		end
	end)

	voiceActiveObserver:onChange(function()
		local voiceActive = self.voiceActive:get()
		self.mainUi.Container.Radio.Topbar.Mic.Image = voiceActive and "rbxassetid://16516224290"
			or "rbxassetid://16516226674"
		self.mainUi.Container.Radio.Topbar.Mic.ImageColor3 = voiceActive and Color3.fromRGB(255, 255, 255)
			or Color3.fromRGB(255, 0, 0)
		self.clientApi:fire("voiceActivateChange", voiceActive)

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
			end
			self.sideTone:stop()
		end
	end)

	activeVoiceObserver:onChange(function()
		local activeVoice = self.activeVoice:get()
		if activeVoice == localPlayer then
			self.activeWire:get().TargetInstance = nil
		elseif localPlayer.Character ~= nil then
			self.activeWire:get().TargetInstance = audioEqualizer
		end
	end)

	local function setVisible(forceTo: boolean?)
		local visible = if forceTo ~= nil then forceTo else self.visible:get()
		local enabled = self.enabled:get()

		self.mainUi.Container.Radio.Visible = if enabled == true then visible else false
		self.mainUi.Container.ShowRadio.Visible = if enabled == true then not visible else false
		self.mainUi.DisplayOrder = if visible == true then 0 else 999
	end
	visibleObserver:onChange(setVisible)

	enabledObserver:onChange(function()
		local enabled = self.enabled:get()
		setVisible(enabled)
		self.visible:set(enabled)

		if enabled == true then
			if systemSettings.overrideWindowEnabled == true then
				if TextChatService.ChatVersion == Enum.ChatVersion.TextChatService then
					TextChatService:FindFirstChildOfClass("ChatWindowConfiguration").Enabled = false
				end
			end
		elseif enabled == false then
			TextChatService:FindFirstChildOfClass("ChatInputBarConfiguration").TargetTextChannel =
				TextChatService:FindFirstChild(systemSettings.defaultTextChannel, true)
			if systemSettings.overrideWindowEnabled == true then
				if TextChatService.ChatVersion == Enum.ChatVersion.TextChatService then
					local windowConfig = TextChatService:FindFirstChildOfClass("ChatWindowConfiguration")
					windowConfig.Enabled = windowConfig:GetAttribute("defaultState")
				end
			end

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
	for id, _ in pairs(systemSettings.channels) do
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
	-- clear current messages and authorized channels
	self.activeMessages:set({})
	self.authorizedChannels:set({})
	self.channels = self:setupChannels()
	for _, connection in self.channelConnections do
		connection:Disconnect()
	end

	local success, error = pcall(function()
		local authorizedChannels = {}
		local numberOfChannels = 0
		for channelId, textChannel: TextChannel in pairs(self.textEvents.comm:remoteFunction("authorize")) do
			authorizedChannels[channelId] = textChannel
			numberOfChannels += 1

			table.insert(
				self.channelConnections,
				textChannel.MessageReceived:Connect(function(message: TextChatMessage)
					local player = Players:GetPlayerByUserId(message.TextSource.UserId)
					self:receiveClientMessage({
						channelId = channelId,
						player = player,
						message = message.Text,
					})
					self.clientApi:fire("clientMessageRecieved", channelId, player, message.Text)
				end)
			)
		end
		self.authorizedChannels:set(authorizedChannels)

		if numberOfChannels == 0 then
			self.enabled:set(false)
		else
			self.enabled:set(true)
			if authorizedChannels[self.activeChannel:get()] == nil then
				for channelId, _ in pairs(authorizedChannels) do
					self.activeChannel:set(channelId)
					break
				end
			else
				self:activeChannelChange()
			end
		end
	end)

	if success == false then
		warn(`Failed to retrieve authorized channels\n{error}`)
		self.enabled:set(false)
	end
end

function main:activeChannelChange()
	local activeChannel = self.activeChannel:get()
	local channelMessages = self.channels[activeChannel]:get()
	self.activeMessages:set(table.clone(channelMessages))
	if self.textActive:get() == true then
		local channel = self.authorizedChannels:get()[activeChannel]
		TextChatService:FindFirstChildOfClass("ChatInputBarConfiguration").TargetTextChannel = channel
	end
	if self.activeWire:get() then
		self.activeWire:get().TargetInstance = nil
	end
	if localPlayer.Character ~= nil then
		local wire = shared:WaitForChild("wires"):WaitForChild(activeChannel)
		wire.TargetInstance = audioEqualizer
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

	print("recievingHistory", history)
	for _, message in pairs(history) do
		if message.type == "player" then
			self:receiveClientMessage({
				channelId = channelId,
				player = message.data.player,
				message = message.data.message,
			})
		elseif message.type == "system" then
			self:receiveMessage({ channelId = channelId, message = message.data.message })
		elseif message.type == "panic" then
			self:recievePanicButton({
				channelId = channelId,
				player = message.data.player,
				message = message.data.message,
				noAudio = true,
			})
		end
	end
	if channelId == self.activeChannel:get() then
		self:activeChannelChange()
	end
end

function main:receiveClientMessage(data: { channelId: number, player: Player, message: string })
	local channelId = data.channelId
	local player = data.player
	local message = data.message

	local channel = self.channels[channelId]
	if channel == nil then
		warn("Received message for non-existant channel")
		return
	end

	local channelMessages = channel:get()
	local messageData = {
		id = #channelMessages + 1,
		icon = game.Players:GetUserThumbnailAsync(
			player.UserId,
			Enum.ThumbnailType.HeadShot,
			Enum.ThumbnailSize.Size48x48
		),
		iconRounded = true,
		headerText = player.Name,
		text = message,
		sideAccent = player.TeamColor.Color,
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

function main:receiveMessage(data: {
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
	},
	playPanicSound: boolean?,
})
	local channelId = data.channelId
	local message = data.message
	local playPanicSound = data.playPanicSound

	local channel = self.channels[channelId]
	if channel == nil then
		warn("Received message for non-existant channel")
		return
	end

	local channelMessages = channel:get()
	local messageData = {
		id = #channelMessages + 1,
	}
	for i, v in pairs(message) do
		messageData[i] = v
	end
	table.insert(channelMessages, messageData)
	channel:set(channelMessages)

	if self.activeChannel:get() == channelId then
		local activeMessages = self.activeMessages:get()
		table.insert(activeMessages, messageData)
		self.activeMessages:set(activeMessages)
		if playPanicSound == true then
			self.panic:play()
		else
			self.messageRecieved:play()
		end
	end
end

function main:recievePanicButton(
	data: { channelId: number | boolean, player: Player, message: string, noAudio: boolean? }
)
	local channelId = data.channelId
	local player = data.player
	local message = data.message
	local noAudio = data.noAudio

	print("panic", channelId, player, message, noAudio)
	local panicMessage = {
		text = message,
		headerText = player.Name,
		backgroundColor3 = Color3.fromRGB(175, 60, 60),
		icon = game.Players:GetUserThumbnailAsync(
			player.UserId,
			Enum.ThumbnailType.HeadShot,
			Enum.ThumbnailSize.Size48x48
		),
		iconRounded = true,
		sideAccent = player.TeamColor.Color,
	}

	if channelId == true then
		for id, _ in pairs(self.authorizedChannels:get()) do
			self:receiveMessage({
				channelId = id,
				message = panicMessage,
				playPanicSound = if noAudio == true then false else true,
			})
		end
	else
		self:receiveMessage({
			channelId = channelId,
			message = panicMessage,
			playPanicSound = if noAudio == true then false else true,
		})
	end
end

-- UI
local anchorPoint = Vector2.new(0, 0)
local position = UDim2.fromScale(0, 0)
if systemSettings.uiPosition:lower() == "topright" then
	anchorPoint = Vector2.new(1, 0)
	position = UDim2.fromScale(1, 0)
elseif systemSettings.uiPosition:lower() == "bottomleft" then
	anchorPoint = Vector2.new(0, 1)
	position = UDim2.fromScale(0, 1)
elseif systemSettings.uiPosition:lower() == "bottomright" then
	anchorPoint = Vector2.new(1, 1)
	position = UDim2.fromScale(1, 1)
elseif typeof(systemSettings.overrideUiPosition) == "UDim2" then
	position = systemSettings.overrideUiPosition
end

function main:createUi()
	local ui = New("ScreenGui")({
		Name = "radioClient",
		Parent = localPlayer:WaitForChild("PlayerGui"),
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,

		[Children] = {
			Container = New("Frame")({
				Name = "Container",
				Size = UDim2.fromScale(1, 1),
				BackgroundTransparency = 1,
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(0.5, 0.5),

				[Children] = {
					UIPadding = New("UIPadding")({
						PaddingTop = UDim.new(0, 5 + systemSettings.additionalTopPadding),
						PaddingBottom = UDim.new(0, 5),
						PaddingLeft = UDim.new(0, 8),
						PaddingRight = UDim.new(0, 8),
					}),

					ShowRadio = New("TextButton")({
						Name = "ShowRadio",
						Size = UDim2.fromScale(0.084, 0.037),
						BackgroundColor3 = Color3.fromRGB(40, 40, 40),
						AnchorPoint = Vector2.new(0, 1),
						Position = UDim2.fromScale(0, 1),
						Visible = false,

						Text = "Show Radio",
						FontFace = Font.new(
							"rbxasset://fonts/families/Arial.json",
							Enum.FontWeight.Bold,
							Enum.FontStyle.Normal
						),
						TextScaled = true,
						TextColor3 = Color3.fromRGB(255, 255, 255),
						TextXAlignment = Enum.TextXAlignment.Center,

						[OnEvent("Activated")] = function()
							self.visible:set(true)
						end,

						[Children] = {
							UICorner = New("UICorner")({
								CornerRadius = UDim.new(0, 10),
							}),

							UISizeConstraint = New("UISizeConstraint")({
								MaxSize = Vector2.new(200, 50),
							}),

							UIPadding = New("UIPadding")({
								PaddingTop = UDim.new(0, 3),
								PaddingBottom = UDim.new(0, 3),
								PaddingLeft = UDim.new(0, 3),
								PaddingRight = UDim.new(0, 3),
							}),
						},
					}),

					Radio = New("Frame")({
						Name = "Radio",
						Size = systemSettings.uiSize,
						BackgroundColor3 = Color3.fromRGB(40, 40, 40),
						BorderSizePixel = 0,
						AnchorPoint = anchorPoint,
						Position = position,
						Visible = false,

						[Children] = {
							UICorner = New("UICorner")({
								CornerRadius = UDim.new(0, 10),
							}),

							UISizeConstraint = New("UISizeConstraint")({
								MaxSize = systemSettings.uiMaxSize,
							}),

							Topbar = radioTopbarComponent({
								visible = self.visible,
							}),
							Channels = radioChannelsComponent({
								[Children] = {
									ForPairs(self.authorizedChannels, function(id: number, channel: TextChannel)
										return id,
											radioChannelComponent({
												Id = id,
												Text = channel.Name,
												activeChannel = self.activeChannel,
											})
									end, Fusion.cleanup),
								},
							}),
							Messages = messagesComponent({
								[Children] = {
									ForPairs(self.activeMessages, function(id, messageData)
										return id,
											messageComponent({
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
											})
									end, Fusion.cleanup),
								},
							}),
						},
					}),
				},
			}),
		},
	})

	ui.Container.Radio.Topbar.Chat.MouseButton1Click:Connect(function()
		self.textActive:set(not self.textActive:get())
	end)

	ui.Container.Radio.Topbar.Mic.MouseButton1Down:Connect(function()
		self.voiceActive:set(true)
	end)

	ui.Container.Radio.Topbar.Mic.MouseButton1Up:Connect(function()
		self.voiceActive:set(false)
	end)

	ui.Container.Radio.Topbar.Panic.MouseButton1Click:Connect(function()
		self.textEvents.panicButton:fire(self.activeChannel:get())
	end)

	if systemSettings.panicButtonEnabled == false then
		ui.Container.Radio.Topbar.Panic.Visible = false
	end

	return ui
end

return main
