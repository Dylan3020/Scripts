--// Services \\--
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

--// Variables \\--
local Script = {
    Connections = {},
    ESPTable = {
        Door = {},
        Entity = {},
        Gold = {},
        Item = {},
        Objective = {},
        Player = {},
        None = {}
    },
    Functions = {}
}

local EntityName = {"BlitzMoving", "BackdoorLookmanNew", "RushMoving", "AmbushMoving", "LookmanNew", "Screech", "Halt", "Jeff The KillerMoving", "ContentMoving", "PandemoniumMoving", "eyeMoving", "scaryfaceMoving", "CustomMoving", "Ambush_ModifierMoving", "TrollfaceMoving", "SeekMoving", "A60Moving", "A120Moving"}
local SideEntityName = {"FigureRagdoll", "GiggleCeiling", "GrumbleRig", "Landmine"}
local ShortNames = {
    ["BlitzMoving"] = "Blitz",
    ["BackdoorLookmanNew"] = "Lookman",
    ["LookmanNew"] = "Eyes",
    ["Landmine"] = "Snare",
    ["A60Moving"] = "A-60",
    ["A120Moving"] = "A-120",
    ["Jeff The KillerMoving"] = "Jeff The Killer"
}

local PromptTable = {
    GamePrompts = {},

    Aura = {
        ["ActivateEventPrompt"] = false,
        ["AwesomePrompt"] = true,
        ["FusesPrompt"] = true,
        ["HerbPrompt"] = false,
        ["LeverPrompt"] = true,
        ["LootPrompt"] = false,
        ["ModulePrompt"] = true,
        ["SkullPrompt"] = false,
        ["UnlockPrompt"] = true,
        ["ValvePrompt"] = false,
        ["PropPrompt"] = true
    },
    AuraObjects = {
        "Lock",
        "Button"
    },

    Clip = {
        "AwesomePrompt",
        "FusesPrompt",
        "HerbPrompt",
        "HidePrompt",
        "LeverPrompt",
        "LootPrompt",
        "ModulePrompt",
        "Prompt",
        "PushPrompt",
        "SkullPrompt",
        "UnlockPrompt",
        "ValvePrompt"
    },
    ClipObjects = {
        "LeverForGate",
        "LiveBreakerPolePickup",
        "LiveHintBook",
        "Button",
    },

    Excluded = {
        Prompt = {
            "HintPrompt",
            "InteractPrompt"
        },

        Parent = {
            "KeyObtainFake",
            "Padlock"
        },

        ModelAncestor = {
            "DoorFake"
        }
    }
}

local entityModules = ReplicatedStorage:WaitForChild("ClientModules"):WaitForChild("EntityModules")

local gameData = ReplicatedStorage:WaitForChild("GameData")
local floor = gameData:WaitForChild("Floor")
local latestRoom = gameData:WaitForChild("LatestRoom")

local remotesFolder = ReplicatedStorage:WaitForChild("Bricks")

local localPlayer = Players.LocalPlayer

local playerGui = localPlayer.PlayerGui
local mainUI = playerGui:WaitForChild("MainUI")
local mainGame = mainUI:WaitForChild("Initiator"):WaitForChild("Main_Game")
local mainGameSrc = require(mainGame)

local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()
local alive = localPlayer:GetAttribute("Alive")
local humanoid
local rootPart
local collision
local collisionClone

local isRooms = floor.Value == "Rooms"

local lastSpeed = 0

type ESP = {
    Color: Color3,
    IsEntity: boolean,
    Object: Instance,
    Offset: Vector3,
    Text: string,
    TextParent: Instance,
    Type: string,
}

--// Library \\--
local repo = "https://raw.githubusercontent.com/deividcomsono/LinoriaLib/main/"

local Library = loadstring(game:HttpGet(repo .. "Library.lua"))()
local ThemeManager = loadstring(game:HttpGet(repo .. "addons/ThemeManager.lua"))()
local SaveManager = loadstring(game:HttpGet(repo .. "addons/SaveManager.lua"))()
local Options = getgenv().Linoria.Options
local Toggles = getgenv().Linoria.Toggles

local Window = Library:CreateWindow({
	Title = "DOORS: Rooms+",
	Center = true,
	AutoShow = true,
	Resizable = true,
    NotifySide = "Right",
	ShowCustomCursor = true,
	TabPadding = 2,
	MenuFadeTime = 0
})

local Tabs = {
	Main = Window:AddTab("Main"),
    Exploits = Window:AddTab("Exploits"),
    Visuals = Window:AddTab("Visuals"),
    Floor = Window:AddTab("Floor"),
	["UI Settings"] = Window:AddTab("UI Settings"),
}

--// Functions \\--

function Script.Functions.Warn(message: string)
    warn("WARN - DOORS:", message)
end

function Script.Functions.ESP(args: ESP)
    if not args.Object then return Script.Functions.Warn("ESP Object is nil") end

    local ESPManager = {
        Object = args.Object,
        Text = args.Text or "No Text",
        TextParent = args.TextParent,
        Color = args.Color or Color3.new(),
        Offset = args.Offset or Vector3.zero,
        IsEntity = args.IsEntity or false,
        Type = args.Type or "None",

        RSConnection = nil,
    }

    local tableIndex = #Script.ESPTable[ESPManager.Type] + 1

    if ESPManager.IsEntity and ESPManager.Object.PrimaryPart.Transparency == 1 then
        ESPManager.Object:SetAttribute("Transparency", ESPManager.Object.PrimaryPart.Transparency)
        Instance.new("Humanoid", ESPManager.Object)
        ESPManager.Object.PrimaryPart.Transparency = 0.99
    end

    local highlight = Instance.new("Highlight") do
        highlight.Adornee = ESPManager.Object
        highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        highlight.FillColor = ESPManager.Color
        highlight.FillTransparency = Options.ESPFillTransparency.Value
        highlight.OutlineColor = ESPManager.Color
        highlight.OutlineTransparency = Options.ESPOutlineTransparency.Value
        highlight.Enabled = Toggles.ESPHighlight.Value
        highlight.Parent = ESPManager.Object
    end

    local billboardGui = Instance.new("BillboardGui") do
        billboardGui.Adornee = ESPManager.TextParent or ESPManager.Object
		billboardGui.AlwaysOnTop = true
		billboardGui.ClipsDescendants = false
		billboardGui.Size = UDim2.new(0, 1, 0, 1)
		billboardGui.StudsOffset = ESPManager.Offset
        billboardGui.Parent = ESPManager.TextParent or ESPManager.Object
	end

    local textLabel = Instance.new("TextLabel") do
		textLabel.BackgroundTransparency = 1
		textLabel.Font = Enum.Font.Oswald
		textLabel.Size = UDim2.new(1, 0, 1, 0)
		textLabel.Text = ESPManager.Text
		textLabel.TextColor3 = ESPManager.Color
		textLabel.TextSize = Options.ESPTextSize.Value
        textLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
        textLabel.TextStrokeTransparency = 0.75
        textLabel.Parent = billboardGui
	end

    function ESPManager.SetColor(newColor: Color3)
        ESPManager.Color = newColor

        highlight.FillColor = newColor
        highlight.OutlineColor = newColor

        textLabel.TextColor3 = newColor
    end

    function ESPManager.Destroy()
        if ESPManager.RSConnection then
            ESPManager.RSConnection:Disconnect()
        end

        if ESPManager.IsEntity and ESPManager.Object and ESPManager.Object.PrimaryPart then
            ESPManager.Object.PrimaryPart.Transparency = ESPManager.Object.PrimaryPart:GetAttribute("Transparency")
        end

        if highlight then highlight:Destroy() end
        if billboardGui then billboardGui:Destroy() end

        if Script.ESPTable[ESPManager.Type][tableIndex] then
            Script.ESPTable[ESPManager.Type][tableIndex] = nil
        end
    end

    ESPManager.RSConnection = RunService.RenderStepped:Connect(function()
        if not ESPManager.Object or not ESPManager.Object:IsDescendantOf(workspace) then
            ESPManager.Destroy()
            return
        end

        highlight.Enabled = Toggles.ESPHighlight.Value
        highlight.FillTransparency = Options.ESPFillTransparency.Value
        highlight.OutlineTransparency = Options.ESPOutlineTransparency.Value
        textLabel.TextSize = Options.ESPTextSize.Value
    end)

    Script.ESPTable[ESPManager.Type][tableIndex] = ESPManager
    return ESPManager
end

function Script.Functions.DoorESP(room)
    local door = room:WaitForChild("door")
    local locked = room:GetAttribute("RequiresKey")

    if door and not door:GetAttribute("Opened") then
        local doorEsp = Script.Functions.ESP({
            Type = "Door",
            Object = door:WaitForChild("Door"),
            Text = locked and string.format("Door %s [Locked]", room.Name + 1) or string.format("Door %s", room.Name + 1),
            Color = Options.DoorEspColor.Value
        })

        door:GetAttributeChangedSignal("Opened"):Connect(function()
            doorEsp.Destroy()
        end)
    end
end 

function Script.Functions.ObjectiveESP(room)
    if room:GetAttribute("RequiresKey") then
        local key = room:FindFirstChild("KeyModel", true)

        if key then
            Script.Functions.ESP({
                Type = "Objective",
                Object = key,
                Text = string.format("Key %s", room.Name + 1),
                Color = Options.ObjectiveEspColor.Value
            })
        end
    elseif room:GetAttribute("RequiresGenerator") then
        local generator = room:FindFirstChild("MinesGenerator", true)
        local gateButton = room:FindFirstChild("MinesGateButton", true)

        if generator then
            Script.Functions.ESP({
                Type = "Objective",
                Object = generator,
                Text = "Generator",
                Color = Options.ObjectiveEspColor.Value
            })
        end

        if gateButton then
            Script.Functions.ESP({
                Type = "Objective",
                Object = gateButton,
                Text = "Gate Power Button",
                Color = Options.ObjectiveEspColor.Value
            })
        end
    end
end

function Script.Functions.EntityESP(entity)
    Script.Functions.ESP({
        Type = "Entity",
        Object = entity,
        Text = Script.Functions.GetShortName(entity.Name),
        Color = Options.EntityEspColor.Value,
        IsEntity = entity.Name ~= "JeffTheKiller",
    })
end

function Script.Functions.ItemESP(item)
    Script.Functions.ESP({
        Type = "Item",
        Object = item,
        Text = Script.Functions.GetShortName(item.Name),
        Color = Options.ItemEspColor.Value
    })
end

function Script.Functions.GoldESP(gold)
    Script.Functions.ESP({
        Type = "Gold",
        Object = gold,
        Text = string.format("Gold [%s]", gold:GetAttribute("GoldValue")),
        Color = Options.GoldEspColor.Value
    })
end

function Script.Functions.RoomESP(room)
    local waitLoad = room:GetAttribute("RequiresGenerator") == true or room.Name == "50"

    if Toggles.DoorESP.Value then
        Script.Functions.DoorESP(room)
    end
    
    if Toggles.ObjectiveESP.Value then
        task.delay(waitLoad and 3 or 1, Script.Functions.ObjectiveESP, room)
    end
end

function Script.Functions.ObjectiveESPCheck(child)
    if child.Name == "LiveHintBook" then
        Script.Functions.ESP({
            Type = "Objective",
            Object = child,
            Text = "Book",
            Color = Options.ObjectiveEspColor.Value
        })
    elseif child.Name == "FuseObtain" then
        Script.Functions.ESP({
            Type = "Objective",
            Object = child,
            Text = "Fuse",
            Color = Options.ObjectiveEspColor.Value
        })
    elseif child.Name == "MinesAnchor" then
        local sign = child:WaitForChild("Sign", 5)

        if sign and sign:FindFirstChild("TextLabel") then
            Script.Functions.ESP({
                Type = "Objective",
                Object = child,
                Text = string.format("Anchor %s", sign.TextLabel.Text),
                Color = Options.ObjectiveEspColor.Value
            })
        end
    end
end

function Script.Functions.PromptCondition(prompt)
    local modelAncestor = prompt:FindFirstAncestorOfClass("Model")
    return 
        prompt:IsA("ProximityPrompt") and (
            not table.find(PromptTable.Excluded.Prompt, prompt.Name) 
            and not table.find(PromptTable.Excluded.Parent, prompt.Parent and prompt.Parent.Name or "") 
            and not (table.find(PromptTable.Excluded.ModelAncestor, modelAncestor and modelAncestor.Name or ""))
        )
end

function Script.Functions.ChildCheck(child)
    if Script.Functions.PromptCondition(child) then
        task.defer(function()
            if not child:GetAttribute("Hold") then child:SetAttribute("Hold", child.HoldDuration) end
            if not child:GetAttribute("Distance") then child:SetAttribute("Distance", child.MaxActivationDistance) end
            if not child:GetAttribute("Enabled") then child:SetAttribute("Enabled", child.Enabled) end
            if not child:GetAttribute("Clip") then child:SetAttribute("Clip", child.RequiresLineOfSight) end
        end)

        task.defer(function()
            child.MaxActivationDistance = child:GetAttribute("Distance") * Options.PromptReachMultiplier.Value
    
            if Toggles.InstaInteract.Value then
                child.HoldDuration = 0
            end
    
            if Toggles.PromptClip.Value and Script.Functions.PromptCondition(child) then
                child.RequiresLineOfSight = false
            end
        end)

        table.insert(PromptTable.GamePrompts, child)
    end

    if Toggles.AutoInteract.Value and (Library.IsMobile or Options.AutoInteractKey:GetState()) then
        local prompts = Script.Functions.GetAllPromptsWithCondition(function(prompt)
            if isRetro and prompt.Parent.Parent.Name == "RetroWardrobe" then
                return false
            end

            return PromptTable.Aura[prompt.Name] ~= nil
        end)

        for _, prompt: ProximityPrompt in pairs(prompts) do
            if not prompt.Parent then continue end
            if prompt.Parent:GetAttribute("JeffShop") then continue end
            if prompt.Parent:GetAttribute("PropType") == "Battery" and ((character:FindFirstChildOfClass("Tool") and character:FindFirstChildOfClass("Tool"):GetAttribute("RechargeProp") ~= "Battery") or character:FindFirstChildOfClass("Tool") == nil) then continue end 
            if prompt.Parent:GetAttribute("PropType") == "Heal" and humanoid and humanoid.Health == humanoid.MaxHealth then continue end

            task.spawn(function()
                -- checks if distance can interact with prompt and if prompt can be interacted again
                if Script.Functions.DistanceFromCharacter(prompt.Parent) < prompt.MaxActivationDistance and (not prompt:GetAttribute("Interactions" .. localPlayer.Name) or PromptTable.Aura[prompt.Name] or table.find(PromptTable.AuraObjects, prompt.Parent.Name)) then
                    -- painting checks
                    if prompt.Parent.Name == "Slot" and prompt.Parent:GetAttribute("Hint") and character then
                        if Script.Temp.PaintingDebounce then return end
                        
                        local currentPainting = character:FindFirstChild("Prop")
                        if not currentPainting and prompt.Parent:FindFirstChild("Prop") and prompt.Parent:GetAttribute("Hint") ~= prompt.Parent.Prop:GetAttribute("Hint") then
                            return firePrompt(prompt)
                        end

                        if prompt.Parent:FindFirstChild("Prop") then 
                            if prompt.Parent:GetAttribute("Hint") == prompt.Parent.Prop:GetAttribute("Hint") then
                                return
                            end
                        end

                        if prompt.Parent:GetAttribute("Hint") == currentPainting:GetAttribute("Hint") then
                            Script.Temp.PaintingDebounce = true

                            local oldHint = currentPainting:GetAttribute("Hint")
                            repeat task.wait()
                                firePrompt(prompt)
                            until not character:FindFirstChild("Prop") or character:FindFirstChild("Prop"):GetAttribute("Hint") ~= oldHint

                            task.wait(0.15)
                            Script.Temp.PaintingDebounce = false
                        end                            
                        
                        return
                    end
                    
                    firePrompt(prompt)
                end
            end)
        end
    end

    if child:IsA("Model") then
        if (child:GetAttribute("Pickup") or child:GetAttribute("PropType")) and not child:GetAttribute("FuseID") then
            if Toggles.ItemESP.Value then
                Script.Functions.ItemESP(child)
            end
        end

        if child.Name == "GiggleCeiling" and Toggles.AntiGiggle.Value then
            child:WaitForChild("Hitbox", 5).CanTouch = false
        end

        if child.Name == "GoldPile_Medium" or child.Name == "GoldPile_Large" or child.Name == "GoldPile_Big" or child.Name == "GoldPile_Small" or child.Name == "GoldPile_Worthless" or child.Name == "GoldPile_Bar" or child.Name == "GoldPile_VeryLarge" and Toggles.GoldESP.Value then
            Script.Functions.GoldESP(child)
        end
    elseif child:IsA("BasePart") then
        if child.Name == "Egg" and Toggles.AntiGloomEgg.Value then
            child.CanTouch = false
        end
    end

    if includeESP then
        if Toggles.ObjectiveESP.Value then
            task.spawn(Script.Functions.ObjectiveESPCheck, child)
        end
    end

    if Toggles.EntityESP.Value then
        if table.find(SideEntityName, child.Name) then
            if not child.PrimaryPart then
                local waiting = 0

                repeat
                    waiting += task.wait()
                until child.PrimaryPart or waiting > 3
            end

            Script.Functions.ESP({
                Type = "Entity",
                Object = child,
                Text = Script.Functions.GetShortName(child.Name),
                TextParent = child.PrimaryPart,
                Color = Options.EntityEspColor.Value
            })
        end
    end
end

function Script.Functions.SetupRoomConnection(room)
    for _, child in pairs(room:GetDescendants()) do
        task.spawn(Script.Functions.ChildCheck, child, false)
    end

    room.DescendantAdded:Connect(function(child)
        task.delay(0.1, Script.Functions.ChildCheck, child, true)
    end)
end

function Script.Functions.SetupCharacterConnection(newCharacter)
    character = newCharacter

    humanoid = character:WaitForChild("Humanoid")

    rootPart = character:WaitForChild("HumanoidRootPart")
end

function Script.Functions.GetShortName(entityName: string)
    if ShortNames[entityName] then
        return ShortNames[entityName]
    end

    return tostring(entityName):gsub("Backdoor", ""):gsub("Ceiling", ""):gsub("Moving", ""):gsub("_Modifier", ""):gsub("Ragdoll", ""):gsub("Rig", ""):gsub("Wall", ""):gsub("Pack", " Pack")
end

function Script.Functions.DistanceFromCharacter(position: Instance | Vector3)
    if typeof(position) == "Instance" then
        position = position:GetPivot().Position
    end

    return (rootPart.Position - position).Magnitude
end

function Script.Functions.Alert(message: string, time_obj: number)
    Library:Notify(message, time_obj or 5)

    if Toggles.NotifySound.Value then
        local sound = Instance.new("Sound", workspace) do
            sound.SoundId = "rbxassetid://4590662766"
            sound.Volume = 2
            sound.PlayOnRemove = true
            sound:Destroy()
        end
    end
end

--// Main \\--
 
print("reached main")

local AutomationGroupBox = Tabs.Main:AddRightGroupbox("Automation") do
    AutomationGroupBox:AddToggle("AutoInteract", {
        Text = "Auto Interact",
        Default = false
    }):AddKeyPicker("AutoInteractKey", {
        Mode = Library.IsMobile and "Toggle" or "Hold",
        Default = "R",
        Text = "Auto Interact",
        SyncToggleState = Library.IsMobile
    })
end

local PlayerGroupBox = Tabs.Main:AddLeftGroupbox("Player") do
    PlayerGroupBox:AddToggle("Noclip", {
        Text = "Noclip",
        Default = false
    })

    PlayerGroupBox:AddToggle("InstaInteract", {
        Text = "Instant Interact",
        Default = false
    })
end

local  ReachGroupBox = Tabs.Main:AddLeftGroupbox("Reach") do
	ReachGroupBox:AddToggle("PromptClip", {
        Text = "Prompt Clip",
        Default = false
    })

    ReachGroupBox:AddSlider("PromptReachMultiplier", {
        Text = "Prompt Reach Multiplier",
        Default = 1,
        Min = 1,
        Max = 2,
        Rounding = 1
    })
end

local MiscGroupBox = Tabs.Main:AddRightGroupbox("Misc") do
    MiscGroupBox:AddButton({
        Text = "Respawn Character",
        Func = function()
            remotesFolder.Respawn:FireServer()
        end,
        DoubleClick = true
    })
end

--// Exploits \\--

local AntiEntityGroupBox = Tabs.Exploits:AddLeftGroupbox("Anti-Entity") do
    AntiEntityGroupBox:AddToggle("AntiHalt", {
        Text = "Anti-Halt",
        Default = false
    })

    AntiEntityGroupBox:AddToggle("AntiScreech", {
        Text = "Anti-Screech",
        Default = false
    })

    AntiEntityGroupBox:AddToggle("AntiA90", {
            Text = "Anti-A90",
            Default = false
    })
end


--// Visuals \\--

local ESPGroupBox = Tabs.Visuals:AddLeftGroupbox("ESP") do
    ESPGroupBox:AddToggle("DoorESP", {
        Text = "Door",
        Default = false,
    }):AddColorPicker("DoorEspColor", {
        Default = Color3.new(0, 1, 1),
    })

    ESPGroupBox:AddToggle("ObjectiveESP", {
        Text = "Objective",
        Default = false,
    }):AddColorPicker("ObjectiveEspColor", {
        Default = Color3.new(0, 1, 0),
    })

    ESPGroupBox:AddToggle("EntityESP", {
        Text = "Entity",
        Default = false,
    }):AddColorPicker("EntityEspColor", {
        Default = Color3.new(1, 0, 0),
    })

    ESPGroupBox:AddToggle("ItemESP", {
        Text = "Item",
        Default = false,
    }):AddColorPicker("ItemEspColor", {
        Default = Color3.new(1, 0, 1),
    })

    ESPGroupBox:AddToggle("GoldESP", {
        Text = "Gold",
        Default = false,
    }):AddColorPicker("GoldEspColor", {
        Default = Color3.new(1, 1, 0),
    })
end

local ESPSettingsGroupBox = Tabs.Visuals:AddLeftGroupbox("ESP Settings") do
    ESPSettingsGroupBox:AddToggle("ESPHighlight", {
        Text = "Enable Highlight",
        Default = true,
    })

    ESPSettingsGroupBox:AddSlider("ESPFillTransparency", {
        Text = "Fill Transparency",
        Default = 0.75,
        Min = 0,
        Max = 1,
        Rounding = 2
    })

    ESPSettingsGroupBox:AddSlider("ESPOutlineTransparency", {
        Text = "Outline Transparency",
        Default = 0,
        Min = 0,
        Max = 1,
        Rounding = 2
    })

    ESPSettingsGroupBox:AddSlider("ESPTextSize", {
        Text = "Text Size",
        Default = 22,
        Min = 16,
        Max = 26,
        Rounding = 0
    })
end

local AmbientGroupBox = Tabs.Visuals:AddRightGroupbox("Ambient") do
    AmbientGroupBox:AddToggle("Fullbright", {
        Text = "Fullbright",
        Default = false,
    })
end

local NotifyTabBox = Tabs.Visuals:AddRightTabbox() do
    local NotifyTab = NotifyTabBox:AddTab("Notifier") do
        NotifyTab:AddToggle("NotifyEntity", {
            Text = "Notify Entity",
            Default = false,
        })
    end

    local NotifySettingsTab = NotifyTabBox:AddTab("Settings") do
        NotifySettingsTab:AddToggle("NotifySound", {
            Text = "Play Alert Sound",
            Default = true,
        })

        NotifySettingsTab:AddDropdown("NotifySide", {
            AllowNull = false,
            Values = {"Left", "Right"},
            Default = "Right",
            Multi = false,

            Text = "Notification Side"
        })
    end
end



--// Floor \\--
do
    if isMines then
        local Mines_MovementGroupBox = Tabs.Floor:AddLeftGroupbox("Movement") do
            Mines_MovementGroupBox:AddToggle("FastLadder", {
                Text = "Fast Ladder",
                Default = false
            })
        end

        local Mines_AntiEntityGroupBox = Tabs.Floor:AddLeftGroupbox("Anti-Entity") do
            Mines_AntiEntityGroupBox:AddToggle("AntiGiggle", {
                Text = "Anti-Giggle",
                Default = false
            })

            Mines_AntiEntityGroupBox:AddToggle("AntiGloomEgg", {
                Text = "Anti-GloomEgg",
                Default = false
            })
        end
        

        Toggles.AntiGiggle:OnChanged(function(value)
            for _, room in pairs(workspace.CurrentRooms:GetChildren()) do
                for _, giggle in pairs(room:GetChildren()) do
                    if giggle.Name == "GiggleCeiling" then
                        giggle:WaitForChild("Hitbox", 5).CanTouch = not value
                    end
                end
            end
        end)

        -- this shits bad, but it doesnt go through all parts, so its optimized :cold_face:
        Toggles.AntiGloomEgg:OnChanged(function(value)
            for _, room in pairs(workspace.CurrentRooms:GetChildren()) do
                for _, gloomPile in pairs(room:GetChildren()) do
                    if gloomPile.Name == "GloomPile" then
                        for _, gloomEgg in pairs(gloomPile:GetDescendants()) do
                            if gloomEgg.Name == "Egg" then
                                gloomEgg.CanTouch = not value
                            end
                        end
                    end
                end
            end
        end)
    end
end

--// Features Callback \\--

Toggles.InstaInteract:OnChanged(function(value)
    for _, prompt in pairs(workspace.CurrentRooms:GetDescendants()) do
        if prompt:IsA("ProximityPrompt") then
            if value then
                if not prompt:GetAttribute("Hold") then prompt:SetAttribute("Hold", prompt.HoldDuration) end
                prompt.HoldDuration = 0
            else
                prompt.HoldDuration = prompt:GetAttribute("Hold") or 0
            end
        end
    end
end)

Toggles.PromptClip:OnChanged(function(value)
    for _, prompt in pairs(workspace.CurrentRooms:GetDescendants()) do        
        if Script.Functions.PromptCondition(prompt) then
            if value then
                prompt.RequiresLineOfSight = false
            else
                if prompt:GetAttribute("Enabled") and prompt:GetAttribute("Clip") then
                    prompt.Enabled = prompt:GetAttribute("Enabled")
                    prompt.RequiresLineOfSight = prompt:GetAttribute("Clip")
                end
            end
        end
    end
end)

Options.PromptReachMultiplier:OnChanged(function(value)
    for _, prompt in pairs(workspace.CurrentRooms:GetDescendants()) do
        if Script.Functions.PromptCondition(prompt) then
            if not prompt:GetAttribute("Distance") then prompt:SetAttribute("Distance", prompt.MaxActivationDistance) end

            prompt.MaxActivationDistance = prompt:GetAttribute("Distance") * value
        end
    end
end)

Toggles.AntiHalt:OnChanged(function(value)
    if not entityModules then return end
    local module = entityModules:FindFirstChild("Shade") or entityModules:FindFirstChild("_Shade")

    if module then
        module.Name = value and "_Shade" or "Shade"
    end
end)

Toggles.AntiScreech:OnChanged(function(value)
    if not mainGame then return end
    local module = mainGame:FindFirstChild("Screech", true) or mainGame:FindFirstChild("_Screech", true)

    if module then
        module.Name = value and "_Screech" or "Screech"
    end
end)

Toggles.AntiA90:OnChanged(function(value)
    if not mainGame then return end
    local module = mainGame:FindFirstChild("A90", true) or mainGame:FindFirstChild("_A90", true)

    if module then
        module.Name = value and "_A90" or "A90"
    end
end)

Options.NotifySide:OnChanged(function(value)
    print("changing to side", value)
    Library.NotifySide = value
end)


Toggles.DoorESP:OnChanged(function(value)
    if value then
        for _, room in pairs(workspace.CurrentRooms:GetChildren()) do
            Script.Functions.DoorESP(room)
        end
    else
        for _, esp in pairs(Script.ESPTable.Door) do
            esp.Destroy()
        end
    end
end)

Options.DoorEspColor:OnChanged(function(value)
    for _, esp in pairs(Script.ESPTable.Door) do
        esp.SetColor(value)
    end
end)

Toggles.ObjectiveESP:OnChanged(function(value)
    if value then
        for _, room in pairs(workspace.CurrentRooms:GetChildren()) do
            task.spawn(Script.Functions.ObjectiveESP, room)
            
            for _, child in pairs(room:GetDescendants()) do
                task.spawn(Script.Functions.ObjectiveESPCheck, child)
            end
        end
    else
        for _, esp in pairs(Script.ESPTable.Objective) do
            esp.Destroy()
        end
    end
end)

Options.ObjectiveEspColor:OnChanged(function(value)
    for _, esp in pairs(Script.ESPTable.Objective) do
        esp.SetColor(value)
    end
end)

Toggles.EntityESP:OnChanged(function(value)
    if value then
        for _, entity in pairs(workspace.CurrentRooms:GetDescendants()) do
            if table.find(SideEntityName, entity.Name) then
                Script.Functions.ESP({
                    Type = "Entity",
                    Object = entity,
                    Text = Script.Functions.GetShortName(entity.Name),
                    TextParent = entity.PrimaryPart,
                    Color = Options.EntityEspColor.Value
                })
            end
        end
    else
        for _, esp in pairs(Script.ESPTable.Entity) do
            esp.Destroy()
        end
    end
end)

Options.EntityEspColor:OnChanged(function(value)
    for _, esp in pairs(Script.ESPTable.Entity) do
        esp.SetColor(value)
    end
end)

Toggles.ItemESP:OnChanged(function(value)
    if value then
        for _, item in pairs(workspace.CurrentRooms:GetDescendants()) do
            if item:IsA("Model") and (item:GetAttribute("Pickup") or item:GetAttribute("PropType")) and not item:GetAttribute("FuseID") then
                Script.Functions.ItemESP(item)
            end
        end
    else
        for _, esp in pairs(Script.ESPTable.Item) do
            esp.Destroy()
        end
    end
end)

Options.ItemEspColor:OnChanged(function(value)
    for _, esp in pairs(Script.ESPTable.Item) do
        esp.SetColor(value)
    end
end)

Toggles.GoldESP:OnChanged(function(value)
    if value then
        for _, gold in pairs(workspace.CurrentRooms:GetDescendants()) do
            if gold.Name == "GoldPile_Medium" or gold.Name == "GoldPile_Large" or gold.Name == "GoldPile_Big" or gold.Name == "GoldPile_Small" or gold.Name == "GoldPile_Worthless" or gold.Name == "GoldPile_Bar" or gold.Name == "GoldPile_VeryLarge" then
                Script.Functions.GoldESP(gold)
            end
        end
    else
        for _, esp in pairs(Script.ESPTable.Gold) do
            esp.Destroy()
        end
    end
end)

Options.GoldEspColor:OnChanged(function(value)
    for _, esp in pairs(Script.ESPTable.Gold) do
        esp.SetColor(value)
    end
end)

Toggles.Fullbright:OnChanged(function(value)
    if value then
        Lighting.Ambient = Color3.new(1, 1, 1)
    else
        if alive then
            Lighting.Ambient = workspace.CurrentRooms[localPlayer:GetAttribute("CurrentRoom")]:GetAttribute("Ambient")
        else
            Lighting.Ambient = Color3.new(0, 0, 0)
        end
    end
end)

--// Connections \\--

Library:GiveSignal(workspace.ChildAdded:Connect(function(child)
    task.delay(0.1, function()
        if table.find(EntityName, child.Name) then
            task.spawn(function()
                repeat
                    task.wait()
                until Script.Functions.DistanceFromCharacter(child) < 2000 or not child:IsDescendantOf(workspace)

                if child:IsDescendantOf(workspace) then
                    local entityName = Script.Functions.GetShortName(child)

                    if Toggles.EntityESP.Value then
                        Script.Functions.EntityESP(child)  
                    end

                    if Toggles.NotifyEntity.Value then
                        Script.Functions.Alert(entityName .. " has spawned!")
                    end
                end
            end)
        end
    end)
end))

for _, room in pairs(workspace.CurrentRooms:GetChildren()) do
    task.spawn(Script.Functions.SetupRoomConnection, room)
end
Library:GiveSignal(workspace.CurrentRooms.ChildAdded:Connect(function(room)
    task.spawn(Script.Functions.SetupRoomConnection, room)
    task.spawn(Script.Functions.RoomESP, room)
end))

Library:GiveSignal(localPlayer.CharacterAdded:Connect(function(newCharacter)
    task.delay(1, Script.Functions.SetupCharacterConnection, newCharacter)
end))

Library:GiveSignal(localPlayer:GetAttributeChangedSignal("Alive"):Connect(function()
    alive = localPlayer:GetAttribute("Alive")
end))

Library:GiveSignal(playerGui.ChildAdded:Connect(function(child)
    if child.Name == "MainUI" then
        mainUI = child

        task.delay(1, function()
            if mainUI then
                mainGame = mainUI:WaitForChild("Initiator"):WaitForChild("Main_Game")

                if mainGame then
                    mainGameSrc = require(mainGame)
                    if not mainGame:WaitForChild("RemoteListener", 5) then return end

                    if Toggles.AntiScreech.Value then
                        local module = modules:FindFirstChild("Screech", true)

                        if module then
                            module.Name = "_Screech"
                        end
                    end
								
                    if (isHotel or isRooms) and Toggles.AntiA90.Value then
                        local module = modules:FindFirstChild("A90", true)

                        if module then
                            module.Name = "_A90"
                        end
                    end
                end
            end
        end)
    end
end))

Library:GiveSignal(Lighting:GetPropertyChangedSignal("Ambient"):Connect(function()
    if Toggles.Fullbright.Value then
        Lighting.Ambient = Color3.new(1, 1, 1)
    end

    if rootPart then
        rootPart.CanCollide = not Toggles.Noclip.Value
    end

    if collision then
        collision.CanCollide = not Toggles.Noclip.Value
        if collision:FindFirstChild("CollisionCrouch") then
            collision.CollisionCrouch.CanCollide = not Toggles.Noclip.Value
        end
    end

    if character:FindFirstChild("UpperTorso") then
        character.UpperTorso.CanCollide = not Toggles.Noclip.Value
    end
    
    if character:FindFirstChild("LowerTorso") then
        character.LowerTorso.CanCollide = not Toggles.Noclip.Value
    end
end))

--// Script Load \\--

task.spawn(Script.Functions.SetupCharacterConnection, character)

--// Library Load \\--

Library:OnUnload(function()
    if character then
        character:SetAttribute("SpeedBoostBehind", 0)
    end

    if alive then
        Lighting.Ambient = workspace.CurrentRooms[localPlayer:GetAttribute("CurrentRoom")]:GetAttribute("Ambient")
    else
        Lighting.Ambient = Color3.new(0, 0, 0)
    end

    if entityModules then
        local module = entityModules:FindFirstChild("_Shade")

        if module then
            module.Name = "Shade"
        end
    end

    if mainGame then
        local module = mainGame:FindFirstChild("_Screech", true)

        if module then
            module.Name = "Screech"
        end
    end

    if collision then
        collision.CanCollide = not mainGameSrc.crouching
        if collision:FindFirstChild("CollisionCrouch") then
            collision.CollisionCrouch.CanCollide = mainGameSrc.crouching
        end
    end

    collisionClone:Destroy()

    for _, espType in pairs(Script.ESPTable) do
        for _, esp in pairs(espType) do
            esp.Destroy()
        end
    end

    for _, connection in pairs(Script.Connections) do
        connection:Disconnect()
    end

	print("Unloaded!")
	Library.Unloaded = true
end)

local MenuGroup = Tabs["UI Settings"]:AddLeftGroupbox("Menu")

MenuGroup:AddButton("Unload", function() Library:Unload() end)
MenuGroup:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", { Default = "RightShift", NoUI = true, Text = "Menu keybind" })

Library.ToggleKeybind = Options.MenuKeybind

ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)

SaveManager:IgnoreThemeSettings()

SaveManager:SetIgnoreIndexes({ "MenuKeybind" })

ThemeManager:SetFolder("doorsrooms")
SaveManager:SetFolder("doorsrooms/rooms")

SaveManager:BuildConfigSection(Tabs["UI Settings"])

ThemeManager:ApplyToTab(Tabs["UI Settings"])

SaveManager:LoadAutoloadConfig()
