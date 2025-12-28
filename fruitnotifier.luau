--// Services
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--// Player
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

--// Settings
local savedSettings = { AutoStore = false, Noclip = true }
local storedFruits = {}

--// Fruit list
local fruitsList = {
	"Fruit ","Rocket Fruit","Spin Fruit","Ghost Fruit","Spring Fruit","Bomb Fruit","Spike Fruit",
	"Smoke Fruit","Blade Fruit","Sand Fruit","Ice Fruit","Dark Fruit","Diamond Fruit","Light Fruit",
	"Rubber Fruit","Barrier Fruit","Magma Fruit","Phoenix Fruit","Love Fruit","Spider Fruit",
	"Sound Fruit","Buddha Fruit","Quake Fruit","Gravity Fruit","Control Fruit","T-Rex Fruit",
	"Mammoth Fruit","Spirit Fruit","Venom Fruit","Shadow Fruit","Rumble Fruit","Portal Fruit",
	"Blizzard Fruit","Dragon Fruit","Leopard Fruit","Dough Fruit","Dragon (West) Fruit",
	"Dragon (East) Fruit","Kitsune Fruit","Gas Fruit","Flame Fruit","Yeti Fruit",
	"Creation Fruit","Eagle Fruit"
}

--// Find fruits
local function findFruits()
	local found = {}
	for _, v in ipairs(Workspace:GetChildren()) do
		if table.find(fruitsList, v.Name) and v:FindFirstChild("Handle") then
			table.insert(found, v)
		end
	end
	return found
end

--// Smooth teleport
local activeTween
local function teleportTo(fruit)
	if not fruit or not fruit:FindFirstChild("Handle") then return end
	if activeTween then activeTween:Cancel() end

	local dist = (humanoidRootPart.Position - fruit.Handle.Position).Magnitude
	local time = math.clamp(dist / 150, 1, 4)

	activeTween = TweenService:Create(
		humanoidRootPart,
		TweenInfo.new(time, Enum.EasingStyle.Linear),
		{CFrame = CFrame.new(fruit.Handle.Position + Vector3.new(0,3,0))}
	)

	if savedSettings.Noclip then
		RunService.Stepped:Once(function()
			for _, p in ipairs(character:GetDescendants()) do
				if p:IsA("BasePart") then p.CanCollide = false end
			end
		end)
	end

	activeTween:Play()
end

--// AutoStore
local function autoStore()
	if not savedSettings.AutoStore then return end
	for _, tool in ipairs(player.Backpack:GetChildren()) do
		if tool:IsA("Tool") and tool.Name:find("Fruit") and not storedFruits[tool] then
			pcall(function()
				ReplicatedStorage.Remotes.CommF_:InvokeServer("StoreFruit", tool.Name, tool)
			end)
			storedFruits[tool] = true
		end
	end
end

--// UI
local gui = Instance.new("ScreenGui", player.PlayerGui)
gui.ResetOnSpawn = false

local main = Instance.new("Frame", gui)
main.AnchorPoint = Vector2.new(0.5,0.5)
main.Position = UDim2.fromScale(0.5,0.5)
main.Size = UserInputService.TouchEnabled and UDim2.fromOffset(520,600) or UDim2.fromOffset(450,520)
main.BackgroundColor3 = Color3.fromRGB(25,25,25)
main.BorderSizePixel = 0
Instance.new("UICorner", main).CornerRadius = UDim.new(0,16)

--// Title bar
local title = Instance.new("Frame", main)
title.Size = UDim2.new(1,0,0,45)
title.BackgroundColor3 = Color3.fromRGB(40,40,40)

local titleText = Instance.new("TextLabel", title)
titleText.Size = UDim2.new(1,-150,1,0)
titleText.Position = UDim2.fromOffset(10,0)
titleText.BackgroundTransparency = 1
titleText.Text = "Fruit Teleport (Mobile)"
titleText.Font = Enum.Font.GothamBold
titleText.TextScaled = true
titleText.TextColor3 = Color3.new(1,1,1)
titleText.TextXAlignment = Left

--// Buttons
local function topButton(text,x)
	local b = Instance.new("TextButton", title)
	b.Size = UDim2.fromOffset(70,30)
	b.Position = UDim2.new(1,x,0,7)
	b.Text = text
	b.Font = Enum.Font.GothamBold
	b.TextScaled = true
	b.TextColor3 = Color3.new(1,1,1)
	Instance.new("UICorner", b).CornerRadius = UDim.new(0,8)
	return b
end

local noclipBtn = topButton("Noclip:On",-230)
local storeBtn  = topButton("Store:Off",-150)
local minBtn    = topButton("–",-75)

noclipBtn.BackgroundColor3 = Color3.fromRGB(60,200,60)
storeBtn.BackgroundColor3  = Color3.fromRGB(180,60,60)
minBtn.BackgroundColor3    = Color3.fromRGB(200,60,60)

--// Content
local scroll = Instance.new("ScrollingFrame", main)
scroll.Position = UDim2.fromOffset(10,50)
scroll.Size = UDim2.new(1,-20,1,-60)
scroll.CanvasSize = UDim2.new()
scroll.ScrollBarThickness = 10
scroll.BackgroundTransparency = 1

local layout = Instance.new("UIListLayout", scroll)
layout.Padding = UDim.new(0,10)

--// Drag (MOBILE + PC)
local dragging, dragStart, startPos
title.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1
	or input.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		dragStart = input.Position
		startPos = main.Position
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
	or input.UserInputType == Enum.UserInputType.Touch) then
		local delta = input.Position - dragStart
		main.Position = UDim2.new(
			startPos.X.Scale,
			startPos.X.Offset + delta.X,
			startPos.Y.Scale,
			startPos.Y.Offset + delta.Y
		)
	end
end)

UserInputService.InputEnded:Connect(function()
	dragging = false
end)

--// Fruit buttons
local function refresh()
	for _, c in ipairs(scroll:GetChildren()) do
		if c:IsA("TextButton") then c:Destroy() end
	end

	for _, fruit in ipairs(findFruits()) do
		local b = Instance.new("TextButton", scroll)
		b.Size = UDim2.new(1,0,0,45)
		b.Text = fruit.Name == "Fruit " and "Spawned Fruit" or fruit.Name
		b.Font = Enum.Font.GothamBold
		b.TextScaled = true
		b.TextColor3 = Color3.new(1,1,1)
		b.BackgroundColor3 = Color3.fromRGB(60,180,255)
		Instance.new("UICorner", b).CornerRadius = UDim.new(0,10)
		b.MouseButton1Click:Connect(function()
			teleportTo(fruit)
		end)
	end
	scroll.CanvasSize = UDim2.new(0,0,0,layout.AbsoluteContentSize.Y + 10)
end

--// Button logic
noclipBtn.MouseButton1Click:Connect(function()
	savedSettings.Noclip = not savedSettings.Noclip
	noclipBtn.Text = "Noclip:" .. (savedSettings.Noclip and "On" or "Off")
	noclipBtn.BackgroundColor3 = savedSettings.Noclip and Color3.fromRGB(60,200,60) or Color3.fromRGB(200,60,60)
end)

storeBtn.MouseButton1Click:Connect(function()
	savedSettings.AutoStore = not savedSettings.AutoStore
	storeBtn.Text = "Store:" .. (savedSettings.AutoStore and "On" or "Off")
	storeBtn.BackgroundColor3 = savedSettings.AutoStore and Color3.fromRGB(60,200,60) or Color3.fromRGB(200,60,60)
end)

local minimized = false
minBtn.MouseButton1Click:Connect(function()
	minimized = not minimized
	scroll.Visible = not minimized
	main.Size = minimized and UDim2.fromOffset(main.Size.X.Offset,45)
		or (UserInputService.TouchEnabled and UDim2.fromOffset(520,600) or UDim2.fromOffset(450,520))
end)

--// Loop
task.spawn(function()
	while true do
		refresh()
		autoStore()
		task.wait(1)
	end
end)
