-- Redon Tech Radio System

local main = script.Parent:WaitForChild("main")

local success, result = pcall(function()
	return require(main).init()
end)

if not success then
	warn("[RTRS Client]: Client could not start\n", result, "\nTraceback:\n", debug.traceback())
end