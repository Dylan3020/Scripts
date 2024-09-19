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
	Title = "Doors Rooms+",
	Center = true,
	AutoShow = true,
	Resizable = true,
	ShowCustomCursor = false,
	TabPadding = 2,
	MenuFadeTime = 0
})

local Tabs = {
	Main = Window:AddTab("Main"),
	["UI Settings"] = Window:AddTab("UI Settings"),
}

local MainFrame = MainUI.MainFrame
local GameData = ReplicatedStorage.GameData
local LatestRoom = GameData.LatestRoom
local Floor = GameData.Floor
local Bricks = ReplicatedStorage.Bricks
local ClientModules = ReplicatedStorage.ClientModules
local DeathHint = Bricks.DeathHint
local CamLock = Bricks.CamLock
local MotorReplication = Bricks.MotorReplication
local EntityModules = ClientModules.EntityModules
local CurrentRooms = workspace.CurrentRooms
local MainUI = LocalPlayer.PlayerGui.MainUI
local Main_Game = MainUI.Initiator.Main_Game
local Modules = Main_Game.RemoteListener.Modules

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
	Temp = {
        AnchorFinished = {},
        FlyBody = nil,
        Guidance = {},
    }
}

local EntityName = {"BlitzMoving", "BackdoorLookmanNew", "RushMoving", "AmbushMoving", "LookmanNew", "A60Moving", "A120Moving"}
local SideEntityName = {"FigureRig", "GiggleCeiling", "GrumbleRig", "Snare"}
local ShortNames = {
    ["BlitzMoving"] = "Blitz"
}

function Script.Functions.GetShortName(entityName: string)
    if ShortNames[entityName] then
        return ShortNames[entityName]
    end

    local suffixPrefix = {
        ["Backdoor"] = "",
        ["Ceiling"] = "",
        ["Moving"] = "",
        ["Ragdoll"] = "",
        ["Rig"] = "",
        ["Wall"] = "",
        ["Key"] = " Key",
        ["Pack"] = " Pack",
        ["Swarm"] = " Swarm",
    }

    for suffix, fix in pairs(suffixPrefix) do
        entityName = entityName:gsub(suffix, fix)
    end

    return entityName
end

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

Library:GiveSignal(workspace.ChildAdded:Connect(function(child)
    task.delay(0.1, function()
        if table.find(EntityName, child.Name) then
            task.spawn(function()
                repeat
                    task.wait()
                until Script.Functions.DistanceFromCharacter(child) < 2000 or not child:IsDescendantOf(workspace)

                if child:IsDescendantOf(workspace) then
                    local entityName = Script.Functions.GetShortName(child.Name)

                    if isFools and child.Name == "RushMoving" then
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

if Toggles.EntityESP.Value and table.find(SideEntityName, asset.Name) then    
                task.spawn(Script.Functions.SideEntityESP, asset)
end





local MenuGroup = Tabs["UI Settings"]:AddLeftGroupbox("Menu")
local CreditsGroup = Tabs["UI Settings"]:AddRightGroupbox("Credits")

MenuGroup:AddToggle("KeybindMenuOpen", { Default = false, Text = "Open Keybind Menu", Callback = function(value) Library.KeybindFrame.Visible = value end})
MenuGroup:AddToggle("ShowCustomCursor", {Text = "Custom Cursor", Default = true, Callback = function(Value) Library.ShowCustomCursor = Value end})
MenuGroup:AddDivider()
MenuGroup:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", { Default = "RightShift", NoUI = true, Text = "Menu keybind" })
MenuGroup:AddButton("Join Discord Server", function()
    local Inviter = loadstring(game:HttpGet("https://raw.githubusercontent.com/RegularVynixu/Utilities/main/Discord%20Inviter/Source.lua"))()
	Inviter.Join("https://discord.com/invite/cfyMptntHr")
	Inviter.Prompt({
		name = "mspaint",
		invite = "https://discord.com/invite/cfyMptntHr",
	})
end)
MenuGroup:AddButton("Unload", function() Library:Unload() end)

CreditsGroup:AddLabel("deividcomsono - script dev")
CreditsGroup:AddLabel("upio - script dev")
CreditsGroup:AddDivider()
CreditsGroup:AddLabel("Script Contributors:")
CreditsGroup:AddLabel("mstudio45 - fake revive & firepp")

Library.ToggleKeybind = Options.MenuKeybind

ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)

SaveManager:IgnoreThemeSettings()

ThemeManager:SetFolder("mspaint")
SaveManager:SetFolder("mspaint/doors")

SaveManager:BuildConfigSection(Tabs["UI Settings"])

ThemeManager:ApplyToTab(Tabs["UI Settings"])

SaveManager:LoadAutoloadConfig()
