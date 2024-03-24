---
authors:
    - parker02311
---

This guide is the next part after [setting up the system](/setup/setup). If you have not done this step please do it before continuing.

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

Note: The UI has a 30 pixel sized padding always. 

Default Value:
```lua
settings.overrideUiPosition = nil
```

#### `settings.audio`
Controls audio played upon certain actions. Set any value to `nil` or `false` to disable that sound. 

The Radio system comes with audio published by parker02311, due to the audio privacy update these audios will not work by default. You can find the audio used in his videos [here](http://www.w2sjw.com/radio_sounds.html) and republish them yourself. 

Actions:

| Action          | Description                                                                                |
| --------------- | ------------------------------------------------------------------------------------------ |
| messageRecieved | When the player recieves a message in their active channel                                 |
| sideTone        | When the player tries to activate voice communications while someone else is using the air |
| keyDown         | When the player presses down the key to activate voice                                     |
| keyUp           | The exact oppisite of the above                                                            |

---
### Chat Config

#### `settings.overrideWindowEnabled`
When the game uses the new text chat service this option when enabled will override the value for `ChatWindowConfiguration.Enabled` to be false. 

This makes it easier to use the system when its UI position is in TopLeft. 

Default Value:
```lua
settings.overrideWindowEnabled = true
```

---
### DEVELOPER
Best not to touch anything

#### `settings.debug`
Touch this if you are using the API, helps a lot with debugging any API issues.