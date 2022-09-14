loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/Jamster707/PL2/main/main.lua"))()
LocalPlayer.OnTeleport:Connect(function(State)
    if State == Enum.TeleportState.Started then
        local QueueOnTeleport = (syn and syn.queue_on_teleport) or queue_on_teleport
        QueueOnTeleport(loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/Jamster707/PL2/main/main.lua"))())
    end
end)
