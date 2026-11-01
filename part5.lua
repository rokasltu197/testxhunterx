-- ============================ YOUR APP CODE ============================
local Window = OrionLib:MakeWindow({
    Name = "Dragon Blox Full 2 V1.11",
    HidePremium = false,
    SaveConfig = true,
    ConfigFolder = "TeleportConfig"
})

local Tab  = Window:MakeTab({Name = "Smart+Anti Band", Icon = "rbxassetid://4483345998", PremiumOnly = false})
local Tab1 = Window:MakeTab({Name = "Auto Farm👑", Icon = "rbxassetid://4483345998", PremiumOnly = false})
local Tab2 = Window:MakeTab({Name = "Dungeon", Icon = "rbxassetid://4483345998", PremiumOnly = false})
local Tab3 = Window:MakeTab({Name = "Auto Skill", Icon = "rbxassetid://4483345998", PremiumOnly = false})
local Tab4 = Window:MakeTab({Name = "Anti lag", Icon = "rbxassetid://4483345998", PremiumOnly = false})

local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")

local Player = Players.LocalPlayer
local BossFolder = workspace["World Mobs"]["Boss Mobs"]

local AutoMeta = false
local AutoPainsHurts = false
local AutoZero = false

local MetaTween = nil
local PainsHurtsTween = nil
local ZeroTween = nil

local TweenSpeed = 200

-- =========================================================
-- NÚT ORION LIB
-- =========================================================

Tab1:AddToggle({
    Name = "Auto set Meta",
    Default = false,
    Save = true,
    Flag = "AutoMeta",
    Callback = function(Value)
        AutoMeta = Value
        if not Value and MetaTween then
            pcall(function() MetaTween:Cancel() end)
            MetaTween = nil
        end
    end
})

Tab1:AddToggle({
    Name = "Auto Pains + Hurts",
    Default = false,
    Save = true,
    Flag = "AutoPainsHurts",
    Callback = function(Value)
        AutoPainsHurts = Value
        if not Value and PainsHurtsTween then
            pcall(function() PainsHurtsTween:Cancel() end)
            PainsHurtsTween = nil
        end
    end
})

Tab1:AddToggle({
    Name = "Auto set Zero",
    Default = false,
    Save = true,
    Flag = "AutoZero",
    Callback = function(Value)
        AutoZero = Value
        if not Value and ZeroTween then
            pcall(function() ZeroTween:Cancel() end)
            ZeroTween = nil
        end
    end
})

-- =========================================================
-- HÀM TWEEN CHUNG
-- =========================================================

local function GetRoot()
    local Character = Player.Character
    if not Character then Character = Player.CharacterAdded:Wait() end
    return Character:WaitForChild("HumanoidRootPart")
end

local function TweenTo(TargetCFrame, CurrentTweenName, IsEnabled)
    local Root = GetRoot()
    local Distance = (Root.Position - TargetCFrame.Position).Magnitude
    local Duration = Distance / TweenSpeed

    if Duration < 0.1 then
        if IsEnabled() then Root.CFrame = TargetCFrame end
        return true, nil
    end

    local Tween = TweenService:Create(
        Root,
        TweenInfo.new(Duration, Enum.EasingStyle.Linear),
        {CFrame = TargetCFrame}
    )

    if CurrentTweenName == "Meta" then MetaTween = Tween
    elseif CurrentTweenName == "PainsHurts" then PainsHurtsTween = Tween
    elseif CurrentTweenName == "Zero" then ZeroTween = Tween end

    Tween:Play()

    while IsEnabled() and Tween.PlaybackState == Enum.PlaybackState.Playing do
        if not Root.Parent or Player.Character ~= Root.Parent then
            pcall(function() Tween:Cancel() end)
            return false, nil
        end
        task.wait()
    end

    if not IsEnabled() then
        pcall(function() Tween:Cancel() end)
        return false, nil
    end

    if Root.Parent and Player.Character == Root.Parent then
        Root.CFrame = TargetCFrame
    end

    return true, nil
end

-- =========================================================
-- AUTO META
-- =========================================================

task.spawn(function()
    local CurrentIndex = 1
    local BossData = {
        {Name = "Meta Chromest", Position = CFrame.new(-2949.98657, 44.359993, 113.719284, 1,0,0, 0,1,0, 0,0,1)},
        {Name = "Meta Coolest",  Position = CFrame.new(-1997.33386, 80.0019531, -2640.44287, 1,0,0, 0,1,0, 0,0,1)},
        {Name = "Meta Amythest", Position = CFrame.new(1344.54321, 75.0019531, -2866.45361, 1,0,0, 0,1,0, 0,0,1)}
    }

    while true do
        if not AutoMeta then task.wait(0.2) continue end

        local Data = BossData[CurrentIndex]
        local Root = GetRoot()
        local Distance = (Root.Position - Data.Position.Position).Magnitude

        if Distance > 3 then
            local Success = TweenTo(Data.Position, "Meta", function() return AutoMeta end)
            if not Success then task.wait(0.2) continue end
        end

        local Boss = BossFolder:FindFirstChild(Data.Name)
        if Boss then
            local Humanoid = Boss:FindFirstChildOfClass("Humanoid")
            if Humanoid and Humanoid.Health <= 0 then
                task.wait(2)
                if AutoMeta then
                    CurrentIndex += 1
                    if CurrentIndex > #BossData then CurrentIndex = 1 end
                end
            else
                task.wait(0.2)
            end
        else
            task.wait(0.2)
        end
    end
end)

-- =========================================================
-- AUTO PAINS + HURTS
-- =========================================================

task.spawn(function()
    local CurrentIndex = 1
    local BossData = {
        {Name = "Pains", Position = CFrame.new(5435.41064, 502.409637, 741.838013, 1,0,0, 0,1,0, 0,0,1)},
        {Name = "Hurts", Position = CFrame.new(2733.07642, 101.598831, 426.639465, 1,0,0, 0,1,0, 0,0,1)}
    }

    while true do
        if not AutoPainsHurts then task.wait(0.2) continue end

        local Data = BossData[CurrentIndex]
        local Root = GetRoot()
        local Distance = (Root.Position - Data.Position.Position).Magnitude

        if Distance > 3 then
            local Success = TweenTo(Data.Position, "PainsHurts", function() return AutoPainsHurts end)
            if not Success then task.wait(0.2) continue end
        end

        local Boss = BossFolder:FindFirstChild(Data.Name)
        if Boss then
            local Humanoid = Boss:FindFirstChildOfClass("Humanoid")
            if Humanoid and Humanoid.Health <= 0 then
                task.wait(2)
                if AutoPainsHurts then
                    CurrentIndex += 1
                    if CurrentIndex > #BossData then CurrentIndex = 1 end
                end
            else
                task.wait(0.2)
            end
        else
            task.wait(0.2)
        end
    end
end)

-- =========================================================
-- AUTO ZERO
-- =========================================================

task.spawn(function()
    local TargetPosition = CFrame.new(2204.00586, 45.5981483, -4348.96826, 1,0,0, 0,1,0, 0,0,1)

    while true do
        if not AutoZero then task.wait(0.2) continue end
        local Root = GetRoot()
        local Distance = (Root.Position - TargetPosition.Position).Magnitude
        if Distance > 3 then
            TweenTo(TargetPosition, "Zero", function() return AutoZero end)
        end
        task.wait(0.5)
    end
end)

-- =========================================================
-- AUTO PICKUP
-- =========================================================
local AutoPickup = false

Tab1:AddToggle({
    Name = "Auto pickup Support Farm full set",
    Default = false,
    Save = true,
    Callback = function(Value)
        AutoPickup = Value
        if Value then
            task.spawn(function()
                while AutoPickup do
                    local Player = game.Players.LocalPlayer
                    local Character = Player.Character
                    local Root = Character and Character:FindFirstChild("HumanoidRootPart")
                    if Root then
                        for _, v in ipairs(workspace:GetDescendants()) do
                            if not AutoPickup then break end
                            if v:IsA("ProximityPrompt") then
                                local Part = v.Parent
                                if Part and Part:IsA("BasePart") then
                                    if (Root.Position - Part.Position).Magnitude <= 100 then
                                        fireproximityprompt(v)
                                    end
                                end
                            end
                        end
                    end
                    task.wait(0.1)
                end
            end)
        end
    end
})

OrionLib:Init()

-- =========================================================
-- ANTI FALL
-- =========================================================
local RunService = game:GetService("RunService")
local FloatEnabled = false
local FloatConnection
local BV

local function removeFloat()
    if FloatConnection then FloatConnection:Disconnect() FloatConnection = nil end
    if BV then BV:Destroy() BV = nil end
end

local function setupFloat(Character)
    removeFloat()
    local Root = Character:WaitForChild("HumanoidRootPart", 5)
    if not Root then return end
    BV = Instance.new("BodyVelocity")
    BV.Name = "ContinuousFloat"
    BV.MaxForce = Vector3.new(0, math.huge, 0)
    BV.Velocity = Vector3.zero
    BV.Parent = Root
    FloatConnection = RunService.Heartbeat:Connect(function()
        if FloatEnabled and BV and BV.Parent and Root.Parent then
            BV.Velocity = Vector3.zero
        end
    end)
end

Tab1:AddToggle({
    Name = "Anti Fall Support Tween",
    Default = false,
    Save = true,
    Callback = function(Value)
        FloatEnabled = Value
        if Value then
            local Character = Player.Character
            if Character then setupFloat(Character) end
        else
            removeFloat()
        end
    end
})

Player.CharacterAdded:Connect(function(Character)
    task.wait(0.5)
    if FloatEnabled then setupFloat(Character) end
end)

OrionLib:Init()

-- =========================================================
-- TIME STOP BUTTON
-- =========================================================
local RS = game:GetService("ReplicatedStorage")
local LP = Players.LocalPlayer

local Gui = Instance.new("ScreenGui")
Gui.Name = "Skill126Gui"
Gui.ResetOnSpawn = false
Gui.Enabled = false
Gui.Parent = LP:WaitForChild("PlayerGui")

local SkillButton = Instance.new("TextButton")
SkillButton.Name = "Skill126Button"
SkillButton.Size = UDim2.new(0, 150, 0, 50)
SkillButton.Position = UDim2.new(0.5, -75, 0.8, 0)
SkillButton.BackgroundTransparency = 0.1
SkillButton.Text = "Time stop"
SkillButton.TextSize = 18
SkillButton.TextColor3 = Color3.new(1, 1, 1)
SkillButton.Parent = Gui

local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 8)
Corner.Parent = SkillButton

SkillButton.MouseButton1Click:Connect(function()
    local args = {
        {
            Camera = CFrame.new(
                74.2727279663086, 251.0009002685547, -28.747745513916016,
                -0.9511321783065796, -0.044049736112356186, 0.3056260347366333,
                0, 0.9897724390029907, 0.14265543222427368,
                -0.308784157037735, 0.13568417727947235, -0.9414043426513672
            ),
            SkillId = "126",
            Began = true,
            CFrame = CFrame.new(70.45240020751953, 247.81771850585938, -16.98019027709961, 1,0,0, 0,1,0, 0,0,1),
            ["Typ\208\181"] = 1,
            Aim = vector.create(70.45240020751953, 247.81771850585938, -66.98019409179688)
        }
    }
    RS:WaitForChild("Remotes"):WaitForChild("SkillRemote"):FireServer(unpack(args))
end)

Tab1:AddToggle({
    Name = "Time stop wis",
    Default = false,
    Callback = function(Value) Gui.Enabled = Value end
})

OrionLib:Init()

-- =========================================================
-- AUTO M1
-- =========================================================
local AutoSkill = false

Tab:AddToggle({
    Name = "Auto M1",
    Default = false,
    Save = true,
    Callback = function(Value)
        AutoSkill = Value
        if Value then
            task.spawn(function()
                while AutoSkill do
                    local args = {
                        [1] = {
                            ["Camera"] = CFrame.new(
                                1436.56982421875, 610.5719604492188, -2926.40576171875,
                                0.4276675879955292, 0.8082790374755859, -0.404704213142395,
                                0, 0.44771331548690796, 0.8941771984100342,
                                0.9039360880851746, -0.38241061568260193, 0.19147247076034546
                            ),
                            ["SkillId"] = "1",
                            ["Began"] = true,
                            ["CFrame"] = CFrame.new(
                                1441.628662109375, 597.61474609375, -2928.799072265625,
                                0.4534393846988678, -9.274389611846345e-08, -0.891287088394165,
                                2.6512436690495633e-08, 1, -9.056802241502737e-08,
                                0.891287088394165, 1.7436915911162032e-08, 0.4534393846988678
                            ),
                            ["Typ\208\181"] = 1,
                            ["Aim"] = Vector3.new(1486.1929931640625, 597.61474609375, -2951.470947265625)
                        }
                    }
                    game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("SkillRemote"):FireServer(unpack(args))
                    task.wait(0.151)
                end
            end)
        end
    end
})

OrionLib:Init()

-- =========================================================
-- AURA KILL ENERGY BLAST V2
-- =========================================================
local WorldMobs = workspace:WaitForChild("World Mobs")
local SkillRemote = game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("SkillRemote")

local AuraEnabled = false

local function GetRandomMob()
    local Character = Player.Character
    local Root = Character and Character:FindFirstChild("HumanoidRootPart")
    if not Root then return nil end

    local Mobs = {}
    for _, Mob in ipairs(WorldMobs:GetDescendants()) do
        if Mob:IsA("Model") then
            local Humanoid = Mob:FindFirstChildOfClass("Humanoid")
            local MobRoot = Mob:FindFirstChild("HumanoidRootPart")
                or Mob.PrimaryPart
                or Mob:FindFirstChildWhichIsA("BasePart")
            if Humanoid and MobRoot and Humanoid.Health > 0 then
                local Distance = (Root.Position - MobRoot.Position).Magnitude
                if Distance <= 400 then
                    table.insert(Mobs, Mob)
                end
            end
        end
    end
    if #Mobs > 0 then return Mobs[math.random(1, #Mobs)] end
    return nil
end

Tab:AddToggle({
    Name = "Aura Kill Energy Blast V2",
    Default = false,
    Callback = function(Value)
        AuraEnabled = Value
        if AuraEnabled then
            task.spawn(function()
                while AuraEnabled do
                    task.wait(0.16)
                    local Character = Player.Character
                    local Root = Character and Character:FindFirstChild("HumanoidRootPart")
                    if Root then
                        local RandomMob = GetRandomMob()
                        if RandomMob then
                            local MobRoot = RandomMob:FindFirstChild("HumanoidRootPart")
                                or RandomMob.PrimaryPart
                                or RandomMob:FindFirstChildWhichIsA("BasePart")
                            if MobRoot then
                                local TargetPosition = MobRoot.Position
                                local SkillCFrame = CFrame.lookAt(
                                    Root.Position,
                                    Vector3.new(TargetPosition.X, Root.Position.Y, TargetPosition.Z)
                                )
                                local args = {
                                    [1] = {
                                        ["Camera"] = CFrame.lookAt(workspace.CurrentCamera.CFrame.Position, TargetPosition),
                                        ["SkillId"] = "101",
                                        ["Began"] = true,
                                        ["CFrame"] = SkillCFrame,
                                        ["Typ\208\181"] = 1,
                                        ["Aim"] = TargetPosition
                                    }
                                }
                                SkillRemote:FireServer(unpack(args))
                            end
                        end
                    end
                end
            end)
        end
    end
})

-- =========================================================
-- AUTO LOCK RANDOM MOB
-- =========================================================
local LockedOnChanged = game:GetService("ReplicatedStorage")
    :WaitForChild("Packages")
    :WaitForChild("_Index")
    :WaitForChild("sleitnick_knit@1.4.7")
    :WaitForChild("knit")
    :WaitForChild("Services")
    :WaitForChild("SkillManager")
    :WaitForChild("RE")
    :WaitForChild("LockedOnChanged")

local AutoLockRandomMob = false

local function GetRandomMobLock()
    local Character = Player.Character
    local Root = Character and Character:FindFirstChild("HumanoidRootPart")
    if not Root then return nil end

    local ValidMobs = {}
    for _, Mob in ipairs(WorldMobs:GetDescendants()) do
        if Mob:IsA("Model") then
            local Humanoid = Mob:FindFirstChildOfClass("Humanoid")
            local MobRoot = Mob:FindFirstChild("HumanoidRootPart")
                or Mob.PrimaryPart
                or Mob:FindFirstChildWhichIsA("BasePart")
            if Humanoid and MobRoot and Humanoid.Health > 0 then
                local Distance = (Root.Position - MobRoot.Position).Magnitude
                if Distance <= 400 then
                    table.insert(ValidMobs, Mob)
                end
            end
        end
    end
    if #ValidMobs > 0 then return ValidMobs[math.random(1, #ValidMobs)] end
    return nil
end

Tab:AddToggle({
    Name = "Auto Lock Random Mob",
    Default = false,
    Callback = function(Value)
        AutoLockRandomMob = Value
        if Value then
            task.spawn(function()
                while AutoLockRandomMob do
                    local RandomMob = GetRandomMobLock()
                    if RandomMob then
                        LockedOnChanged:FireServer(RandomMob)
                    end
                    task.wait(0.4)
                end
            end)
        end
    end
})

-- =========================================================
-- AUTO KILL ZAJA
-- =========================================================
local EventMobs = WorldMobs:WaitForChild("Event Mobs")

local AutoZaja = false
local CurrentTween = nil

local function GetZaja()
    local Zaja = EventMobs:FindFirstChild("Zaja")
    if not Zaja then return nil end
    local Humanoid = Zaja:FindFirstChildOfClass("Humanoid")
    local Root = Zaja:FindFirstChild("HumanoidRootPart")
        or Zaja.PrimaryPart
        or Zaja:FindFirstChildWhichIsA("BasePart")
    if not Humanoid or not Root or Humanoid.Health <= 0 then return nil end
    return Zaja, Humanoid, Root
end

local function GetDistancePosition(PlayerRoot, ZajaRoot)
    local Direction = PlayerRoot.Position - ZajaRoot.Position
    if Direction.Magnitude <= 0.1 then
        Direction = Vector3.new(0, 0, 1)
    else
        Direction = Direction.Unit
    end
    local Position = ZajaRoot.Position + (Direction * 500)
    return CFrame.lookAt(
        Position,
        Vector3.new(ZajaRoot.Position.X, Position.Y, ZajaRoot.Position.Z)
    )
end

local function TweenToZaja(PlayerRoot, ZajaRoot)
    if CurrentTween then
        CurrentTween:Cancel()
        CurrentTween = nil
    end
    local TargetCFrame = GetDistancePosition(PlayerRoot, ZajaRoot)
    local Distance = (PlayerRoot.Position - TargetCFrame.Position).Magnitude
    local Time = Distance / 220
    CurrentTween = TweenService:Create(
        PlayerRoot,
        TweenInfo.new(math.max(Time, 0.05), Enum.EasingStyle.Linear),
        {CFrame = TargetCFrame}
    )
    CurrentTween:Play()
end

Tab1:AddToggle({
    Name = "Auto kill Zaja",
    Default = false,
    Callback = function(Value)
        AutoZaja = Value
        if not Value then
            if CurrentTween then
                CurrentTween:Cancel()
                CurrentTween = nil
            end
            return
        end

        -- Luồng di chuyển
        task.spawn(function()
            while AutoZaja do
                local Character = Player.Character
                local PlayerRoot = Character and Character:FindFirstChild("HumanoidRootPart")
                local Zaja, Humanoid, ZajaRoot = GetZaja()
                if PlayerRoot and Zaja and Humanoid.Health > 0 then
                    local Distance = (PlayerRoot.Position - ZajaRoot.Position).Magnitude
                    if math.abs(Distance - 500) > 25 then
                        TweenToZaja(PlayerRoot, ZajaRoot)
                    end
                else
                    if CurrentTween then
                        CurrentTween:Cancel()
                        CurrentTween = nil
                    end
                end
                task.wait(0.3)
            end
        end)

        -- Luồng LockOn
        task.spawn(function()
            while AutoZaja do
                local Zaja = GetZaja()
                if Zaja then
                    LockedOnChanged:FireServer(Zaja)
                end
                task.wait(0.2)
            end
        end)

        -- Luồng bắn Skill 101
        task.spawn(function()
            while AutoZaja do
                local Character = Player.Character
                local PlayerRoot = Character and Character:FindFirstChild("HumanoidRootPart")
                local Zaja, Humanoid, ZajaRoot = GetZaja()
                if PlayerRoot and Zaja and ZajaRoot then
                    local TargetPosition = ZajaRoot.Position
                    local args = {
                        [1] = {
                            ["Camera"] = CFrame.lookAt(workspace.CurrentCamera.CFrame.Position, TargetPosition),
                            ["SkillId"] = "101",
                            ["Began"] = true,
                            ["CFrame"] = CFrame.lookAt(
                                PlayerRoot.Position,
                                Vector3.new(TargetPosition.X, PlayerRoot.Position.Y, TargetPosition.Z)
                            ),
                            ["Typ\208\181"] = 1,
                            ["Aim"] = TargetPosition
                        }
                    }
                    SkillRemote:FireServer(unpack(args))
                end
                task.wait(0.18)
            end
        end)
    end
})
