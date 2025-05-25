-- Redon Tech Radio System

local comm = {}
comm.__index = comm

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local shared = ReplicatedStorage:WaitForChild("radioShared")

local systemSettings = require(shared:WaitForChild("settings"))
local isServer = RunService:IsServer()

local print = function(...)
	if systemSettings.debug then
		print(`[RTRS {if isServer then "Server" else "Client"}]: `, ...)
	end
end
local warn = function(...)
	if systemSettings.debug then
		warn(`[RTRS {if isServer then "Server" else "Client"}]: `, ...)
	end
end

function comm.new(namespace: string)
	print(`Initializing Comm {namespace}`)
	local data = {
		_commFolder = shared:WaitForChild("commEvents"),
		namespace = namespace,
	}
	local self = setmetatable(data, comm)

	if isServer == true then
		self.folder = self._commFolder:FindFirstChild(namespace)
		if self.folder == nil then
			self.folder = Instance.new("Folder")
			self.folder.Name = namespace
			self.folder.Parent = self._commFolder
		end
	else
		self.folder = self._commFolder:WaitForChild(namespace)
	end

	print(`Initialized Comm {namespace}`)

	return self
end

function comm.setup()
	if isServer == false then
		warn("setup can't be run on client")
		return
	end
	print("Comm Setup Started")
	if ReplicatedStorage:FindFirstChild("comm") then
		warn("Attempted to setup after setup has already happened")
		return
	end

	local commFolder = Instance.new("Folder")
	commFolder.Name = "commEvents"
	commFolder.Parent = shared
	print("Comm Setup Complete")
end

function comm:folderCheck()
	if self.folder == nil then
		warn(`{self.namespace} has no folder`)
		return false
	end
	return true
end

function comm:remoteFunction(name: string, ...): any
	if self:folderCheck() == false then
		return
	end

	if isServer == true then
		if self.folder:FindFirstChild(name) then
			warn(`RemoteFunction {name} already exists.`)
			return
		end

		local remote = Instance.new("RemoteFunction")
		remote.Name = name
		remote.Parent = self.folder

		local bindTo: {} | (...any) -> ...any, funcName: string = ...
		if typeof(bindTo) == "table" then
			remote.OnServerInvoke = function(...)
				return bindTo[funcName](bindTo, ...) -- the first param is bindTo to pass back in self :D
			end
		else
			remote.OnServerInvoke = bindTo
		end
		return remote
	else
		local remote = self.folder:WaitForChild(name)
		return remote:InvokeServer(...)
	end
end

function comm:remoteEvent(
	name: string,
	...
): {
	remote: RemoteEvent,
	connect: (any, func: (...any) -> ...any) -> RBXScriptConnection,
	fire: (...any) -> nil,
	fireAll: ((...any) -> nil)?,
	fireFilter: ((...any) -> nil)?,
	fireExcept: ((...any) -> nil)?,
	fireFor: ((...any) -> nil)?,
} | nil
	if self:folderCheck() == false then
		return
	end

	if isServer == true then
		local remoteEvent = {}
		remoteEvent.__index = remoteEvent

		remoteEvent.remote = self.folder:FindFirstChild(name) or Instance.new("RemoteEvent")
		remoteEvent.remote.Name = name
		remoteEvent.remote.Parent = self.folder

		function remoteEvent:connect(func: (...any) -> ...any): RBXScriptConnection
			return self.remote.OnServerEvent:Connect(func)
		end

		function remoteEvent:fireAll(...)
			self.remote:FireAllClients(...)
		end

		function remoteEvent:fire(player: Player, ...)
			self.remote:FireClient(player, ...)
		end

		function remoteEvent:fireFilter(filter: (Player, ...any) -> boolean, ...)
			for _, player: Player in pairs(Players:GetPlayers()) do
				if filter(player, ...) then
					self:fire(player, ...)
				end
			end
		end

		function remoteEvent:fireFor(players: { Player }, ...)
			for _, player: Player in pairs(players) do
				self:fire(player, ...)
			end
		end

		function remoteEvent:fireDataFromFunction(func: (Player, ...any) -> ...any, ...)
			for _, player: Player in Players:GetPlayers() do
				local data = func(player, ...)
				if data ~= nil then
					self:fire(player, data)
				end
			end
		end

		return remoteEvent
	else
		local remoteEvent = {}
		remoteEvent.__index = remoteEvent

		remoteEvent.remote = self.folder:WaitForChild(name)

		function remoteEvent:connect(func: (...any) -> ...any): RBXScriptConnection
			return self.remote.OnClientEvent:Connect(func)
		end

		function remoteEvent:fire(...)
			self.remote:FireServer(...)
		end

		return remoteEvent
	end
end

function comm:bindableFunction(name: string, bindTo: {} | (...any) -> ...any, funcName: string): BindableFunction?
	if self:folderCheck() == false then
		return
	end

	if self.folder:FindFirstChild(name) then
		warn(`BindableFunction {name} already exists.`)
		return
	end

	local bindableFunction = Instance.new("BindableFunction")
	bindableFunction.Name = name
	bindableFunction.Parent = self.folder

	if typeof(bindTo) == "table" then
		bindableFunction.OnInvoke = function(...)
			return bindTo[funcName](bindTo, ...) -- the first param is bindTo to pass back in self :D
		end
	else
		bindableFunction.OnInvoke = bindTo
	end
	return bindableFunction
end

function comm:bindableEvent(
	name: string,
	...
): {
	connect: (any, func: (...any) -> ...any) -> RBXScriptConnection,
	fire: (...any) -> nil,
}?
	if self:folderCheck() == false then
		return
	end

	local bindableEvent = {}
	bindableEvent.__index = bindableEvent

	bindableEvent.remote = self.folder:FindFirstChild(name) or Instance.new("BindableEvent")
	bindableEvent.remote.Name = name
	bindableEvent.remote.Parent = self.folder

	function bindableEvent:connect(func: (...any) -> ...any): RBXScriptConnection
		return self.remote.Event:Connect(func)
	end

	function bindableEvent:fire(...)
		self.remote:Fire(...)
	end

	return bindableEvent
end

return comm
