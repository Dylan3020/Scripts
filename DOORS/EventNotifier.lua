function spawned(entity)
game:GetService("StarterGui"):SetCore("SendNotification",{
    Title = entity.." Has Spawned!", -- Required
    Text = entity, -- Required!!
    Icon = "rbxassetid://1234567890" -- Optional
})
end
game.Workspace.ChildAdded:Connect(function(child)

if child.Name == "A60Moving" then
spawned("A-60")
elseif child.Name == "A120Moving" then
spawned("A-120")
elseif child.Name == "RushMoving" then
spawned("Rush")
elseif child.Name == "AmbushMoving" then
spawned("Ambush")

elseif child.Name == "A60" then
spawned("A-60")
elseif child.Name == "A120" then
spawned("A-120")
elseif child.Name == "BackdoorRush" then
spawned("Blitz")
elseif child.Name == "MonumentEntity" then
spawned("Monument")
elseif child.Name == "Groundskeeper" then
spawned("Groundskeeper")
elseif child.Name == "Eyes" then
spawned("Eyes")
elseif child.Name == "BackdoorLookman" then
spawned("Lookman")
elseif child.name == "Death" then
spawned("Ripper")
elseif child.name == "RushCounterpart" then
spawned("Cease")
elseif child.name == "A-60" then
spawned("A-60 Multimonster")
elseif child.name == "ReboundMoving" then
spawned("Rebound")
elseif child.name == "Silence" then
spawned("Silence")
elseif child.name == "monster2" then
spawned("A-200")
elseif child.name == "Deer God" then
spawned("Deer God")






end
end)
spawned("Entity Notifier 2.0")
