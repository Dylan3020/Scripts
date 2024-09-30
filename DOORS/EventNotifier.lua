function spawned(entity)
game:GetService("StarterGui"):SetCore("SendNotification",{
    Title = entity.." Has Spawned!", -- Required
    Text = entity, -- Required
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

elseif child.Name == "TrollfaceMoving" then
spawned("Trollface")
elseif child.Name == "Josh HutchersonMoving" then
spawned("Josh Hutcherson")
elseif child.Name == "werid entityMoving" then
spawned("werid entity")
elseif child.Name == "BlitzMoving" then
spawned("Blitz")
elseif child.Name == "Ambush_ModifierMoving" then
spawned("Ambush")
elseif child.Name == "ShadowA60Moving" then
spawned("Shadow A-60")
elseif child.Name == "ShadowA120Moving" then
spawned("Shadow A-120")
elseif child.Name == "AnglerMoving" then
spawned("Angler")
elseif child.Name == "FrogerMoving" then
spawned("Froger")
elseif child.Name == "eyeMoving" then
spawned("eye")
elseif child.Name == "scaryfaceMoving" then
spawned("Scary Face")
elseif child.name == "CustomMoving" then
spawned("Custom Entity")

end
end)
spawned("Entity Notifier 2.0")
