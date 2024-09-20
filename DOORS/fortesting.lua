--// Services \\--
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local SoundService = game:GetService("SoundService")
local UserInputService = game:GetService("UserInputService")
local PathfindingService = game:GetService("PathfindingService")
local ProximityPromptService = game:GetService("ProximityPromptService")

--// Library \\--
local repo = "https://raw.githubusercontent.com/mstudio45/LinoriaLib/main/"

local Library = loadstring(game:HttpGet(repo .. "Library.lua"))()
local ThemeManager = loadstring(game:HttpGet(repo .. "addons/ThemeManager.lua"))()
local SaveManager = loadstring(game:HttpGet(repo .. "addons/SaveManager.lua"))()
local Options = getgenv().Linoria.Options
local Toggles = getgenv().Linoria.Toggles

local Window = Library:CreateWindow({
	Title = "Doors Rooms+ V1",
	Center = true,
	AutoShow = true,
	Resizable = true,
	ShowCustomCursor = true,
	TabPadding = 2,
	MenuFadeTime = 0
})

local Tabs = {
	Main = Window:AddTab("Main"),
    Visuals = Window:AddTab("Visuals"),
	["UI Settings"] = Window:AddTab("UI Settings"),
}

Toggles.EntityESP:OnChanged(function(value)
    if value then
        local currentRoomModel = workspace.CurrentRooms:FindFirstChild(currentRoom)
        if currentRoomModel then
            for _, entity in pairs(currentRoomModel:GetDescendants()) do
                if table.find(SideEntityName, entity.Name) then
                    Script.Functions.SideEntityESP(entity)
                end
            end
        end
    else
        for _, esp in pairs(Script.ESPTable.Entity) do
            esp.Destroy()
        end
        for _, esp in pairs(Script.ESPTable.SideEntity) do
            esp.Destroy()
        end
    end
end)

Options.EntityEspColor:OnChanged(function(value)
    for _, esp in pairs(Script.ESPTable.Entity) do
        esp.SetColor(value)
    end
end

function Script.Functions.EntityESP(entity)
    Script.Functions.ESP({
        Type = "Entity",
        Object = entity,
        Text = Script.Functions.GetShortName(entity.Name),
        Color = Options.EntityEspColor.Value,
    })
end

function Script.Functions.SideEntityESP(entity)
    Script.Functions.ESP({
        Type = "SideEntity",
        Object = entity,
        Text = Script.Functions.GetShortName(entity.Name),
        TextParent = entity.PrimaryPart,
        Color = Options.EntityEspColor.Value,
    })
end

local ESPTabBox = Tabs.Visuals:AddLeftTabbox() do
    local ESPTab = ESPTabBox:AddTab("ESP") do
        ESPTab:AddToggle("EntityESP", {
            Text = "Entity",
            Default = false,
        }):AddColorPicker("EntityEspColor", {
            Default = Color3.new(1, 0, 0),
        })
    end

Library:GiveSignal(workspace.ChildAdded:Connect(function(child)
    task.delay(0.1, function()
        if table.find(EntityName, child.Name) then
            task.spawn(function()
                repeat
                    task.wait()
                until Script.Functions.DistanceFromCharacter(child) < 2000 or not child:IsDescendantOf(workspace)

                if child:IsDescendantOf(workspace) then
                    local entityName = Script.Functions.GetShortName(child.Name)

                    if isFools and child.Name == "RushAmbush" then
                        entityName = child.PrimaryPart.Name:gsub("New", "")
                    end

                    if Toggles.EntityESP.Value then
                        Script.Functions.EntityESP(child)  
                    end

                    if Toggles.NotifyEntity.Value then
                        Script.Functions.Alert(entityName .. " has spawned!")
                    end
                end
            end)
        elseif EntityNotify[child.Name] and Toggles.NotifyEntity.Value then
            Script.Functions.Alert(EntityNotify[child.Name])
        end

if workspace.CurrentRooms:FindFirstChild(currentRoom) then
    task.spawn(Script.Functions.SetupCurrentRoomConnection, workspace.CurrentRooms[currentRoom])
end
Library:GiveSignal(localPlayer:GetAttributeChangedSignal("CurrentRoom"):Connect(function()
    currentRoom = localPlayer:GetAttribute("CurrentRoom")
    nextRoom = currentRoom + 1

    local currentRoomModel = workspace.CurrentRooms:FindFirstChild(currentRoom)
    local nextRoomModel = workspace.CurrentRooms:FindFirstChild(nextRoom)
  
    if Toggles.EntityESP.Value then
        for _, sideEntityESP in pairs(Script.ESPTable.SideEntity) do
            sideEntityESP.Destroy()
        end
    end
end

if currentRoomModel then
        for _, asset in pairs(currentRoomModel:GetDescendants()) do
            if Toggles.EntityESP.Value and table.find(SideEntityName, asset.Name) then    
                task.spawn(Script.Functions.SideEntityESP, asset)
            end
        end
    
        Script.Functions.SetupCurrentRoomConnection(currentRoomModel)
    end
end))


function Script.Functions.ESP(args: ESP)
    if not args.Object then return Script.Functions.Warn("ESP Object is nil") end

    local ESPManager = {
        Object = args.Object,
        Text = args.Text or "No Text",
        TextParent = args.TextParent,
        Color = args.Color or Color3.new(),
        Offset = args.Offset or Vector3.zero,
        IsEntity = args.IsEntity or false,
        IsDoubleDoor = args.IsDoubleDoor or false,
        Type = args.Type or "None",

        Highlights = {},
        Humanoid = nil,
        RSConnection = nil,
    }
            end
     end)
        
 Script.ESPTable[ESPManager.Type][tableIndex] = ESPManager
    return ESPManager
end 


local entityModules = ReplicatedStorage:WaitForChild("ClientModules"):WaitForChild("EntityModules")

local gameData = ReplicatedStorage:WaitForChild("GameData")
local floor = gameData:WaitForChild("Floor")
local latestRoom = gameData:WaitForChild("LatestRoom")

local Bricks

local camera = workspace.CurrentCamera
local localPlayer = Players.LocalPlayer

local playerGui = localPlayer.PlayerGui
local mainUI = playerGui:WaitForChild("MainUI")
local mainGame = mainUI:WaitForChild("Initiator"):WaitForChild("Main_Game")
local mainGameSrc = require(mainGame)

local playerScripts = localPlayer.PlayerScripts
local controlModule = require(playerScripts:WaitForChild("PlayerModule"):WaitForChild("ControlModule"))

local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()
local alive = localPlayer:GetAttribute("Alive")
local humanoid: Humanoid
local rootPart: BasePart
local collision
local collisionClone

local isRooms = floor.Value == "Rooms"

local currentRoom = localPlayer:GetAttribute("CurrentRoom") or 0
local nextRoom = currentRoom + 1 

type ESP = {
    Color: Color3,
    IsEntity: boolean,
    IsDoubleDoor: boolean,
    Object: Instance,
    Offset: Vector3,
    Text: string,
    TextParent: Instance,
    Type: string,
}

local Script = {
    Binded = {}, -- ty geo for idea :smartindividual:
    Connections = {},
    ESPTable = {
        Entity = {},
        SideEntity = {},
        None = {}
    },
    Functions = {},
    Temp = {
        AnchorFinished = {},
        FlyBody = nil,
        Guidance = {},
    }
}

local EntityName = {"BlitzMoving", "BackdoorLookmanNew", "RushMoving", "AmbushMoving", "LookmanNew", "TrollfaceMoving", "A60Moving", "A120Moving"}
local SideEntityName = {"FigureRig", "GiggleCeiling", "GrumbleRig", "Snare"}
local ShortNames = {
    ["BlitzMoving"] = "Blitz",
    ["BackdoorLookmanNew"] = "Lookman",
    ["LookmanNew"] = "Eyes",
    ["A60Moving"] = "A120Moving"
}


	print("Unloaded!")
	Library.Unloaded = true
    getgenv().doorsrooms_loaded = false
end)

local MenuGroup = Tabs["UI Settings"]:AddLeftGroupbox("Menu")
local CreditsGroup = Tabs["UI Settings"]:AddRightGroupbox("Credits")

MenuGroup:AddToggle("KeybindMenuOpen", { Default = false, Text = "Open Keybind Menu", Callback = function(value) Library.KeybindFrame.Visible = value end})
MenuGroup:AddToggle("ShowCustomCursor", {Text = "Custom Cursor", Default = true, Callback = function(Value) Library.ShowCustomCursor = Value end})
MenuGroup:AddDivider()
MenuGroup:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", { Default = "RightShift", NoUI = true, Text = "Menu keybind" })
MenuGroup:AddButton("Join Discord Server", function()
    local Inviter = loadstring(game:HttpGet("https://raw.githubusercontent.com/RegularVynixu/Utilities/main/Discord%20Inviter/Source.lua"))()
	Inviter.Join("discord.gg/AvhgYcUd7N")
	Inviter.Prompt({
		name = "Doors Rooms+",
		invite = "discord.gg/AvhgYcUd7N",
	})
end)
MenuGroup:AddButton("Unload", function() Library:Unload() end)

CreditsGroup:AddLabel("Supge3 - script dev")
CreditsGroup:AddDivider()
CreditsGroup:AddLabel("US_VK owner of this goofy ahh game")

Library.ToggleKeybind = Options.MenuKeybind

ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)

SaveManager:IgnoreThemeSettings()

ThemeManager:SetFolder("doorsrooms")
SaveManager:SetFolder("doorsrooms/doors")

SaveManager:BuildConfigSection(Tabs["UI Settings"])

ThemeManager:ApplyToTab(Tabs["UI Settings"])

SaveManager:LoadAutoloadConfig()      
