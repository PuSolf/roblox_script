-- [[ Solf Hub ]] --
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local camera = Workspace.CurrentCamera

-- ========================================================
-- BIẾN CẤU HÌNH CAMERA VÀ SCRIPT UTILITIES
-- ========================================================
local cameraRotationX = 0
local cameraRotationY = 0
local targetRotationX = 0
local targetRotationY = 0

local cameraDistance = 15 
local cameraConnection = nil

-- CẤU HÌNH ĐỘ NHẠY VÀ ĐỘ MƯỢT (Logic gốc của bạn)
local CAMERA_SENSITIVITY = 0.9 
local SMOOTHNESS = 0.8 

local bypassSpeedEnabled = false
local speedMultiplier = 2.0 
local speedConnection = nil

local cframeJumpEnabled = false
local jumpBoostForce = 2.0 

local brightEnabled = false
local originalAmbient = Lighting.Ambient
local originalOutdoorAmbient = Lighting.OutdoorAmbient

-- ========================================================
-- 1. TẠO GIAO DIỆN MENU TRÊN MOBILE & GIẢ LẬP
-- ========================================================
local PlayerGui = player:FindFirstChildOfClass("PlayerGui") or player:WaitForChild("PlayerGui")

if PlayerGui:FindFirstChild("SolfHub") then
    PlayerGui["SolfHub"]:Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SolfHub"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = PlayerGui

local MenuFrame = Instance.new("Frame")
MenuFrame.Size = UDim2.new(0, 220, 0, 325) 
MenuFrame.Position = UDim2.new(0.1, 0, 0.2, 0)
MenuFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
MenuFrame.Active = true
MenuFrame.Draggable = true 
MenuFrame.Parent = ScreenGui

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 30)
Title.Text = "Solf Hub"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
Title.Parent = MenuFrame

-- [UI TỐC ĐỘ]
local ToggleButton = Instance.new("TextButton")
ToggleButton.Size = UDim2.new(0.9, 0, 0, 35)
ToggleButton.Position = UDim2.new(0.05, 0, 0, 40)
ToggleButton.Text = "Bypass Speed: OFF"
ToggleButton.BackgroundColor3 = Color3.fromRGB(70, 30, 30)
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.Parent = MenuFrame

local SpeedLabel = Instance.new("TextLabel")
SpeedLabel.Size = UDim2.new(0.9, 0, 0, 25)
SpeedLabel.Position = UDim2.new(0.05, 0, 0, 80)
SpeedLabel.Text = "Speed Multiplier: 2.0x"
SpeedLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
SpeedLabel.BackgroundTransparency = 1
SpeedLabel.Parent = MenuFrame

local MinusButton = Instance.new("TextButton")
MinusButton.Size = UDim2.new(0.4, 0, 0, 30)
MinusButton.Position = UDim2.new(0.05, 0, 0, 105)
MinusButton.Text = "-"
MinusButton.TextSize = 20
MinusButton.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
MinusButton.TextColor3 = Color3.fromRGB(255, 255, 255)
MinusButton.Parent = MenuFrame

local PlusButton = Instance.new("TextButton")
PlusButton.Size = UDim2.new(0.4, 0, 0, 30)
PlusButton.Position = UDim2.new(0.55, 0, 0, 105)
PlusButton.Text = "+"
PlusButton.TextSize = 20
PlusButton.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
PlusButton.TextColor3 = Color3.fromRGB(255, 255, 255)
PlusButton.Parent = MenuFrame

-- [UI NHẢY CAO]
local ToggleJumpButton = Instance.new("TextButton")
ToggleJumpButton.Size = UDim2.new(0.9, 0, 0, 35)
ToggleJumpButton.Position = UDim2.new(0.05, 0, 0, 150)
ToggleJumpButton.Text = "Nhảy CFrame: OFF"
ToggleJumpButton.BackgroundColor3 = Color3.fromRGB(70, 30, 30)
ToggleJumpButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleJumpButton.Parent = MenuFrame

local JumpLabel = Instance.new("TextLabel")
JumpLabel.Size = UDim2.new(0.9, 0, 0, 25)
JumpLabel.Position = UDim2.new(0.05, 0, 0, 190)
JumpLabel.Text = "Jump Force Boost: 2.0x"
JumpLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
JumpLabel.BackgroundTransparency = 1
JumpLabel.Parent = MenuFrame

local MinusJumpButton = Instance.new("TextButton")
MinusJumpButton.Size = UDim2.new(0.4, 0, 0, 30)
MinusJumpButton.Position = UDim2.new(0.05, 0, 0, 215)
MinusJumpButton.Text = "-"
MinusJumpButton.TextSize = 20
MinusJumpButton.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
MinusJumpButton.TextColor3 = Color3.fromRGB(255, 255, 255)
MinusJumpButton.Parent = MenuFrame

local PlusJumpButton = Instance.new("TextButton")
PlusJumpButton.Size = UDim2.new(0.4, 0, 0, 30)
PlusJumpButton.Position = UDim2.new(0.55, 0, 0, 215)
PlusJumpButton.Text = "+"
PlusJumpButton.TextSize = 20
PlusJumpButton.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
PlusJumpButton.TextColor3 = Color3.fromRGB(255, 255, 255)
PlusJumpButton.Parent = MenuFrame

-- [UI ĐÈN ĐÊM]
local ToggleBrightButton = Instance.new("TextButton")
ToggleBrightButton.Size = UDim2.new(0.9, 0, 0, 35)
ToggleBrightButton.Position = UDim2.new(0.05, 0, 0, 260) 
ToggleBrightButton.Text = "Đèn Đêm: OFF"
ToggleBrightButton.BackgroundColor3 = Color3.fromRGB(70, 30, 30)
ToggleBrightButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleBrightButton.Parent = MenuFrame


-- ========================================================
-- 2. LOGIC ĐIỀU KHIỂN SCRIPT TIỆN ÍCH
-- ========================================================

local function updateSpeedDisplay()
    SpeedLabel.Text = string.format("Speed Multiplier: %.1fx", speedMultiplier)
end

local function updateJumpDisplay()
    JumpLabel.Text = string.format("Jump Force Boost: %.1fx", jumpBoostForce)
end

-- [LOGIC TỐC ĐỘ]
local function handleCFrameSpeed()
    local char = player.Character
    local rootPart = char and char:FindFirstChild("HumanoidRootPart")
    local humanoid = char and char:FindFirstChildOfClass("Humanoid")
    
    if rootPart and humanoid and humanoid.MoveDirection.Magnitude > 0 then
        local velocity = humanoid.MoveDirection * (speedMultiplier * 0.25)
        rootPart.CFrame = rootPart.CFrame + velocity
    end
end

ToggleButton.MouseButton1Click:Connect(function()
    bypassSpeedEnabled = not bypassSpeedEnabled
    if bypassSpeedEnabled then
        ToggleButton.Text = "Bypass Speed: ON"
        ToggleButton.BackgroundColor3 = Color3.fromRGB(30, 70, 30)
        speedConnection = RunService.RenderStepped:Connect(handleCFrameSpeed)
    else
        ToggleButton.Text = "Bypass Speed: OFF"
        ToggleButton.BackgroundColor3 = Color3.fromRGB(70, 30, 30)
        if speedConnection then speedConnection:Disconnect() speedConnection = nil end
    end
end)

MinusButton.MouseButton1Click:Connect(function()
    if speedMultiplier > 0.1 then speedMultiplier = speedMultiplier - 0.1 updateSpeedDisplay() end
end)

PlusButton.MouseButton1Click:Connect(function()
    if speedMultiplier < 5.0 then speedMultiplier = speedMultiplier + 0.1 updateSpeedDisplay() end
end)


-- [LOGIC NHẢY CAO]
ToggleJumpButton.MouseButton1Click:Connect(function()
    cframeJumpEnabled = not cframeJumpEnabled
    if cframeJumpEnabled then
        ToggleJumpButton.Text = "Nhảy CFrame: ON"
        ToggleJumpButton.BackgroundColor3 = Color3.fromRGB(30, 70, 30)
    else
        ToggleJumpButton.Text = "Nhảy CFrame: OFF"
        ToggleJumpButton.BackgroundColor3 = Color3.fromRGB(70, 30, 30)
    end
end)

MinusJumpButton.MouseButton1Click:Connect(function()
    if jumpBoostForce > 0.5 then jumpBoostForce = jumpBoostForce - 0.2 updateJumpDisplay() end
end)

PlusJumpButton.MouseButton1Click:Connect(function()
    if jumpBoostForce < 6.0 then jumpBoostForce = jumpBoostForce + 0.2 updateJumpDisplay() end
end)

local function connectJumpEvent(character)
    local humanoid = character:WaitForChild("Humanoid", 5)
    local rootPart = character:WaitForChild("HumanoidRootPart", 5)
    
    if humanoid and rootPart then
        humanoid.Jumping:Connect(function(isActive)
            if isActive and cframeJumpEnabled then
                local count = 0
                local boostConnection
                
                boostConnection = RunService.Heartbeat:Connect(function()
                    if count < 5 and rootPart and rootPart.Parent then
                        rootPart.CFrame = rootPart.CFrame + Vector3.new(0, jumpBoostForce, 0)
                        count = count + 1
                    else
                        boostConnection:Disconnect()
                    end
                end)
            end
        end)
    end
end

if player.Character then connectJumpEvent(player.Character) end
player.CharacterAdded:Connect(function(newCharacter) connectJumpEvent(newCharacter) end)


-- [LOGIC ĐÈN ĐÊM]
local function applyFullBright()
    if brightEnabled then
        Lighting.Ambient = Color3.fromRGB(255, 255, 255)
        Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
    end
end

ToggleBrightButton.MouseButton1Click:Connect(function()
    brightEnabled = not brightEnabled
    if brightEnabled then
        ToggleBrightButton.Text = "Đèn Đêm: ON"
        ToggleBrightButton.BackgroundColor3 = Color3.fromRGB(30, 70, 30)
        applyFullBright()
    else
        ToggleBrightButton.Text = "Đèn Đêm: OFF"
        ToggleBrightButton.BackgroundColor3 = Color3.fromRGB(70, 30, 30)
        Lighting.Ambient = originalAmbient
        Lighting.OutdoorAmbient = originalOutdoorAmbient
    end
end)

Lighting.Changed:Connect(function(property)
    if (property == "Ambient" or property == "OutdoorAmbient") and brightEnabled then
        applyFullBright()
    end
end)


-- ========================================================
-- CẮT ĐOẠN NÀY THAY VÀO TOÀN BỘ PHẦN CAMERA CUỐI SCRIPT CỦA BẠN
-- ========================================================

UserInputService.InputChanged:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement then
        if input.UserInputType == Enum.UserInputType.Touch then
            local screenSize = camera.ViewportSize
            if input.Position.X < (screenSize.X * 0.4) then 
                return 
            end
        end

        local delta = input.Delta
        targetRotationX = targetRotationX - delta.X * CAMERA_SENSITIVITY
        targetRotationY = math.clamp(targetRotationY - delta.Y * CAMERA_SENSITIVITY, -75, 75)
    end
end)

-- Tạo hàm bọc đúng chuẩn gốc của bạn
local function startCustomLookCamEngine()
    if cameraConnection then cameraConnection:Disconnect() end

    cameraConnection = RunService.RenderStepped:Connect(function()
        local char = player.Character
        local rootPart = char and char:FindFirstChild("HumanoidRootPart")
        
        if camera and rootPart then
            camera.CameraType = Enum.CameraType.Scriptable
            
            cameraRotationX = cameraRotationX + (targetRotationX - cameraRotationX) * SMOOTHNESS
            cameraRotationY = cameraRotationY + (targetRotationY - cameraRotationY) * SMOOTHNESS
            
            local startCFrame = CFrame.new(rootPart.Position)
            local rotationCFrame = CFrame.Angles(0, math.rad(cameraRotationX), 0) * CFrame.Angles(math.rad(cameraRotationY), 0, 0)
            
            camera.CFrame = startCFrame * rotationCFrame * CFrame.new(0, 2, cameraDistance)
            camera.Focus = startCFrame
        end
    end)
end

-- Kích hoạt và gọi hàm khi hồi sinh y hệt bản gốc của bạn
startCustomLookCamEngine()

player.CharacterAdded:Connect(function()
    task.wait(0.3)
    startCustomLookCamEngine()
end)
