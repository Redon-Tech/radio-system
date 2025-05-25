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

local settings = script.Parent.settings
local systemSettings = require(settings)

print(`\n		[RTRS]: Initializing System\n		Version: {systemSettings.v}\n		Debug Mode: {systemSettings.debug}`)

if game.ReplicatedStorage:FindFirstChild("radioShared") then
	game.ReplicatedStorage:FindFirstChild("radioShared"):Destroy()
end
local sharedFolder = script.shared
sharedFolder.Name = "radioShared"
sharedFolder.Parent = game.ReplicatedStorage

local wireFolder = Instance.new("Folder")
wireFolder.Name = "wires"
wireFolder.Parent = sharedFolder

local effectFolder = sharedFolder:WaitForChild("effects")
local audioEqualizer = effectFolder:WaitForChild("1 - Equalizer")
local audioDistortion = effectFolder:WaitForChild("2 - Distortion")
local audioFader = effectFolder:WaitForChild("3 - Fader")
audioDistortion.Wire.SourceInstance = audioEqualizer
audioDistortion.Wire.TargetInstance = audioDistortion
audioFader.Wire.SourceInstance = audioDistortion
audioFader.Wire.TargetInstance = audioFader

settings.Parent = sharedFolder

local comm = require(sharedFolder:WaitForChild("comm"))
comm.setup()

local main = require(script:WaitForChild("server"):WaitForChild("main"))
main.init()

-- Startup --
local radioClient = script.client:Clone()
radioClient.Name = "radioClient"
radioClient.Parent = game.StarterPlayer.StarterPlayerScripts

print("\n		[RTRS]: Initialized")
