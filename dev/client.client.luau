local localPlayer = game.Players.LocalPlayer
local ScreenGui = localPlayer:WaitForChild("PlayerGui"):WaitForChild("ScreenGui")
local template = ScreenGui:WaitForChild("Frame"):WaitForChild("template")
template.Visible = false

for i,v in pairs(game.Teams:GetChildren()) do
	local clone = template:Clone()
	clone.Name = v.Name
	clone.Parent = template.Parent
	clone.Visible = true
	clone.Text = v.Name

	clone.MouseButton1Click:Connect(function()
		game.ReplicatedStorage.RemoteEvent:FireServer(v.Name)
	end)
end