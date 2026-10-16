-- Zurly Hub — Grow a Garden UI (modern dark + crimson, floating toggle, debug tab)
local UI = {}

local CoreGui = game:GetService("CoreGui")
local UIS     = game:GetService("UserInputService")
local Players = game:GetService("Players")
local RS      = game:GetService("ReplicatedStorage")
local TS      = game:GetService("TweenService")
local LP      = Players.LocalPlayer

function UI:Build(Ctx, cfg)
    local T = Ctx.Theme
    local W = Ctx.UIWidgets.New(T)
    local corner = Ctx.UIWidgets.corner
    local stroke = Ctx.UIWidgets.stroke
    local padding = Ctx.UIWidgets.padding
    local gradient = Ctx.UIWidgets.gradient

    if CoreGui:FindFirstChild("ZurlyHub_GG") then CoreGui.ZurlyHub_GG:Destroy() end
    local gui = Instance.new("ScreenGui")
    gui.Name = "ZurlyHub_GG"; gui.ResetOnSpawn = false
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    gui.IgnoreGuiInset = true
    gui.Parent = CoreGui

    -- ========== Floating Toggle Button ==========
    local toggleBtn = Instance.new("TextButton", gui)
    toggleBtn.Name = "ToggleBtn"
    toggleBtn.Size = UDim2.new(0, 48, 0, 48)
    toggleBtn.Position = UDim2.new(0, 20, 0, 20)
    toggleBtn.BackgroundColor3 = T.accent
    toggleBtn.BorderSizePixel = 0
    toggleBtn.Text = "Z"
    toggleBtn.Font = Enum.Font.GothamBold
    toggleBtn.TextSize = 22
    toggleBtn.TextColor3 = Color3.new(1,1,1)
    toggleBtn.AutoButtonColor = false
    toggleBtn.Active = true
    toggleBtn.Draggable = true
    corner(toggleBtn, 24)
    stroke(toggleBtn, T.accentL, 2, 0.2)

    -- Hover anim
    toggleBtn.MouseEnter:Connect(function()
        TS:Create(toggleBtn, TweenInfo.new(0.15), {Size = UDim2.new(0, 54, 0, 54)}):Play()
    end)
    toggleBtn.MouseLeave:Connect(function()
        TS:Create(toggleBtn, TweenInfo.new(0.15), {Size = UDim2.new(0, 48, 0, 48)}):Play()
    end)

    -- ========== Main Window ==========
    local main = Instance.new("Frame", gui)
    main.Name = "Main"
    main.Size = UDim2.new(0, 680, 0, 460)
    main.Position = UDim2.new(0.5, -340, 0.5, -230)
    main.BackgroundColor3 = T.bg
    main.BorderSizePixel = 0
    main.Active = true; main.Draggable = true
    main.Visible = false
    corner(main, 10)
    stroke(main, T.border, 1, 0.3)

    toggleBtn.MouseButton1Click:Connect(function()
        main.Visible = not main.Visible
    end)

    -- Title bar with gradient
    local title = Instance.new("Frame", main)
    title.Size = UDim2.new(1, 0, 0, 44); title.BackgroundColor3 = T.panel
    title.BorderSizePixel = 0
    corner(title, 10)
    local titleFix = Instance.new("Frame", title)
    titleFix.Size = UDim2.new(1, 0, 0.5, 0); titleFix.Position = UDim2.new(0, 0, 0.5, 0)
    titleFix.BackgroundColor3 = T.panel; titleFix.BorderSizePixel = 0

    local brandDot = Instance.new("Frame", title)
    brandDot.Size = UDim2.new(0, 8, 0, 8); brandDot.Position = UDim2.new(0, 16, 0.5, -4)
    brandDot.BackgroundColor3 = T.accent; brandDot.BorderSizePixel = 0
    corner(brandDot, 4)

    local titleTxt = Instance.new("TextLabel", title)
    titleTxt.Size = UDim2.new(1, -140, 1, 0); titleTxt.Position = UDim2.new(0, 32, 0, 0)
    titleTxt.BackgroundTransparency = 1
    titleTxt.Font = Enum.Font.GothamBold; titleTxt.TextSize = 14
    titleTxt.TextColor3 = T.text
    titleTxt.TextXAlignment = Enum.TextXAlignment.Left
    titleTxt.Text = T.brand .. "   /   Grow a Garden"

    local badge = Instance.new("TextLabel", title)
    badge.Size = UDim2.new(0, 72, 0, 22); badge.Position = UDim2.new(1, -156, 0.5, -11)
    badge.BackgroundColor3 = Ctx.IsPremium and T.accent or T.panel3
    badge.BorderSizePixel = 0
    badge.Font = Enum.Font.GothamBold; badge.TextSize = 10
    badge.TextColor3 = Ctx.IsPremium and Color3.new(1,1,1) or T.textDim
    badge.Text = Ctx.IsPremium and "PREMIUM" or "FREE"
    corner(badge, 11)

    local closeBtn = Instance.new("TextButton", title)
    closeBtn.Size = UDim2.new(0, 28, 0, 28); closeBtn.Position = UDim2.new(1, -36, 0.5, -14)
    closeBtn.BackgroundColor3 = T.panel3; closeBtn.BorderSizePixel = 0
    closeBtn.Font = Enum.Font.GothamBold; closeBtn.TextSize = 14
    closeBtn.TextColor3 = T.textDim; closeBtn.Text = "X"
    closeBtn.AutoButtonColor = false
    corner(closeBtn, 6)
    closeBtn.MouseButton1Click:Connect(function() main.Visible = false end)
    closeBtn.MouseEnter:Connect(function()
        TS:Create(closeBtn, TweenInfo.new(0.1), {BackgroundColor3 = T.danger, TextColor3 = Color3.new(1,1,1)}):Play()
    end)
    closeBtn.MouseLeave:Connect(function()
        TS:Create(closeBtn, TweenInfo.new(0.1), {BackgroundColor3 = T.panel3, TextColor3 = T.textDim}):Play()
    end)

    -- Sidebar
    local side = Instance.new("Frame", main)
    side.Size = UDim2.new(0, 148, 1, -56); side.Position = UDim2.new(0, 8, 0, 50)
    side.BackgroundColor3 = T.panel; side.BorderSizePixel = 0
    corner(side, 8)
    local sl = Instance.new("UIListLayout", side)
    sl.Padding = UDim.new(0, 4); sl.SortOrder = Enum.SortOrder.LayoutOrder
    padding(side, 8)

    local content = Instance.new("Frame", main)
    content.Size = UDim2.new(1, -168, 1, -56); content.Position = UDim2.new(0, 160, 0, 50)
    content.BackgroundColor3 = T.panel; content.BorderSizePixel = 0
    corner(content, 8)

    local tabs = {}
    local function makeTabPanel()
        local p = Instance.new("ScrollingFrame", content)
        p.Size = UDim2.new(1, 0, 1, 0); p.BackgroundTransparency = 1
        p.BorderSizePixel = 0; p.ScrollBarThickness = 3
        p.ScrollBarImageColor3 = T.accent
        p.CanvasSize = UDim2.new(0, 0, 0, 0); p.Visible = false
        local lay = Instance.new("UIListLayout", p)
        lay.Padding = UDim.new(0, 8); lay.SortOrder = Enum.SortOrder.LayoutOrder
        padding(p, 16)
        lay:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            p.CanvasSize = UDim2.new(0, 0, 0, lay.AbsoluteContentSize.Y + 32)
        end)
        return p
    end
    local function makeTabBtn(name, order)
        local b = Instance.new("TextButton", side)
        b.LayoutOrder = order
        b.Size = UDim2.new(1, 0, 0, 34)
        b.BackgroundColor3 = T.panel; b.BorderSizePixel = 0
        b.Font = Enum.Font.GothamMedium; b.TextSize = 12
        b.TextColor3 = T.textDim; b.TextXAlignment = Enum.TextXAlignment.Left
        b.Text = "   " .. name
        b.AutoButtonColor = false
        corner(b, 6)
        local indicator = Instance.new("Frame", b)
        indicator.Size = UDim2.new(0, 3, 0.6, 0); indicator.Position = UDim2.new(0, 0, 0.2, 0)
        indicator.BackgroundColor3 = T.accent; indicator.BorderSizePixel = 0
        indicator.Visible = false
        corner(indicator, 2)
        b.MouseEnter:Connect(function()
            if not b:GetAttribute("Active") then
                TS:Create(b, TweenInfo.new(0.1), {BackgroundColor3 = T.panel2}):Play()
            end
        end)
        b.MouseLeave:Connect(function()
            if not b:GetAttribute("Active") then
                TS:Create(b, TweenInfo.new(0.1), {BackgroundColor3 = T.panel}):Play()
            end
        end)
        return b, indicator
    end
    local function selectTab(name)
        for n, t in pairs(tabs) do
            t.panel.Visible = (n == name)
            t.button.BackgroundColor3 = (n == name) and T.panel2 or T.panel
            t.button.TextColor3 = (n == name) and T.text or T.textDim
            t.indicator.Visible = (n == name)
            t.button:SetAttribute("Active", n == name)
        end
    end

    local locked = not Ctx.IsPremium

    -- ========== Home ==========
    do
        local p = makeTabPanel()
        local b, ind = makeTabBtn("Home", 1)
        b.MouseButton1Click:Connect(function() selectTab("Home") end)
        tabs.Home = { panel = p, button = b, indicator = ind }

        W.Section(p, "Zurly Hub")
        local card = Instance.new("Frame", p)
        card.Size = UDim2.new(1, 0, 0, 90); card.BackgroundColor3 = T.panel2
        card.BorderSizePixel = 0
        corner(card, 8)
        padding(card, 14)
        local info = Instance.new("TextLabel", card)
        info.Size = UDim2.new(1, 0, 1, 0); info.BackgroundTransparency = 1
        info.Font = Enum.Font.Gotham; info.TextSize = 12
        info.TextColor3 = T.text
        info.TextXAlignment = Enum.TextXAlignment.Left
        info.TextYAlignment = Enum.TextYAlignment.Top
        info.Text = string.format(
            "Status  %s\nPlayer  %s\nExpiry  %s",
            Ctx.IsPremium and "PREMIUM ACTIVE" or "FREE VERSION",
            LP.Name,
            Ctx.Expiry > 0 and os.date("%d/%m/%Y %H:%M", Ctx.Expiry) or "N/A"
        )

        W.Section(p, "Quick Actions")
        W.Button(p, "Vender Tudo Agora", false, function() Ctx.Shop:SellOnce() end)
        W.Button(p, "TP para Shop",   false, function() Ctx.Teleport:ToShop() end)
        W.Button(p, "TP para Garden", false, function() Ctx.Teleport:ToGarden() end)
        W.Button(p, "TP para Sell Area", false, function() Ctx.Teleport:ToSelling() end)
    end

    -- ========== Farm ==========
    do
        local p = makeTabPanel()
        local b, ind = makeTabBtn("Farm", 2)
        b.MouseButton1Click:Connect(function() selectTab("Farm") end)
        tabs.Farm = { panel = p, button = b, indicator = ind }

        W.Section(p, "Automation")
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
        W.Input(p, "Seed name  (Carrot, Strawberry, Pumpkin...)", cfg.plant_seed, false, function(v)
            cfg.plant_seed = v; Ctx.Plants:SetSeed(v)
            if Ctx.IsPremium then Ctx.Config:Save(cfg) end
        end)

        W.Section(p, "Timing")
        W.Slider(p, "Plant Delay (×0.1s)", false, 1, 30, math.floor(cfg.plant_delay * 10), function(v)
            cfg.plant_delay = v / 10; Ctx.Plants:SetDelay(v / 10)
            if Ctx.IsPremium then Ctx.Config:Save(cfg) end
        end)
        W.Slider(p, "Sell Interval (s)", false, 5, 120, cfg.auto_sell_delay, function(v)
            cfg.auto_sell_delay = v
            if Ctx.IsPremium then Ctx.Config:Save(cfg) end
        end)

        W.Section(p, "Pets — Premium")
        W.Toggle(p, "Auto Fuse Pets", locked, cfg.auto_fuse, function(v)
            cfg.auto_fuse = v; Ctx.Pets:SetAutoFuse(v); Ctx.Config:Save(cfg)
        end)
        W.Toggle(p, "Auto Equip Best", locked, cfg.auto_equip_best, function(v)
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
        W.Toggle(p, "ESP Pets Raros", locked, cfg.esp_rare_pets, function(v)
            cfg.esp_rare_pets = v; Ctx.Pets:SetESP(v); Ctx.Config:Save(cfg)
        end)
    end

    -- ========== Player ==========
    do
        local p = makeTabPanel()
        local b, ind = makeTabBtn("Player", 3)
        b.MouseButton1Click:Connect(function() selectTab("Player") end)
        tabs.Player = { panel = p, button = b, indicator = ind }

        W.Section(p, "Movement")
        W.Toggle(p, "Flight  (WASD + Space / Ctrl)", false, cfg.flight, function(v)
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
        W.Toggle(p, "Nunca ser kickado por AFK", false, true, function(v)
            Ctx.Player:SetAntiAFK(v)
        end)
    end

    -- ========== Debug ==========
    do
        local p = makeTabPanel()
        local b, ind = makeTabBtn("Debug", 4)
        b.MouseButton1Click:Connect(function() selectTab("Debug") end)
        tabs.Debug = { panel = p, button = b, indicator = ind }

        W.Section(p, "Remote Discovery")
        W.TextLabel(p, "Clica Scan pra listar remotes do jogo. Usa isso pra achar nomes de RemoteEvents (Plant, Sell, Harvest, Fuse...) que o jogo usa.", 44)

        local output = Instance.new("Frame", p)
        output.Size = UDim2.new(1, 0, 0, 220); output.BackgroundColor3 = T.panel2
        output.BorderSizePixel = 0
        corner(output, 6)
        local scroll = Instance.new("ScrollingFrame", output)
        scroll.Size = UDim2.new(1, -8, 1, -8); scroll.Position = UDim2.new(0, 4, 0, 4)
        scroll.BackgroundTransparency = 1; scroll.BorderSizePixel = 0
        scroll.ScrollBarThickness = 2; scroll.ScrollBarImageColor3 = T.accent
        scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
        local lay = Instance.new("UIListLayout", scroll)
        lay.Padding = UDim.new(0, 2); lay.SortOrder = Enum.SortOrder.LayoutOrder

        W.Button(p, "Scan Remotes do Jogo", false, function()
            for _, c in ipairs(scroll:GetChildren()) do
                if c:IsA("TextLabel") then c:Destroy() end
            end
            local remotes = {}
            for _, inst in ipairs(RS:GetDescendants()) do
                if inst:IsA("RemoteEvent") or inst:IsA("RemoteFunction") then
                    table.insert(remotes, inst)
                end
            end
            table.sort(remotes, function(a, b) return a.Name < b.Name end)
            for _, r in ipairs(remotes) do
                local l = Instance.new("TextLabel", scroll)
                l.Size = UDim2.new(1, -8, 0, 16); l.BackgroundTransparency = 1
                l.Font = Enum.Font.Code; l.TextSize = 10
                l.TextColor3 = T.text; l.TextXAlignment = Enum.TextXAlignment.Left
                local pad = Instance.new("UIPadding", l)
                pad.PaddingLeft = UDim.new(0, 6)
                l.Text = string.format("[%s]  %s", r.ClassName:sub(1, 7), r:GetFullName())
            end
            scroll.CanvasSize = UDim2.new(0, 0, 0, #remotes * 18)
            print("[Zurly Debug] Scanned", #remotes, "remotes — see list in Debug tab")
        end)

        W.Section(p, "Manual Remote Fire")
        local pathBox = W.Input(p, "ReplicatedStorage.GameEvents.PlantSeed", "", false, nil)
        local argsBox = W.Input(p, 'args JSON  ["Carrot", 1] or []', "[]", false, nil)
        W.Button(p, "FIRE Server (RemoteEvent)", false, function()
            local HttpService = game:GetService("HttpService")
            local pathStr = pathBox.Text
            -- Resolve path
            local target = game
            for seg in pathStr:gmatch("[^%.]+") do
                target = target:FindFirstChild(seg)
                if not target then warn("[Zurly] Path not found at:", seg); return end
            end
            if not target then warn("[Zurly] No remote at path"); return end
            local args = {}
            if argsBox.Text:match("%S") then
                local ok, parsed = pcall(HttpService.JSONDecode, HttpService, argsBox.Text)
                if ok and type(parsed) == "table" then args = parsed end
            end
            pcall(function()
                if target:IsA("RemoteEvent") then target:FireServer(table.unpack(args))
                elseif target:IsA("RemoteFunction") then target:InvokeServer(table.unpack(args))
                end
            end)
            print("[Zurly Debug] Fired", target:GetFullName())
        end)
    end

    -- ========== Premium ==========
    do
        local p = makeTabPanel()
        local b, ind = makeTabBtn("Premium", 5)
        b.MouseButton1Click:Connect(function() selectTab("Premium") end)
        tabs.Premium = { panel = p, button = b, indicator = ind }

        W.Section(p, "Status")
        local card = Instance.new("Frame", p)
        card.Size = UDim2.new(1, 0, 0, 54); card.BackgroundColor3 = T.panel2
        card.BorderSizePixel = 0
        corner(card, 8); padding(card, 14)
        local st = Instance.new("TextLabel", card)
        st.Size = UDim2.new(1, 0, 1, 0); st.BackgroundTransparency = 1
        st.Font = Enum.Font.GothamBold; st.TextSize = 14
        st.TextColor3 = Ctx.IsPremium and T.success or T.danger
        st.TextXAlignment = Enum.TextXAlignment.Left
        st.TextYAlignment = Enum.TextYAlignment.Top
        st.Text = Ctx.IsPremium
            and ("PREMIUM ATIVO\nExpira " .. os.date("%d/%m/%Y %H:%M", Ctx.Expiry))
            or "SEM PREMIUM"

        if not Ctx.IsPremium then
            W.Section(p, "Ativar Premium")
            local keyBox = W.Input(p, "COLE SUA KEY AQUI", "", false, nil)
            local result = W.TextLabel(p, "", 20)
            W.Button(p, "ATIVAR", false, function()
                local key = keyBox.Text:gsub("%s+", "")
                if #key < 8 then result.Text = "Key muito curta"; result.TextColor3 = T.danger; return end
                result.Text = "Validando..."; result.TextColor3 = T.textDim
                task.spawn(function()
                    local ok, info = Ctx.KeyAuth:Validate(key)
                    if ok then
                        Ctx.KeyAuth:SaveCache(key, info.expires_at)
                        result.Text = "SUCESSO. Expira " .. os.date("%d/%m/%Y", info.expires_at)
                        result.TextColor3 = T.success
                        task.wait(1.5)
                        gui:Destroy()
                        loadstring(game:HttpGet((getgenv().ZURLY_BASE or getgenv().NXS_BASE) .. "/loader.lua"))()
                    else
                        result.Text = "ERRO: " .. tostring(info); result.TextColor3 = T.danger
                    end
                end)
            end)
        else
            W.Button(p, "Resetar cache local (desativar)", false, function()
                Ctx.KeyAuth:ClearCache(); gui:Destroy()
                loadstring(game:HttpGet((getgenv().ZURLY_BASE or getgenv().NXS_BASE) .. "/loader.lua"))()
            end)
        end

        W.Section(p, "Features Premium")
        for _, f in ipairs({
            "Auto Fuse Pets (combina pra mutations raras)",
            "Auto Equip Best Pet",
            "Auto Buy Rare Seeds",
            "ESP Pets com Mutation Rara",
            "Webhook Discord (notifica drops)",
            "Config save/load persistente",
        }) do
            W.TextLabel(p, (Ctx.IsPremium and "✓  " or "○  ") .. f, 18,
                Ctx.IsPremium and T.text or T.textDim)
        end
    end

    -- ========== Settings ==========
    do
        local p = makeTabPanel()
        local b, ind = makeTabBtn("Settings", 6)
        b.MouseButton1Click:Connect(function() selectTab("Settings") end)
        tabs.Settings = { panel = p, button = b, indicator = ind }

        W.Section(p, "Webhook Discord")
        W.Input(p, "https://discord.com/api/webhooks/...",
                cfg.webhook_url, not Ctx.IsPremium, function(v)
            cfg.webhook_url = v; Ctx.Webhook:SetUrl(v)
            if Ctx.IsPremium then Ctx.Config:Save(cfg) end
        end)
        W.Button(p, "Testar Webhook", not Ctx.IsPremium, function() Ctx.Webhook:Test() end)

        W.Section(p, "Interface")
        W.TextLabel(p, "Clica no círculo Z pra abrir/fechar o menu\nArrasta a barra do título pra mover", 36)
    end

    selectTab("Home")
    Ctx.Webhook:SetUrl(cfg.webhook_url or "")

    -- Backward-compat hotkey
    UIS.InputBegan:Connect(function(i, gp)
        if gp then return end
        if i.KeyCode == Enum.KeyCode[cfg.menu_hotkey] then
            main.Visible = not main.Visible
        end
    end)

    return gui
end

return UI
