local ReplicatedStorage = game:GetService("ReplicatedStorage")
local shared = ReplicatedStorage:WaitForChild("radioShared")
local Fusion = require(shared:WaitForChild("Fusion"))

local New, Children, Computed, OnEvent = Fusion.New, Fusion.Children, Fusion.Computed, Fusion.OnEvent

return function(props)
	return New "TextButton" {
		Name = props.Id,
		LayoutOrder = props.Id,
		Size = UDim2.fromScale(1, 0.9),
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.fromScale(0.5, 0),

		Text = props.Text,
		FontFace = Computed(function()
			if props.activeChannel:get() == props.Id then
				return Font.new("rbxasset://fonts/families/Arial.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal)
			else
				return Font.new("rbxasset://fonts/families/Arial.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
			end
		end),
		TextScaled = true,
		TextColor3 = Color3.fromRGB(255, 255, 255),
		TextXAlignment = Enum.TextXAlignment.Center,

		[OnEvent "Activated"] = function()
			props.activeChannel:set(props.Id)
		end,

		[Children] = {
			Active = New "Frame" {
				Name = "Active",
				Size = UDim2.fromScale(0.75, 0.075),
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				BorderSizePixel = 0,
				AnchorPoint = Vector2.new(0.5, 1),
				Position = UDim2.fromScale(0.5, 1),
				ZIndex = 0,

				Visible = Computed(function()
					return props.activeChannel:get() == props.Id
				end),
			}
		}
	}
end