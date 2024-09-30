local plr = game.Players.LocalPlayer
local char = plr.Character
local hum = char:FindFirstChildOfClass("Humanoid") or char:WaitForChild("Humanoid")
local entitynames = {"RushMoving","AmbushMoving", "BackdoorRush", "GloombatSwarm", "CustomMoving", "Ambush_ModifierMoving", "BlitzMoving", "TrollfaceMoving", "ShadowA60Moving", "ShadowA120Moving" "AnglerMoving", "FrogerMoving", "eyeMoving", "scaryfaceMoving", "A60Moving", "A120Moving", "Rush", "Ambush"}
 local addconnect
        addconnect = workspace.ChildAdded:Connect(function(v)
            if table.find(entitynames,v.Name) then
                repeat task.wait() until plr:DistanceFromCharacter(v:GetPivot().Position) < 1000 or not v:IsDescendantOf(workspace)
                
                if v:IsDescendantOf(workspace) then
        firesignal(game.ReplicatedStorage.Bricks.Caption.OnClientEvent, v.Name:gsub("Moving","").." Spawned!")



                end
            end
        end)
