repeat task.wait() until game:IsLoaded() and game.Players and game.Players.LocalPlayer and game.Players.LocalPlayer:FindFirstChild("PlayerGui") and game.Players.LocalPlayer:FindFirstChild("PlayerGui"):FindFirstChild("MainUI") and game.Players.LocalPlayer:FindFirstChild("PlayerGui"):FindFirstChild("MainUI"):FindFirstChild("ItemShop") and game.Players.LocalPlayer:FindFirstChild("PlayerGui"):FindFirstChild("MainUI"):FindFirstChild("ItemShop").Visible == true or (game:GetService("ReplicatedStorage"):FindFirstChild("GameData") and game:GetService("ReplicatedStorage"):FindFirstChild("GameData"):FindFirstChild("LatestRoom") and game:GetService("ReplicatedStorage"):FindFirstChild("GameData"):FindFirstChild("LatestRoom").Value ~= 0) task.wait(1.25)

local MainUI = game:GetService("Players").LocalPlayer.PlayerGui.MainUI

local Main = require(MainUI.Initiator:FindFirstChildOfClass("ModuleScript"))

local Char = (game.Players.LocalPlayer.Character or game.Players.LocalPlayer.CharacterAdded:Wait()) :: Model & {
    HumanoidRootPart: Part,
    Humanoid: Humanoid
}

Char.HumanoidRootPart:GetPropertyChangedSignal("Anchored"):Connect(function()
    if Char.HumanoidRootPart.Anchored then
        Char.HumanoidRootPart.Anchored = false
    end
end)

Main.freemouse = false
MainUI.ItemShop.Visible = false

local LatestRoom = game:GetService("ReplicatedStorage"):FindFirstChild("GameData"):FindFirstChild("LatestRoom")

local function HasTool(Name: string)
    return Char:FindFirstChild(Name) or (game.Players.LocalPlayer.Backpack :: Backpack):FindFirstChild(Name)
end

local function Fuck_A_PVInstance_Until_You_Own_It(Instance: PVInstance, ToolName: string?, PP: ProximityPrompt?, TouchInterest: TouchTransmitter?)
    local Position_Before_Fucking_A_PVInstance = Char:GetPivot()

    while not HasTool(ToolName or Instance.Name) and task.wait() do
        Char:PivotTo(Instance:GetPivot())

        if PP and fireproximityprompt then
            fireproximityprompt(PP, 3.685159)
        end

        if TouchInterest and firetouchinterest then
            firetouchinterest(TouchInterest.Parent, Char.HumanoidRootPart, 0)
            firetouchinterest(TouchInterest.Parent, Char.HumanoidRootPart, 1)
        end
    end

    Char:PivotTo(Position_Before_Fucking_A_PVInstance)
end

local function Has_The_Room_Which_Is_Being_Sexed_A_Key_Question_Mark(Room: PVInstance)
    local Key = false

    for i,v in next, Room:WaitForChild("Assets"):GetDescendants() do
        if v.Name == "KeyObtain" then
            Key = v
        end
    end

    return Key
end

local function Sex_This_Room_Exclamation_Mark(Room: PVInstance)
    local Key_Which_Is_About_To_Get_Fucked = Has_The_Room_Which_Is_Being_Sexed_A_Key_Question_Mark(Room)

    local RoomNum, Door = tonumber(Room.Name), Room.Door

    if Key_Which_Is_About_To_Get_Fucked then
        Fuck_A_PVInstance_Until_You_Own_It(Key_Which_Is_About_To_Get_Fucked, "Key", Key_Which_Is_About_To_Get_Fucked:WaitForChild("ModulePrompt"), Key_Which_Is_About_To_Get_Fucked.Hitbox:FindFirstChild("TouchInterest"))

        Door.Lock.UnlockPrompt.HoldDuration = 0
    end

    while LatestRoom.Value == RoomNum and task.wait() do
        Char:PivotTo(Door.Door:GetPivot())

        Door.ClientOpen:FireServer()

        if Key_Which_Is_About_To_Get_Fucked and fireproximityprompt then
            fireproximityprompt(Door.Lock.UnlockPrompt, 2.183619)
        end
    end
end

local Thread = task.spawn(function()
    while task.wait() do
        Sex_This_Room_Exclamation_Mark(workspace.CurrentRooms[LatestRoom.Value])
    end
end)

local Con; Con = workspace.ChildAdded:Connect(function(__: Instance)
    local v: Model = __ :: Model

    if v.Name:match("Moving") then
        task.cancel(Thread)

        Thread = task.spawn(function()
            while task.wait() do
                Char:PivotTo(v:GetPivot())
            end
        end)

        Char.Humanoid.Died:Wait()

        task.spawn(queue_on_teleport or syn and syn.queue_on_teleport, game:HttpGet("https://raw.githubusercontent.com/ActualMasterOogway/Scripts/main/Doors/Death-Farm.lua"))

        game.ReplicatedStorage.RemotesFolder.PlayAgain:FireServer()

        Con:Disconnect()
    end
end)
