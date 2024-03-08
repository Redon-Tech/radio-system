--[[
	 _____               _                     _______                 _
	|  __ \             | |                   |__   __|               | |
	| |__) |   ___    __| |   ___    _ __        | |      ___    ___  | |__
	|  _  /   / _ \  / _  |  / _ \  |  _ \       | |     / _ \  / __| |  _ \
	| | \ \  |  __/ | (_| | | (_) | | | | |      | |    |  __/ | (__  | | | |
	|_|  \_\  \___|  \__,_|  \___/  |_| |_|      |_|     \___|  \___| |_| |_|
	Radio System
	Loader
--]]

local Players = game:GetService("Players")


local sharedFolder = script.shared
sharedFolder.Name = "radioShared"
sharedFolder.Parent = game.ReplicatedStorage

local settings = script.Parent.settings
settings.Parent = sharedFolder

local function initClient(Player: Player)
	local PlayerGui = Player:WaitForChild("PlayerGui")
	if PlayerGui:FindFirstChild("radioClient") then return end

	local radioClient = script.client:Clone()
	radioClient.Name = "radioClient"
	radioClient.Parent = PlayerGui
end

local comm = require(sharedFolder:WaitForChild("comm"))
comm.setup()

local main = require(script:WaitForChild("server"):WaitForChild("main"))
main.init()

-- Startup --
local radioClient = script.client:Clone()
radioClient.Name = "radioClient"
radioClient.Parent = game.StarterGui

for _,player:Player in ipairs(Players:GetPlayers()) do
	initClient(player)
end
