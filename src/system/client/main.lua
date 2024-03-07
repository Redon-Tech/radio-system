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
	print("Initializing Radio System")
	local textEvents = comm.new("text")
	local voiceEvents = comm.new("voice")
	local data = {
		textEvents = {
			clientMessage = textEvents:remoteEvent("clientMessage"),
			systemMessage = textEvents:remoteEvent("systemMessage"),
		},
		activeChannel = Value(1),
		activeMessages = Value({}),
		textActive = Value(false),
		voiceActive = Value(false),
	}
	local self = setmetatable(data, main)

	self:setupObservers()
	self.channels = self:setupChannels()
	self.mainUi = self:createUi()

	self.textEvents.clientMessage:connect(function(...)
		self:receiveClientMessage(...)
	end)

	UserInputService.InputBegan:Connect(function(input)
		if input.KeyCode == Enum.KeyCode.T then
			self.textActive:set(not self.textActive:get())
		end
	end)

	localPlayer.Chatted:Connect(function(message)
		if self.textActive:get() then
			self.textEvents.clientMessage:fire(message, self.activeChannel:get())
		end
	end)

	print("Initialized Radio System")
	return self
end

function main:setupObservers()
	local activeChannelObserver = Observer(self.activeChannel)
	local activeMessagesObserver = Observer(self.activeMessages)
	local textActiveObserver = Observer(self.textActive)
	local voiceActiveObserver = Observer(self.voiceActive)

	activeChannelObserver:onChange(function()
		local activeChannel = self.activeChannel:get()
		self.activeMessages:set(table.clone(self.channels[activeChannel]:get()))
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
	end
end

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
									ForPairs(systemSettings.channels, function(id, channel)
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