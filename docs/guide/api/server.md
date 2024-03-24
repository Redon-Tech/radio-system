---
authors:
    - parker02311
---

Please take a note of where your server API wrapper is located, this guide will assume that the wrapper is in ServerScriptService.

## Setting Up
Setting up is pretty simple. Just require the script and call `.init()`. 

1. Create a `Script`
2. Paste the following code:
    ```lua
    local ServerScriptService = game:GetService("ServerScriptService")
    local serverAPI = require(ServerScriptService:WaitForChild("Radio System Server API")).init()
    ```
3. Hit 'Play', check for any errors.

??? failure "It Errors"
    1. Try debugging it yourself.
    2. If you can not figure out why, feel free to create a support thread.
    3. Remember, be patient, and please understand that the API is meant to be used by those who know how to program.

## API Reference

---
### cleanup
**The most important function of them all**
Call this function once you are done with the API, it will clean up all connections for you. 
```lua
() -> nil
```

#### Example Usage
```lua
serverAPI:cleanup()
```

---
### ScriptConnection
Our version of a `RBXMScriptConnection`, it just provides a way to disconnect from a function.

#### Methods
- `disconnect()` - Disconnects the function

#### Example Usage
```lua
local connection = ...
task.wait(10)
connection:disconnect()
```

---
### receivedClientMessage
Calls the function whenever we receieve a message from a player.
```lua
(
    func: (player: Player, message: string, channelId: number) -> nil
) -> ScriptConnection
```

#### Parameters

- `func: (player: Player, message: string, channelId: number) -> nil` - a function that accepts a Player, string, number as its parameters and returns nil.

#### Example Usage
```lua
local connection = serverAPI:clientMessageRecieved(function(player: Player, message: string, channelId: number)
    print(player, message, channelId)
end)

task.wait(10)

connection:disconnect()
```

---
### receivedClientMessage
Calls the function whenever a player **tries** to use the voice channel.
```lua
(
    func: (player: Player, channelId: number) -> nil
) -> ScriptConnection
```

#### Parameters

- `func: (player: Player, channelId: number) -> nil` - a function that accepts a Player and number as its parameters and returns nil.

#### Example Usage
```lua
serverAPI:clientMessageRecieved(function(player: Player, channelId: number)
    print(player, channelId)
end)
```

---
### authorizedClient
Calls the function whenever the server sends authorized channels to a client.
```lua
(
    func: (player: Player, authorizedChannels: {number}) -> nil
) -> ScriptConnection
```

#### Parameters

- `func: (player: Player, authorizedChannels: {number}) -> nil` - a function that accepts a Player and table as its parameters and returns nil.

#### Example Usage
```lua
serverAPI:clientMessageRecieved(function(player: Player, authorizedChannels: {number})
    print(player, authorizedChannels)
end)
```

---
### channelAddPlayer
Calls the function whenever a channel adds a player to itself.
```lua
(
    func: (id: number, player: Player) -> nil
) -> ScriptConnection
```

#### Parameters

- `func: (id: number, player: Player) -> nil` - a function that accepts a numbe and Player as its parameters and returns nil.

#### Example Usage
```lua
serverAPI:clientMessageRecieved(function(id: number, player: Player)
    print(id, player)
end)
```

---
### channelRemovePlayer
Calls the function whenever a channel removes a player to itself.
```lua
(
    func: (id: number, player: Player) -> nil
) -> ScriptConnection
```

#### Parameters

- `func: (id: number, player: Player) -> nil` - a function that accepts a numbe and Player as its parameters and returns nil.

#### Example Usage
```lua
serverAPI:clientMessageRecieved(function(id: number, player: Player)
    print(id, player)
end)
```

---
### createSystemMessage
Creates a system message in the specified channel. System messages are not currently stored in channel history.
```lua
(
    channelId: number,
	message: {
		text: string,
		headerText: string?,
		backgroundColor3: Color3?,
		icon: string?,
		iconColor3: Color3?,
		iconRounded: boolean?,
		sideText: string?,
		sideAccent: Color3?,
	}
) -> nil
```

#### Parameters

- `channelId: number` - the channel id to send the message to
- `message: ...` - the message data to send

#### Example Usage
```lua
serverAPI:createSystemMessage(1, {
	text = "Hello, World!",
	sideText = "test",
})
```

---
### activatePlayersVoice
Attempts to activate/deactivate a players voice communications
```lua
(
    channelId: number,
	player: Player
) -> nil
```

#### Parameters

- `channelId: number` - the channel id to use
- `player: Player` - the player to attempt this on

#### Example Usage
```lua
serverAPI:activatePlayersVoice(1, game.Players.parker02311)
```