local ReplicatedStorage = game:GetService("ReplicatedStorage")
local shared = ReplicatedStorage:WaitForChild("radioShared")
local Fusion = require(shared:WaitForChild("Fusion"))

local New, Children, OnEvent = Fusion.New, Fusion.Children, Fusion.OnEvent

return function(props)
	local frame: Frame?
	frame = New "Frame" {
		Name = "Channels",
		Size = UDim2.fromScale(1, 0.087),
		BackgroundColor3 = Color3.fromRGB(35, 35, 35),
		BorderSizePixel = 0,
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.fromScale(0.5, 0.173),

		[OnEvent "ChildAdded"] = function(child: TextButton)
			if child:IsA("TextButton") then
				for _,v in pairs(frame:GetChildren()) do
					if v:IsA("TextButton") then
						v.Size = UDim2.fromScale(1 / (#frame:GetChildren()-1), 1)
					end
				end
			end
		end,

		[Children] = {
			UIListLayout = New "UIListLayout" {
				FillDirection = Enum.FillDirection.Horizontal,
				SortOrder = Enum.SortOrder.LayoutOrder,
				Padding = UDim.new(0, 0),
			},

			props[Children]
		}
	}

	for _,v in pairs(frame:GetChildren()) do
		if v:IsA("TextButton") then
			v.Size = UDim2.fromScale((1 / (#frame:GetChildren()-1)), 1)
		end
	end

	return frame
end