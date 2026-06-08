-- [[ MOBILE SCRIPT HUB - BYPASS SPEED WITH ADJUSTMENT ]] --
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer

-- 1. TẠO GIAO DIỆN MENU TRÊN MOBILE
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "BypassSpeedHubV2"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = player:WaitForChild("PlayerGui")

local MenuFrame = Instance.new("Frame")
MenuFrame.Size = UDim2.new(0, 200, 0, 160) -- Tăng kích thước bảng một chút để đủ chỗ xếp nút
MenuFrame.Position = UDim2.new(0.1, 0, 0.2, 0)
MenuFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
MenuFrame.Active = true
MenuFrame.Draggable = true
MenuFrame.Parent = ScreenGui

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 30)
Title.Text = "SPEED ADJUST HUB"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
Title.Parent = MenuFrame

-- Nút Bật/Tắt chính
local ToggleButton = Instance.new("TextButton")
ToggleButton.Size = UDim2.new(0.9, 0, 0, 35)
ToggleButton.Position = UDim2.new(0.05, 0, 0, 40)
ToggleButton.Text = "Bypass Speed: OFF"
ToggleButton.BackgroundColor3 = Color3.fromRGB(70, 30, 30)
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.Parent = MenuFrame

-- Dòng hiển thị mức tốc độ hiện tại
local SpeedLabel = Instance.new("TextLabel")
SpeedLabel.Size = UDim2.new(0.9, 0, 0, 25)
SpeedLabel.Position = UDim2.new(0.05, 0, 0, 85)
SpeedLabel.Text = "Speed Multiplier: 1.5x"
SpeedLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
SpeedLabel.BackgroundTransparency = 1
SpeedLabel.Parent = MenuFrame

-- Nút GIẢM tốc độ (-)
local MinusButton = Instance.new("TextButton")
MinusButton.Size = UDim2.new(0.4, 0, 0, 30)
MinusButton.Position = UDim2.new(0.05, 0, 0, 115)
MinusButton.Text = "-"
MinusButton.TextSize = 20
MinusButton.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
MinusButton.TextColor3 = Color3.fromRGB(255, 255, 255)
MinusButton.Parent = MenuFrame

-- Nút TĂNG tốc độ (+)
local PlusButton = Instance.new("TextButton")
PlusButton.Size = UDim2.new(0.4, 0, 0, 30)
PlusButton.Position = UDim2.new(0.55, 0, 0, 115)
PlusButton.Text = "+"
PlusButton.TextSize = 20
PlusButton.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
PlusButton.TextColor3 = Color3.fromRGB(255, 255, 255)
PlusButton.Parent = MenuFrame

-- ========================================================
-- 2. LOGIC XỬ LÝ tốc độ VÀ ĐIỀU CHỈNH

local bypassSpeedEnabled = false
local speedMultiplier = 1.5 -- Tốc độ ban đầu mặc định
local cframeConnection = nil

-- Hàm cập nhật text hiển thị
local function updateSpeedDisplay()
	-- Làm tròn đến 1 chữ số thập phân cho đẹp UI
	SpeedLabel.Text = string.format("Speed Multiplier: %.1fx", speedMultiplier)
end

-- Hàm dịch chuyển vi mô dựa theo speedMultiplier
local function handleCFrameSpeed()
	local char = player.Character
	local rootPart = char and char:FindFirstChild("HumanoidRootPart")
	local humanoid = char and char:FindFirstChildOfClass("Humanoid")
	
	if rootPart and humanoid and humanoid.MoveDirection.Magnitude > 0 then
		-- Công thức: lấy hướng đi nhân với hệ số điều chỉnh để đẩy nhân vật đi
		local velocity = humanoid.MoveDirection * (speedMultiplier * 0.25)
		rootPart.CFrame = rootPart.CFrame + velocity
	end
end

-- Sự kiện nút Bật/Tắt
ToggleButton.MouseButton1Click:Connect(function()
	bypassSpeedEnabled = not bypassSpeedEnabled
	
	if bypassSpeedEnabled then
		ToggleButton.Text = "Bypass Speed: ON"
		ToggleButton.BackgroundColor3 = Color3.fromRGB(30, 70, 30)
		cframeConnection = RunService.RenderStepped:Connect(handleCFrameSpeed)
	else
		ToggleButton.Text = "Bypass Speed: OFF"
		ToggleButton.BackgroundColor3 = Color3.fromRGB(70, 30, 30)
		if cframeConnection then
			cframeConnection:Disconnect()
			cframeConnection = nil
		end
	end
end)

-- Sự kiện nút GIẢM (-)
MinusButton.MouseButton1Click:Connect(function()
	if speedMultiplier > 0.1 then
		speedMultiplier = speedMultiplier - 0.1 -- Mỗi lần bấm giảm 0.1
		updateSpeedDisplay()
	end
end)

-- Sự kiện nút TĂNG (+)
PlusButton.MouseButton1Click:Connect(function()
	if speedMultiplier < 5.0 then -- Giới hạn tối đa là 5.0 để tránh văng map
		speedMultiplier = speedMultiplier + 0.1 -- Mỗi lần bấm tăng 0.1
		updateSpeedDisplay()
	end
end)
