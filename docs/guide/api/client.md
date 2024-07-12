---
authors:
    - parker02311
---

Please take a note of where your client API wrapper is located, this guide will assume that the wrapper is in ReplicatedStorage.

## Setting Up
Setting up is pretty simple. Just require the script and call `.init()`. 

1. Create a `LocalScript` in `StaterGui` or in `StaterPlayer`
2. Paste the following code:
    ```lua
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local clientAPI = require(ReplicatedStorage:WaitForChild("Radio System Client API")).init()
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
clientAPI:cleanup()
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
### clientMessageRecieved
Calls the function whenever we receieve a message from another player or we sent a message.
```lua
(
    func: (channelId: number, player: Player, message: string) -> nil
) -> ScriptConnection
```

#### Parameters

- `func: (channelId: number, player: Player, message: string) -> nil` - a function that accepts a number, Player, and string as its parameters and returns nil.

#### Example Usage
```lua
local connection = clientAPI:clientMessageRecieved(function(channelId: number, player: Player, message: string)
    print(channelId, player, message)
end)

task.wait(10)

connection:disconnect()
```

---
### systemMessageRecieved
Calls the function whenever we receieve a message from the system which is usually called by the server API.
```lua
(
    func: (channelId: number, message: {
        text: string,
        headerText: string?,
        backgroundColor3: Color3?,
        icon: string?,
        iconColor3: Color3?,
        iconRounded: boolean?,
        sideText: string?,
        sideAccent: Color3?,
    }) -> nil
) -> ScriptConnection
```

#### Parameters

- `func: (channelId: number, message: ...) -> nil` - a function that accepts a number and message as its parameters and returns nil.

#### Example Usage
```lua
clientAPI:systemMessageRecieved(function(channelId: number, message: {...any})
    print(channelId, message)
end)
```

---
### messageHistoryRecieved
Calls the function whenever we recieve a channels history, usually calls whenver the player recieves the GUI.
```lua
(
    func: (channelId: number, history: {}) -> nil
) -> ScriptConnection
```

#### Parameters

- `func: (channelId: number, history: {}) -> nil` - a function that accepts a number and table as its parameters and returns nil.

#### Example Usage
```lua
clientAPI:clientMessageRecieved(function(channelId: number, history: {...any})
    print(channelId, history)
end)
```

---
### voiceRecieve
Calls the function whenever any player (including the local player) starts to send voice communications.
```lua
(
    func: (channelId: number, player: Player) -> nil
) -> ScriptConnection
```

#### Parameters

- `func: (channelId: number, player: Player) -> nil` - a function that accepts a number and Player as its parameters and returns nil.

#### Example Usage
```lua
clientAPI:clientMessageRecieved(function(channelId: number, player: Player)
    print(channelId, player)
end)
```

---
### sendMessage
Calls the function whenever we send a message to the selected channel.
```lua
(
    func: (channelId: number, message: string) -> nil
) -> ScriptConnection
```

#### Parameters

- `func: (channelId: number, message: string) -> nil` - a function that accepts a number and string as its parameters and returns nil.

#### Example Usage
```lua
clientAPI:clientMessageRecieved(function(channelId: number, message: string)
    print(channelId, message)
end)
```

---
### textActivateChanged
Calls the function whenever we the player activated or deactivated the text chat.
```lua
(
    func: (active: boolean) -> nil
) -> ScriptConnection
```

#### Parameters

- `func: (active: boolean) -> nil` - a function that accepts a boolean as its parameters and returns nil.

#### Example Usage
```lua
clientAPI:clientMessageRecieved(function(active: boolean)
    print(active)
end)
```

---
### voiceActivateChanged
Calls the function whenever we the player activated or deactivated the voice chat.
```lua
(
    func: (active: boolean) -> nil
) -> ScriptConnection
```

#### Parameters

- `func: (active: boolean) -> nil` - a function that accepts a boolean as its parameters and returns nil.

#### Example Usage
```lua
clientAPI:clientMessageRecieved(function(active: boolean)
    print(active)
end)
```

---
### getEnabled
Returns wether or not the radio is currently enabled
```lua
(): boolean
```

#### Example Usage
```lua
print(clientAPI:getEnabled())
```

---
### setEnabled
Tells the radio to disable or enable
```lua
(
    enabled: boolean
) -> nil
```

#### Parameters

- `enabled: boolean` - a true or false.

#### Example Usage
```lua
clientAPI:setEnabled(false)
```