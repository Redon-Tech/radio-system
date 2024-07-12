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
local settings = script.Parent.settings
local systemSettings = require(settings)

print(`\n		[RTRS]: Initializing System\n		Version: {systemSettings.v}\n		Debug Mode: {systemSettings.debug}`)

local sharedFolder = script.shared
sharedFolder.Name = "radioShared"
sharedFolder.Parent = game.ReplicatedStorage

local wireFolder = Instance.new("Folder")
wireFolder.Name = "wires"
wireFolder.Parent = sharedFolder

local effectFolder = sharedFolder:WaitForChild("effects")
local audioDistortion = effectFolder:WaitForChild("AudioDistortion")
local audioEqualizer = effectFolder:WaitForChild("AudioEqualizer")
audioDistortion.Wire.SourceInstance = audioEqualizer
audioDistortion.Wire.TargetInstance = audioDistortion

settings.Parent = sharedFolder

local function initClient(Player: Player)
	local PlayerGui = Player:WaitForChild("PlayerGui")
	if PlayerGui:FindFirstChild("radioClient") then
		return
	end

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
radioClient.Parent = game.StarterPlayer.StarterPlayerScripts

-- for _,player:Player in ipairs(Players:GetPlayers()) do
-- 	initClient(player)
-- end

print("\n		[RTRS]: Initialized")
