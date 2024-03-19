-- Redon Tech Radio Systen

local audio = {}
audio.__index = audio

function audio.new(main: {any}, assetId: string|boolean?, looped: boolean)
	local data = {
		main = main,
		sound = Instance.new("Sound"),
		isEnabled = typeof(assetId) == "string",
	}
	local self = setmetatable(data, audio)

	self.sound.SoundId = assetId
	self.sound.Looped = looped

	return self
end

function audio:play()
	if self.isEnabled == false then return end

	self.sound:Play()
end

function audio:stop()
	if self.isEnabled == false then return end

	self.sound:Stop()
end

function audio:setParent(parent: Instance)
	self.sound.Parent = parent
end

return audio