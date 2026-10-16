-- Zurly Hub — Grow a Garden UI (red/black theme)

local UI = {}

local CoreGui = game:GetService("CoreGui")
local UIS     = game:GetService("UserInputService")
local Players = game:GetService("Players")
local LP      = Players.LocalPlayer

local function fetchTheme()
    return getgenv().ZURLY_THEME
end

function UI:Build(Ctx, cfg)
    local T = Ctx.Theme
    local W = Ctx.UIWidgets.New(T)
    local corner = Ctx.UIWidgets.corner
    local stroke = Ctx.UIWidgets.stroke
    local padding = Ctx.UIWidgets.padding

    if CoreGui:FindFirstChild("ZurlyHub_GG") then CoreGui.ZurlyHub_GG:Destroy() end
    local gui = Instance.new("ScreenGui")
    gui.Name = "ZurlyHub_GG"; gui.ResetOnSpawn = false
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    gui.Parent = CoreGui

    local main = Instance.new("Frame", gui)
    main.Size = UDim2.new(0, 640, 0, 440)
    main.Position = UDim2.new(0.5, -320, 0.5, -220)
    main.BackgroundColor3 = T.bg; main.BorderSizePixel = 0
    main.Active = true; main.Draggable = true
    corner(main, 8); stroke(main, T.border, 1)

    -- Title bar
    local title = Instance.new("Frame", main)
    title.Size = UDim2.new(1, 0, 0, 32); title.BackgroundColor3 = T.panel
    title.BorderSizePixel = 0
    corner(title, 8)
    local titleFix = Instance.new("Frame", title)
    titleFix.Size = UDim2.new(1, 0, 0.5, 0); titleFix.Position = UDim2.new(0, 0, 0.5, 0)
    titleFix.BackgroundColor3 = T.panel; titleFix.BorderSizePixel = 0

    local titleTxt = Instance.new("TextLabel", title)
    titleTxt.Size = UDim2.new(1, -70, 1, 0); titleTxt.Position = UDim2.new(0, 12, 0, 0)
    titleTxt.BackgroundTransparency = 1
    titleTxt.Font = Enum.Font.GothamBold; titleTxt.TextSize = 13
    titleTxt.TextColor3 = T.text
    titleTxt.TextXAlignment = Enum.TextXAlignment.Left
    titleTxt.Text = T.brand .. "  ::  Grow a Garden  "
        .. (Ctx.IsPremium and "[PREMIUM]" or "[FREE]")

    local closeBtn = Instance.new("TextButton", title)
    closeBtn.Size = UDim2.new(0, 28, 0, 24); closeBtn.Position = UDim2.new(1, -34, 0, 4)
    closeBtn.BackgroundTransparency = 1
    closeBtn.Font = Enum.Font.GothamBold; closeBtn.TextSize = 16
    closeBtn.TextColor3 = T.danger; closeBtn.Text = "X"
    closeBtn.MouseButton1Click:Connect(function() gui:Destroy() end)

    local minBtn = Instance.new("TextButton", title)
    minBtn.Size = UDim2.new(0, 28, 0, 24); minBtn.Position = UDim2.new(1, -64, 0, 4)
    minBtn.BackgroundTransparency = 1
    minBtn.Font = Enum.Font.GothamBold; minBtn.TextSize = 16
    minBtn.TextColor3 = T.text; minBtn.Text = "-"
    local minimized = false
    minBtn.MouseButton1Click:Connect(function()
        minimized = not minimized
        main.Size = minimized and UDim2.new(0, 640, 0, 32) or UDim2.new(0, 640, 0, 440)
    end)

    -- Sidebar
    local side = Instance.new("Frame", main)
    side.Size = UDim2.new(0, 130, 1, -40); side.Position = UDim2.new(0, 6, 0, 36)
    side.BackgroundColor3 = T.panel; side.BorderSizePixel = 0
    corner(side, 6)
    local sl = Instance.new("UIListLayout", side); sl.Padding = UDim.new(0, 4)
    sl.SortOrder = Enum.SortOrder.LayoutOrder
    padding(side, 6)

    local content = Instance.new("Frame", main)
    content.Size = UDim2.new(1, -150, 1, -40); content.Position = UDim2.new(0, 142, 0, 36)
    content.BackgroundColor3 = T.panel; content.BorderSizePixel = 0
    corner(content, 6)

    local tabs = {}
    local function makeTabPanel()
        local p = Instance.new("ScrollingFrame", content)
        p.Size = UDim2.new(1, 0, 1, 0); p.BackgroundTransparency = 1
        p.BorderSizePixel = 0; p.ScrollBarThickness = 4
        p.CanvasSize = UDim2.new(0, 0, 0, 0); p.Visible = false
        local lay = Instance.new("UIListLayout", p); lay.Padding = UDim.new(0, 6)
        lay.SortOrder = Enum.SortOrder.LayoutOrder
        padding(p, 12)
        lay:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            p.CanvasSize = UDim2.new(0, 0, 0, lay.AbsoluteContentSize.Y + 24)
        end)
        return p
    end
    local function makeTabBtn(name, order)
        local b = Instance.new("TextButton", side)
        b.LayoutOrder = order
        b.Size = UDim2.new(1, 0, 0, 28)
        b.BackgroundColor3 = T.panel2; b.BorderSizePixel = 0
        b.Font = Enum.Font.GothamSemibold; b.TextSize = 12
        b.TextColor3 = T.text; b.TextXAlignment = Enum.TextXAlignment.Left
        b.Text = "  " .. name
        corner(b, 4)
        return b
    end
    local function selectTab(name)
        for n, t in pairs(tabs) do
            t.panel.Visible = (n == name)
            t.button.BackgroundColor3 = (n == name) and T.accentD or T.panel2
        end
    end

    local locked = not Ctx.IsPremium

    -- Home tab
    do
        local p = makeTabPanel()
        local b = makeTabBtn("Home", 1)
        b.MouseButton1Click:Connect(function() selectTab("Home") end)
        tabs.Home = { panel = p, button = b }

        W.Section(p, "Zurly Hub — Grow a Garden")
        W.TextLabel(p, string.format(
            "Status: %s\nAccount: %s\nExpiry: %s",
            Ctx.IsPremium and "PREMIUM ACTIVE" or "FREE VERSION",
            LP.Name,
            Ctx.Expiry > 0 and os.date("%d/%m/%Y %H:%M", Ctx.Expiry) or "N/A"
        ), 56)

        W.Section(p, "Quick Actions")
        W.Button(p, "Vender Agora (uma vez)", false, function() Ctx.Shop:SellOnce() end)
        W.Button(p, "TP para Shop",   false, function() Ctx.Teleport:ToShop() end)
        W.Button(p, "TP para Garden", false, function() Ctx.Teleport:ToGarden() end)
        W.Button(p, "TP para Sell",   false, function() Ctx.Teleport:ToSelling() end)
    end

    -- Farm tab
    do
        local p = makeTabPanel()
        local b = makeTabBtn("Farm", 2)
        b.MouseButton1Click:Connect(function() selectTab("Farm") end)
        tabs.Farm = { panel = p, button = b }

        W.Section(p, "Free")
        W.Toggle(p, "Auto Harvest", false, cfg.auto_harvest, function(v)
            cfg.auto_harvest = v; Ctx.Plants:SetAutoHarvest(v)
            if Ctx.IsPremium then Ctx.Config:Save(cfg) end
        end)
        W.Toggle(p, "Auto Sell Inventory", false, cfg.auto_sell, function(v)
            cfg.auto_sell = v; Ctx.Shop:SetAutoSell(v)
            if Ctx.IsPremium then Ctx.Config:Save(cfg) end
        end)
        W.Toggle(p, "Auto Plant", false, cfg.auto_plant, function(v)
            cfg.auto_plant = v; Ctx.Plants:SetAutoPlant(v)
            if Ctx.IsPremium then Ctx.Config:Save(cfg) end
        end)
        W.Input(p, "Seed Name (Carrot, Strawberry, ...)", cfg.plant_seed, false, function(v)
            cfg.plant_seed = v; Ctx.Plants:SetSeed(v)
            if Ctx.IsPremium then Ctx.Config:Save(cfg) end
        end)
        W.Slider(p, "Plant Delay (s/10)", false, 1, 30, math.floor(cfg.plant_delay * 10), function(v)
            cfg.plant_delay = v / 10; Ctx.Plants:SetDelay(v / 10)
            if Ctx.IsPremium then Ctx.Config:Save(cfg) end
        end)
        W.Slider(p, "Auto Sell Delay (s)", false, 5, 120, cfg.auto_sell_delay, function(v)
            cfg.auto_sell_delay = v
            if Ctx.IsPremium then Ctx.Config:Save(cfg) end
        end)

        W.Section(p, "Pets — Premium")
        W.Toggle(p, "Auto Fuse Pets", locked, cfg.auto_fuse, function(v)
            cfg.auto_fuse = v; Ctx.Pets:SetAutoFuse(v); Ctx.Config:Save(cfg)
        end)
        W.Toggle(p, "Auto Equip Best Pet", locked, cfg.auto_equip_best, function(v)
            cfg.auto_equip_best = v; Ctx.Pets:SetAutoEquipBest(v); Ctx.Config:Save(cfg)
        end)
        W.Toggle(p, "Auto Buy Rare Seeds", locked, cfg.auto_buy_seeds, function(v)
            cfg.auto_buy_seeds = v
            Ctx.Shop:SetBuyList({
                ["Dragon Fruit"] = true, ["Watermelon"] = true, ["Pumpkin"] = true,
                ["Mushroom"] = true, ["Pepper"] = true, ["Cactus"] = true,
            })
            Ctx.Shop:SetAutoBuySeeds(v); Ctx.Config:Save(cfg)
        end)
        W.Toggle(p, "ESP Pets com Mutation Rara", locked, cfg.esp_rare_pets, function(v)
            cfg.esp_rare_pets = v; Ctx.Pets:SetESP(v); Ctx.Config:Save(cfg)
        end)
    end

    -- Player tab
    do
        local p = makeTabPanel()
        local b = makeTabBtn("Player", 3)
        b.MouseButton1Click:Connect(function() selectTab("Player") end)
        tabs.Player = { panel = p, button = b }

        W.Section(p, "Movement")
        W.Toggle(p, "Flight (WASD + Space/Ctrl)", false, cfg.flight, function(v)
            cfg.flight = v; Ctx.Player:SetFlight(v)
            if Ctx.IsPremium then Ctx.Config:Save(cfg) end
        end)
        W.Slider(p, "Flight Speed", false, 10, 200, cfg.flight_speed, function(v)
            cfg.flight_speed = v; Ctx.Player:SetFlightSpeed(v)
            if Ctx.IsPremium then Ctx.Config:Save(cfg) end
        end)
        W.Slider(p, "Walk Speed", false, 8, 100, cfg.walkspeed, function(v)
            cfg.walkspeed = v; Ctx.Player:SetWalkSpeed(v)
            if Ctx.IsPremium then Ctx.Config:Save(cfg) end
        end)
        W.Slider(p, "Jump Power", false, 20, 200, cfg.jumppower, function(v)
            cfg.jumppower = v; Ctx.Player:SetJumpPower(v)
            if Ctx.IsPremium then Ctx.Config:Save(cfg) end
        end)

        W.Section(p, "Anti-AFK")
        W.Toggle(p, "Anti-AFK (never kick)", false, true, function(v)
            Ctx.Player:SetAntiAFK(v)
        end)
    end

    -- Premium tab
    do
        local p = makeTabPanel()
        local b = makeTabBtn("Premium", 4)
        b.MouseButton1Click:Connect(function() selectTab("Premium") end)
        tabs.Premium = { panel = p, button = b }

        W.Section(p, "Status")
        local status = Instance.new("TextLabel", p)
        status.Size = UDim2.new(1, 0, 0, 36); status.BackgroundTransparency = 1
        status.Font = Enum.Font.GothamBold; status.TextSize = 14
        status.TextColor3 = Ctx.IsPremium and T.accent or T.danger
        status.TextXAlignment = Enum.TextXAlignment.Left; status.TextWrapped = true
        status.Text = Ctx.IsPremium
            and ("ATIVO ate " .. os.date("%d/%m/%Y %H:%M", Ctx.Expiry))
            or "INATIVO — cole sua key abaixo"

        if not Ctx.IsPremium then
            W.Section(p, "Ativar Premium")
            local keyBox = W.Input(p, "COLE SUA KEY AQUI", "", false, nil)
            local result = W.TextLabel(p, "", 20)
            W.Button(p, "ATIVAR PREMIUM", false, function()
                local key = keyBox.Text:gsub("%s+", "")
                if #key < 8 then result.Text = "Key muito curta"; result.TextColor3 = T.danger; return end
                result.Text = "Validando..."; result.TextColor3 = T.textDim
                task.spawn(function()
                    local ok, info = Ctx.KeyAuth:Validate(key)
                    if ok then
                        Ctx.KeyAuth:SaveCache(key, info.expires_at)
                        result.Text = "SUCESSO! Expira: " .. os.date("%d/%m/%Y", info.expires_at)
                        result.TextColor3 = T.accent
                        task.wait(1.5)
                        gui:Destroy()
                        loadstring(game:HttpGet(getgenv().NXS_BASE .. "/loader.lua"))()
                    else
                        result.Text = "ERRO: " .. tostring(info)
                        result.TextColor3 = T.danger
                    end
                end)
            end)
        else
            W.Button(p, "Desativar Premium (reset local)", false, function()
                Ctx.KeyAuth:ClearCache(); gui:Destroy()
                loadstring(game:HttpGet(getgenv().NXS_BASE .. "/loader.lua"))()
            end)
        end

        W.Section(p, "Features Premium")
        for _, f in ipairs({
            "Auto Fuse Pets — fundir pra mutations raras",
            "Auto Equip Best Pet",
            "Auto Buy Rare Seeds (Dragon Fruit, Pumpkin, Mushroom...)",
            "ESP Pets Raros (Rainbow / Golden / Rot / Warped)",
            "Webhook Discord — notifica drops raros",
            "Config save/load persistente",
        }) do
            W.TextLabel(p, (Ctx.IsPremium and "[OK] " or "[  ] ") .. f, 18)
        end
    end

    -- Settings tab
    do
        local p = makeTabPanel()
        local b = makeTabBtn("Settings", 5)
        b.MouseButton1Click:Connect(function() selectTab("Settings") end)
        tabs.Settings = { panel = p, button = b }

        W.Section(p, "Webhook Discord")
        W.Input(p, "https://discord.com/api/webhooks/...",
                cfg.webhook_url, not Ctx.IsPremium, function(v)
            cfg.webhook_url = v; Ctx.Webhook:SetUrl(v)
            if Ctx.IsPremium then Ctx.Config:Save(cfg) end
        end)
        W.Button(p, "Testar Webhook", not Ctx.IsPremium, function() Ctx.Webhook:Test() end)

        W.Section(p, "Interface")
        W.TextLabel(p, "Toggle menu: " .. cfg.menu_hotkey ..
                       "   |   Drag na barra pra mover", 32)
    end

    selectTab("Home")
    Ctx.Webhook:SetUrl(cfg.webhook_url or "")

    UIS.InputBegan:Connect(function(i, gp)
        if gp then return end
        if i.KeyCode == Enum.KeyCode[cfg.menu_hotkey] then
            main.Visible = not main.Visible
        end
    end)

    return gui
end

return UI
