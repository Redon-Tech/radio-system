local ReplicatedStorage = game:GetService("ReplicatedStorage")
local shared = ReplicatedStorage:WaitForChild("radioShared")
local Fusion = require(shared:WaitForChild("Fusion"))

local New, Children, OnEvent = Fusion.New, Fusion.Children, Fusion.OnEvent

return function(props)
	local messages
	messages = New "ScrollingFrame" {
		Name = "Messages",
		Size = UDim2.fromScale(.95, 0.606),
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.fromScale(0.5, 0.329),
		ScrollBarThickness = 5,
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		CanvasSize = UDim2.new(),

		BottomImage = "rbxasset://textures/ui/Scroll/scroll-middle.png",
		MidImage = "rbxasset://textures/ui/Scroll/scroll-middle.png",
		TopImage = "rbxasset://textures/ui/Scroll/scroll-middle.png",
		VerticalScrollBarInset = Enum.ScrollBarInset.Always,

		[OnEvent "ChildAdded"] = function()
			task.wait() -- Roblox!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
			messages.CanvasPosition = Vector2.new(0, messages.AbsoluteCanvasSize.Y)
		end,

		[Children] = {
			UIListLayout = New "UIListLayout" {
				FillDirection = Enum.FillDirection.Vertical,
				SortOrder = Enum.SortOrder.LayoutOrder,
				VerticalAlignment = Enum.VerticalAlignment.Top,
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
				Padding = UDim.new(0, 5),
			},

			props[Children]
		}
	}

	return messages
end