game.ReplicatedStorage.RemoteEvent.OnServerEvent:Connect(function(player: Player, teamName: string)
	player.Team = game.Teams[teamName]
	player:LoadCharacter()
end)