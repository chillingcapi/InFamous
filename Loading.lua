local Players = game.Players
local RunService = game.RunService
local TweenService = game.TweenService
local TextService = game.TextService
local HttpService = game.HttpService

local Player = Players.LocalPlayer

local FontName = "InterSemiBold"
local FontUrl = "https://raw.githubusercontent.com/chillingcapi/Relay/main/InterSemibold.ttf"
local DownloadImage = "rbxassetid://129452692971138"
local ImageFolder = "SweetieHub/Images"
local TitleSize = 20
local MinimumTime = 2.5

local Greeting = "Welcome, please wait while we download our assets"
local ReadyLine = "Almost ready"

local Assets = {
    { Name = "Wipe Selected Slot",     Url = "https://files.catbox.moe/2z3lm3.png" },
    { Name = "Other Luminant",         Url = "https://files.catbox.moe/emta95.png" },
    { Name = "Depths",                 Url = "https://files.catbox.moe/6ndymn.png" },
    { Name = "Voidheart",              Url = "https://files.catbox.moe/kz1pu1.png" },
    { Name = "Auto To1",               Url = "https://files.catbox.moe/iraumn.png" },
    { Name = "Auto Titus",             Url = "https://files.catbox.moe/0t0j8u.png" },
    { Name = "Auto Ingredients",       Url = "https://files.catbox.moe/uoiw0g.png" },
    { Name = "Remove Ingredients",     Url = "https://files.catbox.moe/zxya3e.png" },
    { Name = "Spectate on Leaderboard", Url = "https://files.catbox.moe/mq7dbh.png" },
    { Name = "Auto Wisp",              Url = "https://raw.githubusercontent.com/chillingcapi/Images/refs/heads/main/wisp.png" },
    { Name = "Auto Ores",              Url = "https://raw.githubusercontent.com/chillingcapi/Images/refs/heads/main/New_iron.png" },
    { Name = "Auto Distribute Points", Url = "https://raw.githubusercontent.com/chillingcapi/Images/refs/heads/main/stats.png" },
    { Name = "Auto Saramaed",          Url = "https://raw.githubusercontent.com/chillingcapi/Images/refs/heads/main/Saramaed.png" },
    { Name = "Auto Layer 2",           Url = "https://raw.githubusercontent.com/chillingcapi/Images/refs/heads/main/L2.png" },
    { Name = "Auto Moon Eyrie Island", Url = "https://raw.githubusercontent.com/chillingcapi/Images/main/MoonEyrie.png" },
    { Name = "Auto Collect Eggs",      Url = "https://raw.githubusercontent.com/chillingcapi/Images/main/EggImage.png" },
    { Name = "Auto Collect Money",     Url = "https://raw.githubusercontent.com/chillingcapi/Images/main/CollectCashImage.png" },
    { Name = "Auto Deposit Eggs",      Url = "https://raw.githubusercontent.com/chillingcapi/Images/main/DepositEggsImage.png" },
    { Name = "Auto Merge Chickens",    Url = "https://raw.githubusercontent.com/chillingcapi/Images/main/MergeChickensImage.png" },
    { Name = "Auto Upgrade Process",   Url = "https://raw.githubusercontent.com/chillingcapi/Images/main/UpgradeProgessImage.png" },
}

local function New(Class, Parent, Props)
    local Object = Instance.new(Class)
    for Key, Value in pairs(Props or {}) do Object[Key] = Value end
    Object.Parent = Parent
    return Object
end

local function Tween(Object, Props, Time, Style)
    local Info = TweenInfo.new(Time or 0.2, Style or Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local Handle = TweenService:Create(Object, Info, Props)
    Handle:Play()
    return Handle
end

local function Usable(Value)
    if not Value then return false end
    local Ok, Bounds = pcall(function()
        local Params = Instance.new("GetTextBoundsParams")
        Params.Text, Params.Font, Params.Size = "Ag", Value, 14
        return TextService:GetTextBoundsAsync(Params)
    end)
    return Ok and typeof(Bounds) == "Vector2" and Bounds.X > 0
end

local function LoadFont()
    if not (writefile and isfile and getcustomasset) then return nil end
    local Ttf, Descriptor = FontName .. ".ttf", FontName .. ".font"

    local function Have()
        local Ok, Body = pcall(readfile, Ttf)
        return Ok and type(Body) == "string" and #Body > 4096
    end

    local function Grab()
        local Ok, Body = pcall(function() return game:HttpGet(FontUrl, true) end)
        if not Ok or type(Body) ~= "string" or #Body <= 4096 or Body:sub(1, 1) == "<" then return false end
        return (pcall(writefile, Ttf, Body))
    end

    local function Describe()
        local Ok, Asset = pcall(getcustomasset, Ttf)
        if not Ok or type(Asset) ~= "string" or #Asset == 0 then return false end
        local Faces = { { name = FontName, weight = 600, style = "normal", assetId = Asset } }
        return (pcall(writefile, Descriptor, HttpService:JSONEncode({ name = FontName, faces = Faces })))
    end

    local function Build()
        if not Have() and not Grab() then return nil end
        if not Describe() then return nil end
        local Ok, Value = pcall(function() return Font.new(getcustomasset(Descriptor)) end)
        return Ok and Value or nil
    end

    local Result = Build()
    if Usable(Result) then return Result end
    pcall(delfile, Descriptor) pcall(delfile, Ttf)
    Result = Build()
    return Usable(Result) and Result or nil
end

local TitleFont = LoadFont() or Font.fromEnum(Enum.Font.GothamMedium)

local function CachePath(Url)
    local Sum = 0
    for Index = 1, #Url do Sum = (Sum * 31 + Url:byte(Index)) % 2147483647 end
    local Tail = Url:match("([%w%-_%.]+)$") or "image"
    Tail = Tail:gsub("[^%w%-_%.]", "")
    if #Tail > 40 then Tail = Tail:sub(-40) end
    if not Tail:match("%.%w+$") then Tail = Tail .. ".png" end
    return ImageFolder .. "/" .. Sum .. "_" .. Tail
end

local function EnsureFolders()
    pcall(function()
        if not isfolder("SweetieHub") then makefolder("SweetieHub") end
        if not isfolder(ImageFolder) then makefolder(ImageFolder) end
    end)
end

local function Fetch(Url)
    if not (writefile and isfile) then return false end
    local Path = CachePath(Url)
    local Cached = false
    pcall(function() Cached = isfile(Path) end)
    if Cached then return true end

    local Ok, Body = pcall(function() return game:HttpGet(Url) end)
    if not Ok or type(Body) ~= "string" or #Body < 128 then return false end
    return (pcall(writefile, Path, Body))
end

local Screen = Instance.new("ScreenGui")
Screen.Name = "LoadingScreen"
Screen.ResetOnSpawn = false
Screen.IgnoreGuiInset = true
Screen.DisplayOrder = 999
Screen.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local Parented = pcall(function() Screen.Parent = (gethui and gethui()) or game.CoreGui end)
if not Parented or not Screen.Parent then Screen.Parent = Player:WaitForChild("PlayerGui") end

local Backdrop = New("Frame", Screen, {
    Name = "Frame", BorderSizePixel = 0, BackgroundColor3 = Color3.fromRGB(0, 0, 0),
    BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0),
})

local Home = UDim2.new(0.5, 0, 0.5, -100)
local Away = UDim2.new(0.5, 0, 0, -160)

local Holder = New("Frame", Backdrop, {
    Name = "Title", BackgroundTransparency = 1, AnchorPoint = Vector2.new(0.5, 0.5),
    Position = Away, Size = UDim2.fromOffset(600, 50),
})

local Glyphs = New("Frame", Holder, { Name = "Glyphs", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0) })
New("UIListLayout", Glyphs, {
    FillDirection = Enum.FillDirection.Horizontal,
    HorizontalAlignment = Enum.HorizontalAlignment.Center,
    VerticalAlignment = Enum.VerticalAlignment.Center,
    SortOrder = Enum.SortOrder.LayoutOrder,
})

local Ghosts = New("Frame", Holder, { Name = "Ghosts", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0) })

local Spinner = New("ImageLabel", Holder, {
    Name = "ImageLabel", BackgroundTransparency = 1, Image = DownloadImage,
    ImageColor3 = Color3.fromRGB(255, 255, 255), ImageTransparency = 1,
    AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 1, 30),
    Size = UDim2.fromOffset(70, 70),
})

local function Measure(Text, Size)
    local Ok, Bounds = pcall(function()
        local Params = Instance.new("GetTextBoundsParams")
        Params.Text, Params.Font, Params.Size = Text, TitleFont, Size
        return TextService:GetTextBoundsAsync(Params)
    end)
    return (Ok and Bounds) and Bounds.X or (Size * 0.6)
end

local function MakeTicker(Name, Size, Colour, Offset)
    local Height = math.ceil(Size * 1.4)
    local Width = 0
    for Digit = 0, 9 do Width = math.max(Width, Measure(tostring(Digit), Size)) end
    Width = math.ceil(Width) + 1

    local Row = New("Frame", Holder, {
        Name = Name, BackgroundTransparency = 1, AnchorPoint = Vector2.new(0.5, 0),
        Position = UDim2.new(0.5, 0, 1, Offset), Size = UDim2.new(0, 0, 0, Height),
        AutomaticSize = Enum.AutomaticSize.X,
    })
    New("UIListLayout", Row, {
        FillDirection = Enum.FillDirection.Horizontal,
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        SortOrder = Enum.SortOrder.LayoutOrder,
    })

    local Ticker = { Slots = {}, Shown = "", Alpha = 1 }

    local function Label(Parent, Char, Order, Y)
        return New("TextLabel", Parent, {
            BackgroundTransparency = 1, LayoutOrder = Order, FontFace = TitleFont,
            TextSize = Size, TextColor3 = Colour, Text = Char, TextTransparency = Ticker.Alpha,
            TextXAlignment = Enum.TextXAlignment.Center, TextYAlignment = Enum.TextYAlignment.Center,
            Position = UDim2.fromOffset(0, Y or 0), Size = UDim2.new(1, 0, 0, Height),
        })
    end

    local function MakeDigit(Order)
        local Slot = New("Frame", Row, {
            Name = "Digit", BackgroundTransparency = 1, LayoutOrder = Order,
            ClipsDescendants = true, Size = UDim2.fromOffset(Width, Height),
        })
        local Reel = New("Frame", Slot, { Name = "Reel", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, Height * 11) })
        for Index = 0, 10 do Label(Reel, tostring(Index % 10), Index, Index * Height) end
        return { Kind = "Digit", Slot = Slot, Reel = Reel, Value = 0 }
    end

    local function MakeStatic(Char, Order)
        local Slot = New("Frame", Row, {
            Name = "Static", BackgroundTransparency = 1, LayoutOrder = Order,
            Size = UDim2.fromOffset(math.ceil(Measure(Char, Size)) + 1, Height),
        })
        return { Kind = "Static", Slot = Slot, Label = Label(Slot, Char, 1, 0), Char = Char }
    end

    local function FadeIn(Entry)
        for _, Object in ipairs(Entry.Slot:GetDescendants()) do
            if Object:IsA("TextLabel") then
                Object.TextTransparency = 1
                Tween(Object, { TextTransparency = Ticker.Alpha }, 0.2)
            end
        end
    end

    function Ticker:Set(Value)
        Value = tostring(Value)
        if Value == self.Shown then return end
        self.Shown = Value

        for Index = #Value + 1, #self.Slots do
            local Dying = self.Slots[Index].Slot
            self.Slots[Index] = nil
            Tween(Dying, { Size = UDim2.fromOffset(0, Height) }, 0.22, Enum.EasingStyle.Quint)
            for _, Object in ipairs(Dying:GetDescendants()) do
                if Object:IsA("TextLabel") then Tween(Object, { TextTransparency = 1 }, 0.16) end
            end
            task.delay(0.26, function() if Dying.Parent then Dying:Destroy() end end)
        end

        for Index = 1, #Value do
            local Char = Value:sub(Index, Index)
            local IsDigit = Char:match("%d") ~= nil
            local Entry = self.Slots[Index]
            local Mismatch = Entry and ((Entry.Kind == "Digit") ~= IsDigit or (Entry.Kind == "Static" and Entry.Char ~= Char))

            if Mismatch then Entry.Slot:Destroy() Entry = nil end

            if not Entry then
                Entry = IsDigit and MakeDigit(Index) or MakeStatic(Char, Index)
                self.Slots[Index] = Entry
                FadeIn(Entry)
            end

            if IsDigit then
                local Target = tonumber(Char)
                if Target ~= Entry.Value then
                    local Roll = (Target < Entry.Value) and (Target + 10) or Target
                    Tween(Entry.Reel, { Position = UDim2.fromOffset(0, -Roll * Height) }, 0.42, Enum.EasingStyle.Quint)
                    if Roll >= 10 then
                        task.delay(0.44, function()
                            if Entry.Reel.Parent then Entry.Reel.Position = UDim2.fromOffset(0, -Target * Height) end
                        end)
                    end
                    Entry.Value = Target
                end
            end
        end
    end

    function Ticker:Fade(Alpha, Time)
        self.Alpha = Alpha
        for _, Entry in pairs(self.Slots) do
            for _, Object in ipairs(Entry.Slot:GetDescendants()) do
                if Object:IsA("TextLabel") then Tween(Object, { TextTransparency = Alpha }, Time or 0.3) end
            end
        end
    end

    return Ticker
end

local Percent = MakeTicker("Percent", 18, Color3.fromRGB(255, 255, 255), 112)
local Count = MakeTicker("Count", 13, Color3.fromRGB(150, 150, 160), 138)

local Done, Total, Eased, LastWhole = 0, #Assets, 0, -1

local function SetProgress(Value)
    Done = math.clamp(Value, 0, Total)
    Count:Set(Done .. "/" .. Total)
end

local Shown = ""

local function ShowInstantly(Text)
    for _, Child in ipairs(Ghosts:GetChildren()) do Child:Destroy() end
    for _, Child in ipairs(Glyphs:GetChildren()) do
        if Child:IsA("TextLabel") then Child:Destroy() end
    end
    for Index = 1, #Text do
        New("TextLabel", Glyphs, {
            LayoutOrder = Index, BackgroundTransparency = 1, FontFace = TitleFont,
            TextSize = TitleSize, TextColor3 = Color3.fromRGB(255, 255, 255),
            Text = Text:sub(Index, Index), TextXAlignment = Enum.TextXAlignment.Center,
            TextYAlignment = Enum.TextYAlignment.Center, Size = UDim2.new(0, 0, 1, 0),
            AutomaticSize = Enum.AutomaticSize.X,
        })
    end
end

local function Morph(Text, Instant)
    Text = tostring(Text or "")
    if Shown == Text then return end
    Shown = Text

    if Instant then return ShowInstantly(Text) end

    local Chars = {}
    for _, Child in ipairs(Glyphs:GetChildren()) do
        if Child:IsA("TextLabel") then table.insert(Chars, Child) end
    end
    table.sort(Chars, function(A, B) return A.LayoutOrder < B.LayoutOrder end)

    local Keep = 0
    for Index = 1, math.min(#Chars, #Text) do
        if Chars[Index].Text == Text:sub(Index, Index) then Keep = Index else break end
    end

    local Origin = Glyphs.AbsolutePosition
    local Leaving = #Chars - Keep

    for Index = #Chars, Keep + 1, -1 do
        local Old = Chars[Index]
        local At = Old.AbsolutePosition - Origin
        local Drift = (Index % 2 == 0) and -14 or 14
        Old.AutomaticSize = Enum.AutomaticSize.None
        Old.Size = UDim2.fromOffset(Old.AbsoluteSize.X, Old.AbsoluteSize.Y)
        Old.Position = UDim2.fromOffset(At.X, At.Y)
        Old.Parent = Ghosts

        local Step = (Leaving - (Index - Keep)) * 0.016
        task.delay(Step, function()
            if not Old.Parent then return end
            Tween(Old, { TextTransparency = 1 }, 0.2)
            Tween(Old, { Position = UDim2.fromOffset(At.X, At.Y + Drift) }, 0.3, Enum.EasingStyle.Quint)
        end)
        task.delay(Step + 0.34, function() if Old.Parent then Old:Destroy() end end)
    end

    for Index = Keep + 1, #Text do
        local Char = New("TextLabel", Glyphs, {
            LayoutOrder = Index, BackgroundTransparency = 1, FontFace = TitleFont,
            TextSize = TitleSize, TextColor3 = Color3.fromRGB(255, 255, 255),
            Text = Text:sub(Index, Index), TextTransparency = 1,
            TextXAlignment = Enum.TextXAlignment.Center, TextYAlignment = Enum.TextYAlignment.Center,
            Position = UDim2.fromOffset(0, (math.random() < 0.5) and -16 or 16),
            Size = UDim2.new(0, 0, 1, 0), AutomaticSize = Enum.AutomaticSize.X,
        })
        task.delay((Index - Keep - 1) * 0.028, function()
            if not Char.Parent then return end
            Tween(Char, { TextTransparency = 0 }, 0.3)
            Tween(Char, { Position = UDim2.fromOffset(0, 0) }, 0.42, Enum.EasingStyle.Quint)
        end)
    end
end

local Spin
Spin = RunService.RenderStepped:Connect(function(Delta)
    if not Spinner.Parent then Spin:Disconnect() return end
    Spinner.Rotation = (Spinner.Rotation + Delta * 220) % 360

    Eased = Eased + (((Total > 0) and (Done / Total) or 0) - Eased) * math.min(Delta * 7, 1)
    local Whole = math.floor(Eased * 100 + 0.5)
    if Whole ~= LastWhole then
        LastWhole = Whole
        Percent:Set(Whole .. "%")
    end
end)

local function Finish()
    if Spin then Spin:Disconnect() end
    Tween(Backdrop, { BackgroundTransparency = 1 }, 0.35)
    Tween(Holder, { Position = Away }, 0.5, Enum.EasingStyle.Quint)
    Tween(Spinner, { ImageTransparency = 1 }, 0.3)
    Percent:Fade(1, 0.3)
    Count:Fade(1, 0.3)
    for _, Child in ipairs(Glyphs:GetChildren()) do
        if Child:IsA("TextLabel") then Tween(Child, { TextTransparency = 1 }, 0.3) end
    end
    task.delay(0.6, function() if Screen then Screen:Destroy() end end)
end

task.spawn(function()
    local Started = os.clock()
    EnsureFolders()

    Tween(Backdrop, { BackgroundTransparency = 0.25 }, 0.35)
    Tween(Holder, { Position = Home }, 0.75, Enum.EasingStyle.Quint)
    Tween(Spinner, { ImageTransparency = 0 }, 0.5)
    Percent:Fade(0, 0.5)
    Count:Fade(0.15, 0.5)

    SetProgress(0)
    Morph(Greeting)
    task.wait(#Greeting * 0.028 + 0.42 + 0.5)

    for Index, Asset in ipairs(Assets) do
        Morph("Downloading " .. Asset.Name, true)
        Fetch(Asset.Url)
        SetProgress(Index)
        task.wait()
    end

    local Left = MinimumTime - (os.clock() - Started)
    if Left > 0 then task.wait(Left) end

    Morph(ReadyLine, true)
    task.wait(0.6)
    Finish()
end)
