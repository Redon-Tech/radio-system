local ReplicatedStorage = game:GetService("ReplicatedStorage")
local shared = ReplicatedStorage:WaitForChild("radioShared")
local Fusion = require(shared:WaitForChild("Fusion"))

local New, Children, OnEvent = Fusion.New, Fusion.Children, Fusion.OnEvent

return function(props)
	return New("Frame")({
		Name = "Topbar",
		Size = UDim2.fromScale(1, 0.173),
		BackgroundColor3 = Color3.fromRGB(30, 30, 30),
		BorderSizePixel = 0,
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.fromScale(0.5, 0),

		[Children] = {
			UICorner = New("UICorner")({
				CornerRadius = UDim.new(0, 10),
			}),

			--selene: allow(mixed_table)
			Frame = New("Frame")({
				Name = "Cover",
				Size = UDim2.new(1, 0, 0, 10),
				BackgroundColor3 = Color3.fromRGB(30, 30, 30),
				BorderSizePixel = 0,
				AnchorPoint = Vector2.new(0.5, 1),
				Position = UDim2.fromScale(0.5, 1),
				ZIndex = 0,
			}),

			New("TextButton")({
				Name = "Title",
				Size = UDim2.fromScale(0.2, 1),
				BackgroundTransparency = 1,
				AnchorPoint = Vector2.new(0, 0),
				Position = UDim2.fromScale(0.01, 0),

				Text = "Radio",
				FontFace = Font.new(
					"rbxasset://fonts/families/Arial.json",
					Enum.FontWeight.Bold,
					Enum.FontStyle.Normal
				),
				TextScaled = true,
				TextColor3 = Color3.fromRGB(255, 255, 255),
				TextXAlignment = Enum.TextXAlignment.Left,

				[OnEvent("Activated")] = function()
					props.visible:set(false)
				end,
			}),

			New("TextButton")({
				Name = "Panic",
				Size = UDim2.fromScale(0.2, 0.55),
				BackgroundColor3 = Color3.fromRGB(200, 0, 0),
				AnchorPoint = Vector2.new(1, 0.5),
				Position = UDim2.fromScale(0.83, 0.5),
				AutoButtonColor = true,

				Text = "Panic",
				FontFace = Font.new(
					"rbxasset://fonts/families/Arial.json",
					Enum.FontWeight.Regular,
					Enum.FontStyle.Normal
				),
				TextScaled = true,
				TextColor3 = Color3.fromRGB(255, 255, 255),
				TextXAlignment = Enum.TextXAlignment.Center,

				[Children] = {
					UICorner = New("UICorner")({
						CornerRadius = UDim.new(0.25, 0),
					}),
				},
			}),

			New("ImageButton")({
				Name = "Chat",
				Size = UDim2.fromScale(0.05, 0.6),
				BackgroundTransparency = 1,
				AnchorPoint = Vector2.new(1, 0.5),
				Position = UDim2.fromScale(0.911, 0.5),
				Image = "rbxassetid://16516253569",
				ImageColor3 = Color3.fromRGB(255, 0, 0),
				ScaleType = Enum.ScaleType.Fit,
			}),

			New("ImageButton")({
				Name = "Mic",
				Size = UDim2.fromScale(0.05, 0.6),
				BackgroundTransparency = 1,
				AnchorPoint = Vector2.new(1, 0.5),
				Position = UDim2.fromScale(0.975, 0.5),
				Image = "rbxassetid://16516226674",
				ImageColor3 = Color3.fromRGB(255, 0, 0),
				ScaleType = Enum.ScaleType.Fit,
			}),
		},
	})
end
