-- NEON HUB MOBILE - ORIGINAL LAYOUT + FLY FIX + PLAYER TP
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local lp = Players.LocalPlayer

-- --- 1. FLY CONTROL PANEL ---
local flyGui = Instance.new("ScreenGui", game.CoreGui)
flyGui.Name = "FlyControlPanel"
flyGui.Enabled = false 

local FFrame = Instance.new("Frame", flyGui)
FFrame.Size = UDim2.new(0, 200, 0, 110)
FFrame.Position = UDim2.new(0.1, 0, 0.5, 0)
FFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
FFrame.Active = true
Instance.new("UICorner", FFrame)
local stroke = Instance.new("UIStroke", FFrame)
stroke.Color = Color3.fromRGB(0, 170, 255)
stroke.Thickness = 2

local function MobileBtn(txt, pos, size, color, parent)
    local b = Instance.new("TextButton", parent)
    b.Text = txt; b.Position = pos; b.Size = size
    b.BackgroundColor3 = color; b.TextColor3 = Color3.new(1,1,1)
    b.Font = "SourceSansBold"; b.TextSize = 16
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 5)
    return b
end

local flyToggle = MobileBtn("FLY: OFF", UDim2.new(0.05, 0, 0.25, 0), UDim2.new(0.6, 0, 0, 30), Color3.fromRGB(40, 40, 40), FFrame)
local speedShow = Instance.new("TextLabel", FFrame)
speedShow.Text = "SPD: 50"; speedShow.Size = UDim2.new(0.3, 0, 0, 30); speedShow.Position = UDim2.new(0.65, 0, 0.25, 0)
speedShow.TextColor3 = Color3.fromRGB(0, 170, 255); speedShow.BackgroundTransparency = 1; speedShow.Font = "SourceSansBold"

local up = MobileBtn("▲", UDim2.new(0.05, 0, 0.6, 0), UDim2.new(0.2, 0, 0, 30), Color3.fromRGB(30, 30, 30), FFrame)
local down = MobileBtn("▼", UDim2.new(0.28, 0, 0.6, 0), UDim2.new(0.2, 0, 0, 30), Color3.fromRGB(30, 30, 30), FFrame)
local add = MobileBtn("+", UDim2.new(0.51, 0, 0.6, 0), UDim2.new(0.2, 0, 0, 30), Color3.fromRGB(30, 30, 30), FFrame)
local sub = MobileBtn("-", UDim2.new(0.74, 0, 0.6, 0), UDim2.new(0.2, 0, 0, 30), Color3.fromRGB(30, 30, 30), FFrame)
local closeF = MobileBtn("X", UDim2.new(0.8,0,-0.3,0), UDim2.new(0,30,0,30), Color3.fromRGB(200, 0, 0), FFrame)

-- Fly Logic (Fixed for Mobile Joystick, Removed 0.1 drift)
local isFlying, flySpeed, bv, bg = false, 50, nil, nil
flyToggle.Activated:Connect(function()
    isFlying = not isFlying
    flyToggle.Text = isFlying and "FLY: ON" or "FLY: OFF"
    flyToggle.BackgroundColor3 = isFlying and Color3.fromRGB(0, 170, 255) or Color3.fromRGB(40, 40, 40)
    if isFlying then
        local char = lp.Character or lp.CharacterAdded:Wait()
        bv = Instance.new("BodyVelocity", char.HumanoidRootPart); bv.MaxForce = Vector3.new(1e6, 1e6, 1e6)
        bg = Instance.new("BodyGyro", char.HumanoidRootPart); bg.MaxTorque = Vector3.new(1e6, 1e6, 1e6); bg.P = 9000
        task.spawn(function()
            while isFlying and char and char:FindFirstChild("Humanoid") do
                RunService.Heartbeat:Wait()
                local cam = workspace.CurrentCamera
                local moveDir = char.Humanoid.MoveDirection
                
                if moveDir.Magnitude > 0 then
                    -- Proper Mobile Joystick Directional Math
                    local camLook = cam.CFrame.LookVector
                    local camRight = cam.CFrame.RightVector
                    
                    local flatLook = Vector3.new(camLook.X, 0, camLook.Z).Unit
                    local flatRight = Vector3.new(camRight.X, 0, camRight.Z).Unit
                    
                    if flatLook.Magnitude == 0 then flatLook = Vector3.new(0, 0, -1) end
                    if flatRight.Magnitude == 0 then flatRight = Vector3.new(1, 0, 0) end
                    
                    local fwd = moveDir:Dot(flatLook)
                    local right = moveDir:Dot(flatRight)
                    
                    local finalDir = (camLook * fwd) + (camRight * right)
                    bv.Velocity = finalDir.Unit * flySpeed
                else
                    -- Changed to exactly zero to remove any stutter/drift
                    bv.Velocity = Vector3.new(0, 0, 0) 
                end
                bg.CFrame = cam.CFrame
            end
            if bv then bv:Destroy() end; if bg then bg:Destroy() end
        end)
    else
        if bv then bv:Destroy() end; if bg then bg:Destroy() end
    end
end)

add.Activated:Connect(function() flySpeed = flySpeed + 10; speedShow.Text = "SPD: "..flySpeed end)
sub.Activated:Connect(function() flySpeed = math.max(10, flySpeed - 10); speedShow.Text = "SPD: "..flySpeed end)
up.Activated:Connect(function() if isFlying then lp.Character.HumanoidRootPart.CFrame *= CFrame.new(0, 5, 0) end end)
down.Activated:Connect(function() if isFlying then lp.Character.HumanoidRootPart.CFrame *= CFrame.new(0, -5, 0) end end)
closeF.Activated:Connect(function() flyGui.Enabled = false end)

-- --- 2. NEON HUB MAIN MENU ---
local neonGui = Instance.new("ScreenGui", game.CoreGui)
local MFrame = Instance.new("Frame", neonGui)
MFrame.Size = UDim2.new(0, 260, 0, 330); MFrame.Position = UDim2.new(0.5, -130, 0.5, -165); MFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15); Instance.new("UICorner", MFrame)
local mStroke = Instance.new("UIStroke", MFrame); mStroke.Color = Color3.fromRGB(0, 170, 255); mStroke.Thickness = 1

local function Drag(g)
    local d, s, sp; g.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1 then d = true; s = i.Position; sp = g.Position end end)
    UserInputService.InputChanged:Connect(function(i) if d and (i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseMovement) then local delta = i.Position - s; g.Position = UDim2.new(sp.X.Scale, sp.X.Offset + delta.X, sp.Y.Scale, sp.Y.Offset + delta.Y) end end)
    g.InputEnded:Connect(function() d = false end)
end
Drag(MFrame); Drag(FFrame)

local MainTab = Instance.new("ScrollingFrame", MFrame); MainTab.Size = UDim2.new(1,0,1,-70); MainTab.Position = UDim2.new(0,0,0,70); MainTab.BackgroundTransparency = 1; MainTab.ScrollBarThickness = 2

local function HubBtn(name, parent, pos, callback)
    local b = MobileBtn(name, UDim2.new(0.05, 0, 0, pos), UDim2.new(0.9, 0, 0, 35), Color3.fromRGB(30, 30, 30), parent)
    b.Activated:Connect(function() callback(b) end)
    return b
end

HubBtn("Open Fly Panel", MainTab, 10, function() flyGui.Enabled = true end)

HubBtn("Noclip: OFF", MainTab, 55, function(b) 
    _G.noclip = not _G.noclip
    b.Text = _G.noclip and "Noclip: ON" or "Noclip: OFF"
    b.TextColor3 = _G.noclip and Color3.new(0,1,0) or Color3.new(1,1,1)
end)

HubBtn("Fullbright: OFF", MainTab, 100, function(b) 
    _G.fb = not _G.fb
    b.Text = _G.fb and "Fullbright: ON" or "Fullbright: OFF"
    b.TextColor3 = _G.fb and Color3.new(0,1,0) or Color3.new(1,1,1)
end)

-- --- ADDED PLAYER TP FEATURE ---
local tpBox = Instance.new("TextBox", MainTab)
tpBox.Size = UDim2.new(0.9, 0, 0, 30)
tpBox.Position = UDim2.new(0.05, 0, 0, 145)
tpBox.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
tpBox.TextColor3 = Color3.new(1,1,1)
tpBox.PlaceholderText = "Enter Player Name"
tpBox.Font = "SourceSansBold"
tpBox.TextSize = 14
Instance.new("UICorner", tpBox).CornerRadius = UDim.new(0, 5)

HubBtn("Teleport To Player", MainTab, 185, function()
    local targetName = tpBox.Text:lower()
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= lp and (p.Name:lower():sub(1, #targetName) == targetName or p.DisplayName:lower():sub(1, #targetName) == targetName) then
            if lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                lp.Character.HumanoidRootPart.CFrame = p.Character.HumanoidRootPart.CFrame
            end
            break
        end
    end
end)

-- --- LOOPS ---
RunService.RenderStepped:Connect(function()
    if _G.fb then 
        Lighting.Ambient = Color3.new(1,1,1)
        Lighting.OutdoorAmbient = Color3.new(1,1,1)
        Lighting.Brightness = 2
        Lighting.ClockTime = 14 
    end
end)

RunService.Stepped:Connect(function()
    if _G.noclip and lp.Character then
        for _, v in pairs(lp.Character:GetDescendants()) do 
            if v:IsA("BasePart") then v.CanCollide = false end 
        end
    end
end)

local ToggleBtn = MobileBtn("H", UDim2.new(0, 10, 0.4, 0), UDim2.new(0, 55, 0, 55), Color3.fromRGB(0, 170, 255), neonGui)
Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(1,0); Drag(ToggleBtn)
ToggleBtn.Activated:Connect(function() MFrame.Visible = not MFrame.Visible end)
