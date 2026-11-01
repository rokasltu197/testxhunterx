-- ============================ YOUR APP CODE ============================
local Window = OrionLib:MakeWindow({
	Name = "Dragon Blox Full 2 V1.11",
	HidePremium = false,
	SaveConfig = true,
	ConfigFolder = "TeleportConfig"
})

local Tab = Window:MakeTab({Name = "Great Premium", Icon = "rbxassetid://4483345998", PremiumOnly = false})
local Tab1 = Window:MakeTab({Name = "Auto Farm👑", Icon = "rbxassetid://4483345998", PremiumOnly = false})
local Tab2 = Window:MakeTab({Name = "Dungeon", Icon = "rbxassetid://4483345998", PremiumOnly = false})
local Tab3 = Window:MakeTab({Name = "Auto Skill", Icon = "rbxassetid://4483345998", PremiumOnly = false})
local Tab4 = Window:MakeTab({Name = "Anti lag", Icon = "rbxassetid://4483345998", PremiumOnly = false})

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local Player = Players.LocalPlayer

-- =========================================================
-- NEW FEATURES FROM YOUR NEW SCRIPT
-- =========================================================

local KillCount = 0
local KillLabel = Tab:AddLabel("Great Droid Kills: 0")

task.spawn(function()
    local LastDead = false
    while task.wait(0.5) do
        local Boss = workspace:FindFirstChild("World Mobs")
            and workspace["World Mobs"]:FindFirstChild("Event Mobs")
            and workspace["World Mobs"]["Event Mobs"]:FindFirstChild("Great Droid")

        if Boss then
            local Humanoid = Boss:FindFirstChildOfClass("Humanoid")
            if Humanoid then
                if Humanoid.Health <= 0 then
                    if not LastDead then
                        LastDead = true
                        KillCount = KillCount + 1
                        KillLabel:Set("Great Droid Kills: "..KillCount)
                    end
                else
                    LastDead = false
                end
            end
        end
    end
end)

Tab:AddToggle({
    Name = "Auto Play Again",
    Default = false,
    Callback = function(Value)
        getgenv().AutoPlayAgain = Value
        task.spawn(function()
            while getgenv().AutoPlayAgain do
                task.wait(7.8)
                local atom = workspace:FindFirstChild("World Mobs")
                atom = atom and atom:FindFirstChild("Event Mobs")
                atom = atom and atom:FindFirstChild("Great Droid")

                local dead = false
                if atom and atom:FindFirstChild("Humanoid") then
                    if atom.Humanoid.Health <= 0 then dead = true end
                else
                    dead = true
                end

                if dead then
                    pcall(function()
                        game:GetService("ReplicatedStorage")
                        .Packages._Index["sleitnick_knit@1.4.7"]
                        .knit.Services.DungeonLobbyService.RF.StartDungeon
                        :InvokeServer()
                    end)
                end
            end
        end)
    end
})

local SelectedTool = 2
local AutoEquipTools = false

Tab:AddDropdown({
    Name = "Auto equiptools dls",
    Default = "2",
    Options = {"1","2","3","4","5","6"},
    Callback = function(Value) SelectedTool = tonumber(Value) end
})

Tab:AddToggle({
    Name = "Auto EquipTools",
    Default = false,
    Callback = function(Value)
        AutoEquipTools = Value
        if Value then
            task.spawn(function()
                while AutoEquipTools do
                    local args = { SelectedTool }
                    pcall(function()
                        game:GetService("ReplicatedStorage")
                        :WaitForChild("Packages"):WaitForChild("_Index")
                        :WaitForChild("sleitnick_knit@1.4.7"):WaitForChild("knit")
                        :WaitForChild("Services"):WaitForChild("ToolService")
                        :WaitForChild("RE"):WaitForChild("UpdatePlayerToolbarSelection")
                        :FireServer(unpack(args))
                    end)
                    task.wait(0.1)
                end
            end)
        end
    end
})

local AutoGodmode = false
local HEIGHT_ABOVE = 9.22

Tab:AddToggle({
    Name = "Auto Skill + Godmode V2 (Chạy Liên Tục)",
    Default = false,
    Callback = function(Value)
        AutoGodmode = Value
        if Value then
            task.spawn(function()
                while AutoGodmode do
                    local character = Player.Character
                    local hrp = character and character:FindFirstChild("HumanoidRootPart")
                    local bossFolder = workspace:FindFirstChild("World Mobs") and workspace["World Mobs"]:FindFirstChild("Event Mobs")
                    
                    if hrp and bossFolder then
                        local closestBoss, closestDist = nil, math.huge
                        for _, mob in ipairs(bossFolder:GetChildren()) do
                            local humanoid = mob:FindFirstChild("Humanoid")
                            local root = mob:FindFirstChild("HumanoidRootPart")
                            if root and humanoid and humanoid.Health > 0 then
                                local dist = (hrp.Position - root.Position).Magnitude
                                if dist < closestDist then closestDist = dist; closestBoss = mob end
                            end
                        end
                        
                        if closestBoss and closestBoss:FindFirstChild("HumanoidRootPart") then
                            local bossHRP = closestBoss.HumanoidRootPart
                            local targetPos = bossHRP.Position + Vector3.new(0, HEIGHT_ABOVE, 0)
                            hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                            
                            local tween = TweenService:Create(hrp, TweenInfo.new(0.22, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
                                CFrame = CFrame.new(targetPos, bossHRP.Position)
                            })
                            tween:Play()
                        end
                    end
                    task.wait()
                end
            end)
        end
    end
})

local AutoLoc = false
Tab:AddToggle({
    Name = "Auto Lộc",
    Default = false,
    Callback = function(Value)
        AutoLoc = Value
        if Value then
            task.spawn(function()
                while AutoLoc do
                    local GreatDroid = workspace:FindFirstChild("World Mobs") and workspace["World Mobs"]:FindFirstChild("Event Mobs") and workspace["World Mobs"]["Event Mobs"]:FindFirstChild("Great Droid")
                    if GreatDroid then
                        pcall(function()
                            game:GetService("ReplicatedStorage").Packages._Index["sleitnick_knit@1.4.7"].knit.Services.SkillManager.RE.LockedOnChanged:FireServer(GreatDroid)
                        end)
                    end
                    task.wait(0.1)
                end
            end)
        end
    end
})

local AutoSkillXanh = false
Tab:AddToggle({
    Name = "Auto Skill Xanh",
    Default = false,
    Callback = function(Value)
        AutoSkillXanh = Value
        if Value then
            task.spawn(function()
                while AutoSkillXanh do
                    local args = {
                        "Weapons_22_2",
                        {
                            targetPos = vector.create(1204.772705078125, 2011.405029296875, 744.3994750976562),
                            PauseTimeFrame = 0.016666666666666666,
                            animationInstance = game:GetService("ReplicatedStorage").Assets.SkillsV2.Weapons["SSJG Legend Weapon"].Animations["Double Wild Cannon"],
                            animationSpeed = 1,
                            ResumeOnTimePassed = 1,
                            HumCFrame = CFrame.new(1241.96044921875, 2020.822021484375, 823.090087890625, 0.9039086103439331, -0.06293655186891556, 0.4230699837207794, -7.279183478203777e-09, 0.989115297794342, 0.14714235067367554, -0.4277256429195404, -0.13300324976444244, 0.8940698504447937)
                        },
                        12,
                        true
                    }
                    pcall(function()
                        game:GetService("ReplicatedStorage").Packages._Index["sleitnick_knit@1.4.7"].knit.Services.SkillManagerV2.RE.ExecuteSkill:FireServer(unpack(args))
                        args[4] = false
                        game:GetService("ReplicatedStorage").Packages._Index["sleitnick_knit@1.4.7"].knit.Services.SkillManagerV2.RE.ExecuteSkill:FireServer(unpack(args))
                    end)
                    task.wait()
                end
            end)
        end
    end
})

local AutoKillScroid = false
Tab:AddToggle({
    Name = "Auto kill scroid",
    Default = false,
    Callback = function(Value)
        AutoKillScroid = Value
        if Value then
            task.spawn(function()
                while AutoKillScroid do
                    local customMob = workspace:FindFirstChild("World Mobs") and workspace["World Mobs"]:FindFirstChild("Event Mobs") and workspace["World Mobs"]["Event Mobs"]:FindFirstChild("CustomMob")
                    if customMob and customMob.PrimaryPart then
                        local mobPos = customMob.PrimaryPart.Position
                        pcall(function()
                            ReplicatedStorage.Packages._Index["sleitnick_knit@1.4.7"].knit.Services.SkillManager.RE.LockedOnChanged:FireServer(customMob)
                            ReplicatedStorage.Remotes.SkillRemote:FireServer({Camera = CFrame.lookAt(mobPos + Vector3.new(0, 15, 0), mobPos), SkillId = "101", Began = true, CFrame = CFrame.lookAt(mobPos + Vector3.new(0, 5, 0), mobPos), ["Typ\208\181"] = 1, Aim = mobPos})
                        end)
                    end
                    task.wait(0.1)
                end
            end)
        end
    end
})

local AutoDanh = false
Tab:AddToggle({
    Name = "Auto đánh",
    Default = false,
    Callback = function(Value)
        AutoDanh = Value
        if Value then
            task.spawn(function()
                while AutoDanh do
                    local args = {
                        {
                            Camera = CFrame.new(1345.49853515625, 600.545654296875, -2916.877197265625, -0.21036981046199799, -0.36530575156211853, 0.9068055748939514, 0, 0.9275626540184021, 0.37366774678230286, -0.977621853351593, 0.07860841602087021, -0.19513118267059326),
                            SkillId = "1",
                            Began = true,
                            CFrame = CFrame.new(1334.1634521484375, 594.4747924804688, -2914.43798828125, -0.3630794882774353, 6.794644491492363e-08, 0.9317581653594971, -1.2599003618163351e-08, 1, -7.783230415725484e-08, -0.9317581653594971, -3.9998539591579174e-08, -0.3630794882774353),
                            ["Typ\208\181"] = 1,
                            Aim = Vector3.new(1287.5755615234375, 594.4747924804688, -2896.283935546875)
                        }
                    }
                    pcall(function()
                        game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("SkillRemote"):FireServer(unpack(args))
                    end)
                    task.wait(0.1)
                end
            end)
        end
    end
})

local AutoEnergyBallGreta = false
Tab:AddToggle({
    Name = "Auto enery ball Greta",
    Default = false,
    Callback = function(Value)
        AutoEnergyBallGreta = Value
        if Value then
            task.spawn(function()
                while AutoEnergyBallGreta do
                    local args = {
                        {
                            Camera = CFrame.new(1134.539794921875, 2026.8126220703125, 878.4974975585938, -0.9346979260444641, -0.11704222112894058, 0.33562028408050537, 0, 0.9442304968833923, 0.32928532361984253, -0.35544317960739136, 0.3077823221683502, -0.8825702667236328),
                            SkillId = "101",
                            Began = true,
                            CFrame = CFrame.new(1125.9349365234375, 2018.352783203125, 903.3755493164062, 0.04905059188604355, -0.003960008732974529, -0.9987884163856506, -0.009050008840858936, 0.9999493360519409, -0.004409058019518852, 0.9987552762031555, 0.009255310520529747, 0.04901226609945297),
                            ["Typ\208\181"] = 1,
                            Aim = Vector3.new(1175.8743896484375, 2018.5732421875, 900.9249267578125)
                        }
                    }
                    pcall(function()
                        game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("SkillRemote"):FireServer(unpack(args))
                    end)
                    task.wait(0.15)
                end
            end)
        end
    end
})

local AutoNextArea = false
Tab:AddToggle({
    Name = "Auto Next Area",
    Default = false,
    Callback = function(Value)
        AutoNextArea = Value
        if Value then
            task.spawn(function()
                while AutoNextArea do
                    pcall(function()
                        workspace:WaitForChild("Dungeon"):WaitForChild("Stages"):WaitForChild("0"):WaitForChild("NextArea"):WaitForChild("DungeonNextAreaPad"):WaitForChild("RE"):WaitForChild("Interact"):FireServer(true)
                    end)
                    task.wait(0.1)
                end
            end)
        end
    end
})

-- =========================================================
-- ORIGINAL FEATURES (Auto Farm Tab)
-- =========================================================

local BossFolder = workspace["World Mobs"]["Boss Mobs"]

local AutoMeta = false
local AutoPainsHurts = false
local AutoZero = false
local AutoPickup = false
local FloatEnabled = false
local FloatConnection, BV

local MetaTween, PainsHurtsTween, ZeroTween = nil, nil, nil
local TweenSpeed = 200

Tab1:AddToggle({ Name = "Auto set Meta", Default = false, Callback = function(Value)
    AutoMeta = Value
    if not Value and MetaTween then pcall(function() MetaTween:Cancel() end) MetaTween = nil end
end })

Tab1:AddToggle({ Name = "Auto Pains + Hurts", Default = false, Callback = function(Value)
    AutoPainsHurts = Value
    if not Value and PainsHurtsTween then pcall(function() PainsHurtsTween:Cancel() end) PainsHurtsTween = nil end
end })

Tab1:AddToggle({ Name = "Auto set Zero", Default = false, Callback = function(Value)
    AutoZero = Value
    if not Value and ZeroTween then pcall(function() ZeroTween:Cancel() end) ZeroTween = nil end
end })

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
    local Tween = TweenService:Create(Root, TweenInfo.new(Duration, Enum.EasingStyle.Linear), {CFrame = TargetCFrame})
    if CurrentTweenName == "Meta" then MetaTween = Tween
    elseif CurrentTweenName == "PainsHurts" then PainsHurtsTween = Tween
    elseif CurrentTweenName == "Zero" then ZeroTween = Tween end
    Tween:Play()
    while IsEnabled() and Tween.PlaybackState == Enum.PlaybackState.Playing do
        if not Root.Parent or Player.Character ~= Root.Parent then pcall(function() Tween:Cancel() end) return false, nil end
        task.wait()
    end
    if not IsEnabled() then pcall(function() Tween:Cancel() end) return false, nil end
    if Root.Parent and Player.Character == Root.Parent then Root.CFrame = TargetCFrame end
    return true, nil
end

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
            else task.wait(0.2) end
        else task.wait(0.2) end
    end
end)

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
            else task.wait(0.2) end
        else task.wait(0.2) end
    end
end)

task.spawn(function()
    local TargetPosition = CFrame.new(2204.00586, 45.5981483, -4348.96826, 1,0,0, 0,1,0, 0,0,1)
    while true do
        if not AutoZero then task.wait(0.2) continue end
        local Root = GetRoot()
        local Distance = (Root.Position - TargetPosition.Position).Magnitude
        if Distance > 3 then TweenTo(TargetPosition, "Zero", function() return AutoZero end) end
        task.wait(0.5)
    end
end)

Tab1:AddToggle({ Name = "Auto pickup Support Farm full set", Default = false, Callback = function(Value)
    AutoPickup = Value
    if Value then
        task.spawn(function()
            while AutoPickup do
                local Root = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
                if Root then
                    for _, v in ipairs(workspace:GetDescendants()) do
                        if not AutoPickup then break end
                        if v:IsA("ProximityPrompt") then
                            local Part = v.Parent
                            if Part and Part:IsA("BasePart") and (Root.Position - Part.Position).Magnitude <= 100 then fireproximityprompt(v) end
                        end
                    end
                end
                task.wait(0.1)
            end
        end)
    end
end })

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
        if FloatEnabled and BV and BV.Parent and Root.Parent then BV.Velocity = Vector3.zero end
    end)
end

Tab1:AddToggle({ Name = "Anti Fall Support Tween", Default = false, Callback = function(Value)
    FloatEnabled = Value
    if Value then
        local Character = Player.Character
        if Character then setupFloat(Character) end
    else removeFloat() end
end })

Player.CharacterAdded:Connect(function(Character)
    task.wait(0.5)
    if FloatEnabled then setupFloat(Character) end
end)

OrionLib:Init()
