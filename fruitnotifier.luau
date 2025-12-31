-- SERVICES
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- PLAYER
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local hrp = character:WaitForChild("HumanoidRootPart")

-- SETTINGS
local settings = { AutoStore = true, Noclip = true }

-- FRUITS
local fruitsList = {
	"Fruit ","Rocket Fruit","Spin Fruit","Ghost Fruit","Spring Fruit","Bomb Fruit",
	"Spike Fruit","Smoke Fruit","Blade Fruit","Sand Fruit","Ice Fruit","Dark Fruit",
	"Diamond Fruit","Light Fruit","Rubber Fruit","Barrier Fruit","Magma Fruit",
	"Phoenix Fruit","Love Fruit","Spider Fruit","Sound Fruit","Buddha Fruit",
	"Quake Fruit","Gravity Fruit","Control Fruit","T-Rex Fruit","Mammoth Fruit",
	"Spirit Fruit","Venom Fruit","Shadow Fruit","Rumble Fruit","Portal Fruit",
	"Blizzard Fruit","Dragon Fruit","Leopard Fruit","Dough Fruit",
	"Dragon (West) Fruit","Dragon (East) Fruit","Kitsune Fruit",
	"Gas Fruit","Flame Fruit","Yeti Fruit","Creation Fruit","Eagle Fruit"
}

-- FIND FRUITS
local function findFruits()
	local t = {}
	for _, v in ipairs(Workspace:GetChildren()) do
		if table.find(fruitsList, v.Name) and v:FindFirstChild("Handle") then
			table.insert(t, v)
		end
	end
	return t
end

---------------------------------------------------
-- MOVEMENT (SMOOTH FLY)
---------------------------------------------------
local moving = false
local noclipConn

local function setNoclip(state)
	if noclipConn then noclipConn:Disconnect() noclipConn = nil end
	if state then
		noclipConn = RunService.Stepped:Connect(function()
			for _, p in ipairs(character:GetDescendants()) do
				if p:IsA("BasePart") then p.CanCollide = false end
			end
		end)
	end
end

local function flyTo(position, speed)
	moving = true
	if settings.Noclip then setNoclip(true) end

	local connection
	connection = RunService.Stepped:Connect(function(_, dt)
		local currentPos = hrp.Position
		local direction = (position - currentPos)
		local dist = direction.Magnitude
		if dist < 1 then
			connection:Disconnect()
			moving = false
			setNoclip(false)
			return
		end
		local move = direction.Unit * math.clamp(speed * dt, 0, dist)
		hrp.CFrame = hrp.CFrame + move
	end)
end

local function goToFruit(fruit)
	if not fruit or not fruit:FindFirstChild("Handle") then return end
	local target = fruit.Handle.Position + Vector3.new(0,3,0)
	flyTo(target, 75) -- speed in studs/sec
end

---------------------------------------------------
-- AUTOSTORE
---------------------------------------------------
local stored = {}
local function autoStore()
	if not settings.AutoStore then return end

	local function store(tool)
		if stored[tool] then return end
		if tool:IsA("Tool") and tool.Name:find("Fruit") then
			local name = tool:GetAttribute("OriginalName") or tool.Name
			pcall(function()
				ReplicatedStorage.Remotes.CommF_:InvokeServer("StoreFruit", name, tool)
			end)
			stored[tool] = true
		end
	end

	local bp = player:FindFirstChild("Backpack")
	if bp then for _, t in ipairs(bp:GetChildren()) do store(t) end end
	for _, t in ipairs(character:GetChildren()) do store(t) end
end

---------------------------------------------------
-- UI
---------------------------------------------------
local gui = Instance.new("ScreenGui")
gui.Name = "FruitUI"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

-- ICON BUTTON (DRAGGABLE & CLICK TO MINIMIZE)
local icon = Instance.new("TextButton", gui)
icon.Size = UDim2.new(0,50,0,50)
icon.Position = UDim2.new(0.05,0,0.5,0)
icon.Text = "🍎"
icon.TextScaled = true
icon.Font = Enum.Font.GothamBold
icon.BackgroundColor3 = Color3.fromRGB(70,180,255)
icon.AutoButtonColor = false
icon.ZIndex = 10
icon.Active = true
icon.Draggable = true
Instance.new("UICorner", icon).CornerRadius = UDim.new(1,0)

-- MAIN MENU
local menu = Instance.new("Frame", gui)
menu.Size = UDim2.new(0,450,0,500)
menu.Position = UDim2.new(0.5,0,0.5,0)
menu.AnchorPoint = Vector2.new(0.5,0.5)
menu.BackgroundColor3 = Color3.fromRGB(25,25,25)
menu.Visible = false
Instance.new("UICorner", menu).CornerRadius = UDim.new(0,15)

-- TITLE BAR
local title = Instance.new("TextLabel", menu)
title.Size = UDim2.new(1,0,0,40)
title.BackgroundColor3 = Color3.fromRGB(40,40,40)
title.TextColor3 = Color3.new(1,1,1)
title.Font = Enum.Font.GothamBold
title.TextScaled = true
title.Text = "Fruit Menu"

-- TABS
local tabs = Instance.new("Frame", menu)
tabs.Size = UDim2.new(1,0,0,40)
tabs.Position = UDim2.new(0,0,0,40)
tabs.BackgroundTransparency = 1

local fruitsTabBtn = Instance.new("TextButton", tabs)
fruitsTabBtn.Size = UDim2.new(0.5,0,1,0)
fruitsTabBtn.Position = UDim2.new(0,0,0,0)
fruitsTabBtn.Text = "Fruits"
fruitsTabBtn.Font = Enum.Font.GothamBold
fruitsTabBtn.TextScaled = true
fruitsTabBtn.BackgroundColor3 = Color3.fromRGB(60,170,255)
fruitsTabBtn.TextColor3 = Color3.new(1,1,1)

local settingsTabBtn = Instance.new("TextButton", tabs)
settingsTabBtn.Size = UDim2.new(0.5,0,1,0)
settingsTabBtn.Position = UDim2.new(0.5,0,0,0)
settingsTabBtn.Text = "Settings"
settingsTabBtn.Font = Enum.Font.GothamBold
settingsTabBtn.TextScaled = true
settingsTabBtn.BackgroundColor3 = Color3.fromRGB(50,50,50)
settingsTabBtn.TextColor3 = Color3.new(1,1,1)

-- FRUITS FRAME
local fruitsFrame = Instance.new("ScrollingFrame", menu)
fruitsFrame.Position = UDim2.new(0,10,0,90)
fruitsFrame.Size = UDim2.new(1,-20,1,-100)
fruitsFrame.BackgroundTransparency = 1
fruitsFrame.ScrollBarThickness = 6
local fruitLayout = Instance.new("UIListLayout", fruitsFrame)
fruitLayout.Padding = UDim.new(0,6)

local function refreshFruits()
	for _, c in ipairs(fruitsFrame:GetChildren()) do
		if c:IsA("TextButton") then c:Destroy() end
	end
	for _, f in ipairs(findFruits()) do
		local b = Instance.new("TextButton", fruitsFrame)
		b.Size = UDim2.new(1,0,0,40)
		b.Text = f.Name == "Fruit " and "Spawned Fruit" or f.Name
		b.Font = Enum.Font.GothamBold
		b.TextScaled = true
		b.BackgroundColor3 = Color3.fromRGB(70,170,255)
		b.TextColor3 = Color3.new(1,1,1)
		Instance.new("UICorner", b).CornerRadius = UDim.new(0,8)
		b.MouseButton1Click:Connect(function() goToFruit(f) end)
	end
	fruitsFrame.CanvasSize = UDim2.new(0,0,0,fruitLayout.AbsoluteContentSize.Y+10)
end

-- SETTINGS FRAME
local settingsFrame = Instance.new("Frame", menu)
settingsFrame.Position = UDim2.new(0,0,0,90)
settingsFrame.Size = UDim2.new(1,0,1,-100)
settingsFrame.BackgroundTransparency = 1
settingsFrame.Visible = false

local function addToggle(parent,text,posY,default,callback)
	local b = Instance.new("TextButton", parent)
	b.Size = UDim2.new(0.45,0,0,35)
	b.Position = UDim2.new(0.05,0,0,posY)
	b.Font = Enum.Font.GothamBold
	b.TextScaled = true
	b.TextColor3 = Color3.new(1,1,1)
	local state = default
	local function refresh()
		b.Text = text..": "..(state and "ON" or "OFF")
		b.BackgroundColor3 = state and Color3.fromRGB(60,180,60) or Color3.fromRGB(180,60,60)
	end
	refresh()
	b.MouseButton1Click:Connect(function()
		state = not state
		callback(state)
		refresh()
	end)
end

addToggle(settingsFrame,"AutoStore",50,settings.AutoStore,function(v) settings.AutoStore = v end)
addToggle(settingsFrame,"Noclip",100,settings.Noclip,function(v) settings.Noclip = v end)

-- TAB SWITCHING
fruitsTabBtn.MouseButton1Click:Connect(function()
	fruitsFrame.Visible = true
	settingsFrame.Visible = false
	fruitsTabBtn.BackgroundColor3 = Color3.fromRGB(60,170,255)
	settingsTabBtn.BackgroundColor3 = Color3.fromRGB(50,50,50)
end)
settingsTabBtn.MouseButton1Click:Connect(function()
	fruitsFrame.Visible = false
	settingsFrame.Visible = true
	fruitsTabBtn.BackgroundColor3 = Color3.fromRGB(50,50,50)
	settingsTabBtn.BackgroundColor3 = Color3.fromRGB(60,170,255)
end)

-- ICON CLICK (MINIMIZE / MAXIMIZE)
icon.MouseButton1Click:Connect(function()
	menu.Visible = not menu.Visible
end)

-- MAIN LOOP
task.spawn(function()
	while true do
		if fruitsFrame.Visible then refreshFruits() end
		autoStore()
		task.wait(1)
	end
end)
