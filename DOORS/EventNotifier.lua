local plr = game.Players.LocalPlayer
local char = plr.Character or plr.CharacterAdded:Wait()
local hum = char:FindFirstChildOfClass("Humanoid") or char:WaitForChild("Humanoid")
local entitynames = {"RushMoving","AmbushMoving", "BackdoorRush", "A60", "A120", "Rush", "Ambush"}
 local addconnect
        addconnect = workspace.ChildAdded:Connect(function(v)
            if table.find(entitynames,v.Name) then
                repeat task.wait() until plr:DistanceFromCharacter(v:GetPivot().Position) < 1000 or not v:IsDescendantOf(workspace)
                
                if v:IsDescendantOf(workspace) then
        firesignal(game.ReplicatedStorage.RemotesFolder.Caption.OnClientEvent, v.Name:gsub("Moving","").." Spawned!")



                end
            end
        end)
