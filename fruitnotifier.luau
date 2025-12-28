-- Services
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")

-- Player
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
local humanoid = character:WaitForChild("Humanoid")

-- Settings
local savedSettings = { AutoStore = false, Noclip = true }

-- Fruit list
local fruitsList = {
    "Fruit ", "Rocket Fruit", "Spin Fruit", "Ghost Fruit", "Spring Fruit", "Bomb Fruit", "Spike Fruit", "Smoke Fruit", "Blade Fruit",
    "Sand Fruit", "Ice Fruit", "Dark Fruit", "Diamond Fruit", "Light Fruit", "Rubber Fruit", "Barrier Fruit", "Magma Fruit", "Phoenix Fruit",
    "Love Fruit", "Spider Fruit", "Sound Fruit", "Buddha Fruit", "Quake Fruit", "Gravity Fruit", "Control Fruit", "T-Rex Fruit",
    "Mammoth Fruit", "Spirit Fruit", "Venom Fruit", "Shadow Fruit", "Rumble Fruit", "Portal Fruit", "Blizzard Fruit", "Dragon Fruit",
    "Leopard Fruit", "Dough Fruit", "Dragon (West) Fruit", "Dragon (East) Fruit", "Kitsune Fruit", "Gas Fruit", "Flame Fruit", "Yeti Fruit", "Creation Fruit", "Eagle Fruit"
}

-- Utility functions
local function findFruits()
    local found = {}
    for _, fruit in ipairs(Workspace:GetChildren()) do
        if table.find(fruitsList, fruit.Name) and fruit:FindFirstChild("Handle") then
            table.insert(found, fruit)
        end
    end
    return found
end

-- Slow teleport (smooth, no snap back)
local activeTween
local function teleportTo(fruit)
    if not fruit or not fruit:FindFirstChild("Handle") then return end
    
    if activeTween then
        activeTween:Cancel()
    end

    local dist = (humanoidRootPart.Position - fruit.Handle.Position).Magnitude
    local tweenTime = math.clamp(dist / 150, 1, 4) -- slower speed

    local goalCFrame = CFrame.new(fruit.Handle.Position + Vector3.new(0, 3, 0))
    activeTween = TweenService:Create(humanoidRootPart, TweenInfo.new(tweenTime, Enum.EasingStyle.Linear), {CFrame = goalCFrame})

    local noclipConn
    if savedSettings.Noclip then
        noclipConn = RunService.Stepped:Connect(function()
            for _, part in ipairs(character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end)
    end

    activeTween.Completed:Connect(function()
        if noclipConn then noclipConn:Disconnect() end
        activeTween = nil
    end)

    activeTween:Play()
end

-- AutoStore (backpack + equipped fruits)
local storedFruits = {}
local function autoStore()
    if not savedSettings.AutoStore then return end

    local function storeFruit(tool)
        if not tool or not tool:IsA("Tool") then return end
        if storedFruits[tool] then return end
        if tool.Name:find("Fruit") then
            local original = tool:GetAttribute("OriginalName") or tool.Name
            local success, err = pcall(function()
                ReplicatedStorage.Remotes.CommF_:InvokeServer("StoreFruit", original, tool)
            end)
            if success then
                storedFruits[tool] = true
            end
        end
    end

    local backpack = player:FindFirstChild("Backpack")
    if backpack then
        for _, tool in ipairs(backpack:GetChildren()) do
            storeFruit(tool)
        end
    end

    for _, tool in ipairs(character:GetChildren()) do
        storeFruit(tool)
    end
end

-- UI Setup
local screenGui = Instance.new("ScreenGui")
screenGui.Parent = player:WaitForChild("PlayerGui")

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 450, 0, 520)
mainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 15)
mainCorner.Parent = mainFrame

local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 40)
titleBar.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
titleBar.Parent = mainFrame

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, -180, 1, 0)
titleLabel.Position = UDim2.new(0, 10, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "Fruit Teleport Menu"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextScaled = true
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = titleBar

local minimizeBtn = Instance.new("TextButton")
minimizeBtn.Size = UDim2.new(0, 35, 0, 30)
minimizeBtn.Position = UDim2.new(1, -40, 0, 5)
minimizeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
minimizeBtn.Text = "–"
minimizeBtn.Font = Enum.Font.GothamBold
minimizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
minimizeBtn.TextScaled = true
minimizeBtn.Parent = titleBar

local autoStoreBtn = Instance.new("TextButton")
autoStoreBtn.Size = UDim2.new(0, 60, 0, 30)
autoStoreBtn.Position = UDim2.new(1, -110, 0, 5)
autoStoreBtn.BackgroundColor3 = Color3.fromRGB(50, 180, 50)
autoStoreBtn.Text = "AutoStore: Off"
autoStoreBtn.Font = Enum.Font.GothamBold
autoStoreBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
autoStoreBtn.TextScaled = true
autoStoreBtn.Parent = titleBar

local noclipBtn = Instance.new("TextButton")
noclipBtn.Size = UDim2.new(0, 60, 0, 30)
noclipBtn.Position = UDim2.new(1, -180, 0, 5)
noclipBtn.BackgroundColor3 = Color3.fromRGB(50, 180, 50)
noclipBtn.Text = "Noclip: On"
noclipBtn.Font = Enum.Font.GothamBold
noclipBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
noclipBtn.TextScaled = true
noclipBtn.Parent = titleBar

local contentFrame = Instance.new("ScrollingFrame")
contentFrame.Size = UDim2.new(1, -20, 1, -40)
contentFrame.Position = UDim2.new(0, 10, 0, 40)
contentFrame.BackgroundTransparency = 1
contentFrame.BorderSizePixel = 0
contentFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
contentFrame.ScrollBarThickness = 8
contentFrame.Parent = mainFrame

local uiListLayout = Instance.new("UIListLayout")
uiListLayout.Padding = UDim.new(0, 6)
uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder
uiListLayout.Parent = contentFrame

-- Draggable
local dragging, dragInput, dragStart, startPos
titleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)
titleBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then dragInput = input end
end)
UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end
end)

-- Minimize
local minimized = false
minimizeBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    contentFrame.Visible = not minimized
    mainFrame.Size = minimized and UDim2.new(0, 450, 0, 40) or UDim2.new(0, 450, 0, 520)
end)

-- Toggle AutoStore
autoStoreBtn.MouseButton1Click:Connect(function()
    savedSettings.AutoStore = not savedSettings.AutoStore
    autoStoreBtn.Text = "AutoStore: " .. (savedSettings.AutoStore and "On" or "Off")
    autoStoreBtn.BackgroundColor3 = savedSettings.AutoStore and Color3.fromRGB(50, 180, 50) or Color3.fromRGB(180, 50, 50)
end)

-- Toggle Noclip
noclipBtn.MouseButton1Click:Connect(function()
    savedSettings.Noclip = not savedSettings.Noclip
    noclipBtn.Text = "Noclip: " .. (savedSettings.Noclip and "On" or "Off")
    noclipBtn.BackgroundColor3 = savedSettings.Noclip and Color3.fromRGB(50, 180, 50) or Color3.fromRGB(180, 50, 50)
end)

-- Update fruit buttons
local function updateFruitButtons()
    for _, child in ipairs(contentFrame:GetChildren()) do
        if child:IsA("TextButton") then
            child:Destroy()
        end
    end
    local fruits = findFruits()
    for _, fruit in ipairs(fruits) do
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, 0, 0, 40)
        btn.BackgroundColor3 = Color3.fromRGB(50, 180, 255)
        btn.BackgroundTransparency = 0.1
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.Font = Enum.Font.GothamBold
        btn.TextScaled = true
        btn.Text = fruit.Name == "Fruit " and "Spawned Fruit" or fruit.Name
        btn.Parent = contentFrame

        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 8)
        corner.Parent = btn

        btn.MouseEnter:Connect(function()
            TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundTransparency = 0}):Play()
        end)
        btn.MouseLeave:Connect(function()
            TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundTransparency = 0.1}):Play()
        end)

        btn.MouseButton1Click:Connect(function()
            teleportTo(fruit)
        end)
    end
    contentFrame.CanvasSize = UDim2.new(0, 0, 0, uiListLayout.AbsoluteContentSize.Y + 10)
end

-- Main loop
task.spawn(function()
    while true do
        updateFruitButtons()
        autoStore()
        if savedSettings.Noclip then
            for _, part in ipairs(character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end
        task.wait(0.8)
    end
end)
