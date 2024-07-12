local ProximityPromptService = game:GetService("ProximityPromptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local shared = ReplicatedStorage:WaitForChild("radioShared")
local Fusion = require(shared:WaitForChild("Fusion"))
local util = require(shared:WaitForChild("util"))

local New, Children = Fusion.New, Fusion.Children

return function(props)
	local message: Frame = New("Frame")({
		Name = props.id,
		Size = UDim2.new(1, 0, 0, 50),
		BackgroundTransparency = 0,
		BackgroundColor3 = props.backgroundColor3 or Color3.fromRGB(50, 50, 50),
		BorderSizePixel = 0,
		ClipsDescendants = true,
		LayoutOrder = props.id,

		[Children] = {
			UICorner = New("UICorner")({
				CornerRadius = UDim.new(0, 10),
			}),
			Icon = if props.icon ~= nil
				then New("ImageLabel")({
					Size = UDim2.new(0, 50, 0, 50),
					Position = UDim2.new(0, 5, 0, 5),
					BackgroundTransparency = 0,
					BackgroundColor3 = Color3.fromRGB(40, 40, 40),
					Image = props.icon,
					ImageColor3 = props.iconColor3 or Color3.fromRGB(255, 255, 255),
					ScaleType = Enum.ScaleType.Fit,

					[Children] = {
						UICorner = New("UICorner")({
							CornerRadius = UDim.new(if props.iconRounded then 1 else 0, 0),
						}),
					},
				})
				else nil,
			SideText = if (props.sideText ~= nil or (props.icon == nil and props.sideText == nil))
				then New("TextLabel")({
					Size = UDim2.new(0, 50, 0, 15),
					AnchorPoint = Vector2.new(0, 0.5),
					Position = UDim2.new(0, 5, 0, 22),
					BackgroundTransparency = 1,
					Text = props.sideText or game.Lighting.TimeOfDay,
					FontFace = Font.new(
						"rbxasset://fonts/families/Arial.json",
						Enum.FontWeight.Bold,
						Enum.FontStyle.Normal
					),
					TextScaled = true,
					TextColor3 = Color3.fromRGB(178, 178, 178),
					TextXAlignment = Enum.TextXAlignment.Left,
					TextYAlignment = Enum.TextYAlignment.Top,
				})
				else nil,
			SideAccent = if props.sideAccent ~= nil
				then New("Frame")({
					Size = UDim2.fromScale(1, 1),
					AnchorPoint = Vector2.new(0.5, 0.5),
					Position = UDim2.fromScale(0.5, 0.5),
					BackgroundColor3 = props.sideAccent,

					[Children] = {
						UICorner = New("UICorner")({
							CornerRadius = UDim.new(0, 10),
						}),
						UIGradient = New("UIGradient")({
							Transparency = NumberSequence.new({
								NumberSequenceKeypoint.new(0, 0),
								NumberSequenceKeypoint.new(0.0075, 0),
								NumberSequenceKeypoint.new(0.0076, 1),
								NumberSequenceKeypoint.new(1, 1),
							}),
						}),
					},
				})
				else nil,
			HeaderText = if props.headerText ~= nil
				then New("TextLabel")({
					Size = UDim2.new(1, -65, 0, 15),
					Position = UDim2.new(0, 60, 0, 5),
					BackgroundTransparency = 1,
					Text = props.headerText,
					FontFace = Font.new(
						"rbxasset://fonts/families/Arial.json",
						Enum.FontWeight.Bold,
						Enum.FontStyle.Normal
					),
					TextScaled = true,
					TextColor3 = Color3.fromRGB(178, 178, 178),
					TextXAlignment = Enum.TextXAlignment.Left,
				})
				else nil,
			Text = New("TextLabel")({
				Name = "Text",
				Size = UDim2.new(1, -65, 1, -20),
				AnchorPoint = Vector2.new(0, 1),
				Position = UDim2.new(0, 60, 1, -5),
				BackgroundTransparency = 1,
				Text = props.text,
				FontFace = Font.new(
					"rbxasset://fonts/families/Arial.json",
					Enum.FontWeight.Regular,
					Enum.FontStyle.Normal
				),
				TextSize = 14,
				RichText = props.richText or false,
				TextColor3 = Color3.fromRGB(255, 255, 255),
				TextXAlignment = Enum.TextXAlignment.Left,
				TextWrapped = true,
			}),
		},
	})

	local connections = {}

	connections[#connections + 1] = message.AncestryChanged:Connect(function()
		if message.Parent ~= nil then
			message.Size = UDim2.new(
				1,
				0,
				0,
				math.max(60, util.getMessageHeight(message.Text, message, message.AbsoluteSize.X - 65) + 20 + (5 * 2))
			)
		end
	end)

	connections[#connections + 1] = message.Destroying:Connect(function()
		for i = 1, #connections do
			connections[i]:Disconnect()
		end
	end)

	return message
end
