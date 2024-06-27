local TextService = game:GetService("TextService")
local util = {}

-- Below function is basically copy and pasted from Roblox core scripts for the chat
function util.getStringTextBounds(text, font, textSize, sizeBounds)
	sizeBounds = sizeBounds or Vector2.new(10000, 10000)
	return TextService:GetTextSize(text, textSize, font, sizeBounds)
end

function util.getMessageHeight(BaseMessage, BaseFrame, xSize)
	xSize = xSize or BaseFrame.AbsoluteSize.X
	local textBoundsSize = util.getStringTextBounds(BaseMessage.Text, BaseMessage.Font, BaseMessage.TextSize, Vector2.new(xSize, 1000))
	if textBoundsSize.Y ~= math.floor(textBoundsSize.Y) then
		-- some hack ig
		return textBoundsSize.Y + 1
	end
	return textBoundsSize.Y
end


return util