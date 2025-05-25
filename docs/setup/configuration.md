---
authors:
    - parker02311
---

This guide is the next part after [setting up the system](setup.md). If you have not done this step please do it before continuing.

## Finding the Configuration module
It is under the provided folder in the ModuleScript called `settings`

## Configuration Explained
Now that we have our configuration module we can start configuring it. We will go through each section and setting and explain them.

---
### Channels
Configuration for channels.

#### `settings.channels`
Channels that the system will setup, the format is pretty simple. The first number is the channel id, and the name is the name... 

Default Value:
```lua
settings.channels = {
	[1] = {
		["name"] = "Main",
	},
	[2] = {
		["name"] = "Tac1",
	},
	[3] = {
		["name"] = "Tac2",
	},
	[4] = {
		["name"] = "Police",
	},
	[5] = {
		["name"] = "Fire",
	},
}
```
Format:
```lua
[id] = {
	["name"] = "channelName",
},
``` 

#### `settings.channelHistory`
Controls how much channel history will be stored by the server and sent to players when the **recieve** the GUI. 
This does not change how much history already spawned players will see. 

Default Value:
```lua
settings.channelHistory = 100
```

---
### Access
Controls what teams/users have access to what channels. 
This entire section follows the same format. 

Format: 
```lua
value = {
	1,2,3,4,5,6,7,8,9, -- Channel IDs
},
value = true, -- access all channels
value = false, -- access no channels
```

#### `settings.default`
Simply controls what channels players will have access to when they are not on a team or a user with channels set. 

#### `settings.teams`
Teams access.
Format: 
```lua
["teamName"] = {
	ids
},
```

#### `settings.users`
What users have access to. Basically for administration purposes should a user always have access to these channels. 
Format: 
```lua
[123] = { -- UserId, more secure, try to always use these
	ids
},
["username"] = {
	ids
},
```

---
### Panic
Controls the panic button feature.

#### `settings.panicButtonEnabled`
Controls if the panic button is enabled.
Default Value:
```lua
settings.panicButtonEnabled = true
```

#### `settings.panicBehavior`
Controls if the panic button should activate on all channels or only the active channel.
Possible values:
| Value  | Description                                           |
| ------ | ----------------------------------------------------- |
| all    | Panic button will activate on all channels            |
| active | Panic button will only activate on the active channel |
Default Value:
```lua
settings.panicBehavior = "all"
```

#### `settings.getPanicMessage`
A function that returns the message that will be sent when the panic button is pressed.

Parameters:
- `player` (Player): The player that pressed the panic button.

Returns:
Must not return nil.
- `string`: The message that will be sent when the panic button is pressed.

Default Value:
```lua
settings.getPanicMessage = function(player: Player): string
	return `{player.Name} has activated the panic button!`
end
```

#### `settings.panicCooldown`
Controls the cooldown of the panic button in seconds.
Default Value:
```lua
settings.panicCooldown = 30
```

---
### UI
Configurastion relating to the UI of the radio 

#### `settings.uiPosition`
Controls where the UI should be. 

Possible values: 
`TopLeft`, `TopRight`, `BottomLeft`, `BottomRight` 

Default Value:
```lua
settings.uiPosition = "TopLeft"
```

#### `settings.overrideUiPosition`
Manually set the UI position, this will override the above setting. Setting to nil allows the above setting to control the position. 

Note: The UI has a built in padding size of Top 44px, Bottom 4px, Left/Right 8px. 

Default Value:
```lua
settings.overrideUiPosition = nil
```

#### `settings.uiSize`
Allows you to adjust the UI size to fit your game. 

Note: The UI has a size constraint which can be modified using the settings below. 

Default Value:
```lua
settings.uiSize = UDim2.fromScale(0.4, 0.25)
```

#### `settings.uiMaxSize`
Controls the maxsize of the UI, really only effective when using Scale. Default based off of Roblox. 

Default Value:
```lua
settings.uiMaxSize = Vector2.new(475, 275)
```

#### `settings.keybinds`
Allows you to change the default keybinds for the radio system. 

Default Value:
```lua
settings.keybinds = {
	text = Enum.KeyCode.T,
	mic = Enum.KeyCode.Y,
	hide = Enum.KeyCode.H
}
```

#### `settings.audio`
Controls audio played upon certain actions. Set any value to `nil` or `false` to disable that sound. 

The Radio system comes with audio published by parker02311, due to the audio privacy update these audios will not work by default. You can find the audio used in his videos [here](http://www.w2sjw.com/radio_sounds.html) and republish them yourself. 

The panic sound is a public audio on the toolbox and should work by default.

Actions:

| Action          | Description                                                                                |
| --------------- | ------------------------------------------------------------------------------------------ |
| messageRecieved | When the player recieves a message in their active channel                                 |
| sideTone        | When the player tries to activate voice communications while someone else is using the air |
| keyDown         | When the player presses down the key to activate voice                                     |
| keyUp           | The exact oppisite of the above                                                            |
| panic           | When the panic button is pressed                                                           |

---
### Chat Config

#### `settings.overrideWindowEnabled`
When the game uses the new text chat service this option when enabled will override the value for `ChatWindowConfiguration.Enabled` to be false. 

This makes it easier to use the system when its UI position is in TopLeft. 

Default Value:
```lua
settings.overrideWindowEnabled = true
```

#### `settings.additionalTopPadding`
Adds additional padding to the top of the chat window when the radio UI is in the TopLeft position.

If the radio is not in the TopLeft position, it is recommended to set this value to 0.

Default Value:
```lua
settings.additionalTopPadding = 50
```

---
### DEVELOPER
Best not to touch anything

#### `settings.debug`
Touch this if you are using the API, helps a lot with debugging any API issues.