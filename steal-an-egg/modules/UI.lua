-- NXS UI — custom ImGui-style black/green theme (Instance.new)
-- Tabs: Home | Farm | Player | Teleport | Premium | Settings
-- Pro features visually locked when Ctx.IsPremium is false.

local UI = {}

local CoreGui = game:GetService("CoreGui")
local UIS     = game:GetService("UserInputService")
local TS      = game:GetService("TweenService")
local Players = game:GetService("Players")
local LP      = Players.LocalPlayer

local THEME = {
    bg       = Color3.fromRGB(10, 15, 10),
    panel    = Color3.fromRGB(16, 24, 15),
    panel2   = Color3.fromRGB(22, 32, 22),
    border   = Color3.fromRGB(0, 180, 80),
    accent   = Color3.fromRGB(0, 200, 80),
    accentD  = Color3.fromRGB(0, 150, 60),
    text     = Color3.fromRGB(230, 240, 230),
    textDim  = Color3.fromRGB(140, 160, 140),
    locked   = Color3.fromRGB(70, 70, 70),
    danger   = Color3.fromRGB(220, 60, 60),
}

local function corner(parent, r)
    local c = Instance.new("UICorner", parent)
    c.CornerRadius = UDim.new(0, r or 4)
    return c
end
local function stroke(parent, color, thick)
    local s = Instance.new("UIStroke", parent)
    s.Color = color or THEME.border
    s.Thickness = thick or 1
    s.Transparency = 0.4
    return s
end
local function padding(parent, p)
    local u = Instance.new("UIPadding", parent)
    u.PaddingLeft = UDim.new(0, p); u.PaddingRight = UDim.new(0, p)
    u.PaddingTop = UDim.new(0, p); u.PaddingBottom = UDim.new(0, p)
    return u
end

-- --------------- Widget helpers ---------------
local function createToggle(parent, label, locked, initial, onChange)
    local row = Instance.new("Frame", parent)
    row.Size = UDim2.new(1, 0, 0, 28); row.BackgroundTransparency = 1

    local btn = Instance.new("TextButton", row)
    btn.Size = UDim2.new(0, 40, 0, 20); btn.Position = UDim2.new(0, 0, 0, 4)
    btn.BackgroundColor3 = initial and THEME.accent or THEME.panel2
    btn.Text = ""; btn.AutoButtonColor = false
    corner(btn, 10)

    local knob = Instance.new("Frame", btn)
    knob.Size = UDim2.new(0, 16, 0, 16); knob.Position = UDim2.new(0, initial and 22 or 2, 0.5, -8)
    knob.BackgroundColor3 = Color3.new(1,1,1); knob.BorderSizePixel = 0
    corner(knob, 8)

    local lbl = Instance.new("TextLabel", row)
    lbl.Size = UDim2.new(1, -50, 1, 0); lbl.Position = UDim2.new(0, 50, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Font = Enum.Font.Gotham; lbl.TextSize = 13
    lbl.TextColor3 = locked and THEME.locked or THEME.text
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Text = label .. (locked and "  🔒 Premium" or "")

    local state = initial or false
    btn.MouseButton1Click:Connect(function()
        if locked then return end
        state = not state
        TS:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = state and THEME.accent or THEME.panel2}):Play()
        TS:Create(knob, TweenInfo.new(0.15), {Position = UDim2.new(0, state and 22 or 2, 0.5, -8)}):Play()
        if onChange then onChange(state) end
    end)
    return btn, function(v)
        state = v
        btn.BackgroundColor3 = v and THEME.accent or THEME.panel2
        knob.Position = UDim2.new(0, v and 22 or 2, 0.5, -8)
    end
end

local function createSlider(parent, label, locked, min, max, initial, onChange)
    local row = Instance.new("Frame", parent)
    row.Size = UDim2.new(1, 0, 0, 44); row.BackgroundTransparency = 1

    local lbl = Instance.new("TextLabel", row)
    lbl.Size = UDim2.new(1, 0, 0, 18); lbl.BackgroundTransparency = 1
    lbl.Font = Enum.Font.Gotham; lbl.TextSize = 12
    lbl.TextColor3 = locked and THEME.locked or THEME.textDim
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Text = string.format("%s: %d%s", label, initial, locked and "  🔒" or "")

    local bar = Instance.new("Frame", row)
    bar.Size = UDim2.new(1, -8, 0, 6); bar.Position = UDim2.new(0, 0, 0, 24)
    bar.BackgroundColor3 = THEME.panel2; bar.BorderSizePixel = 0
    corner(bar, 3)

    local fill = Instance.new("Frame", bar)
    local pct = (initial - min) / (max - min)
    fill.Size = UDim2.new(pct, 0, 1, 0); fill.BackgroundColor3 = locked and THEME.locked or THEME.accent
    fill.BorderSizePixel = 0
    corner(fill, 3)

    local handle = Instance.new("TextButton", bar)
    handle.Size = UDim2.new(0, 14, 0, 14); handle.Position = UDim2.new(pct, -7, 0.5, -7)
    handle.BackgroundColor3 = Color3.new(1,1,1); handle.Text = ""; handle.AutoButtonColor = false
    corner(handle, 7)

    local dragging = false
    handle.MouseButton1Down:Connect(function() if not locked then dragging = true end end)
    UIS.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)
    UIS.InputChanged:Connect(function(i)
        if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
            local rel = (i.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X
            rel = math.clamp(rel, 0, 1)
            local val = math.floor(min + (max - min) * rel + 0.5)
            fill.Size = UDim2.new(rel, 0, 1, 0)
            handle.Position = UDim2.new(rel, -7, 0.5, -7)
            lbl.Text = string.format("%s: %d%s", label, val, locked and "  🔒" or "")
            if onChange then onChange(val) end
        end
    end)
    return row
end

local function createButton(parent, label, locked, onClick)
    local b = Instance.new("TextButton", parent)
    b.Size = UDim2.new(1, 0, 0, 30)
    b.BackgroundColor3 = locked and THEME.locked or THEME.accentD
    b.BorderSizePixel = 0
    b.Font = Enum.Font.GothamSemibold; b.TextSize = 13
    b.TextColor3 = THEME.text
    b.Text = label .. (locked and "  🔒" or "")
    b.AutoButtonColor = not locked
    corner(b, 4)
    b.MouseButton1Click:Connect(function()
        if locked then return end
        if onClick then onClick() end
    end)
    return b
end

local function createInput(parent, placeholder, initial, locked, onChange)
    local box = Instance.new("TextBox", parent)
    box.Size = UDim2.new(1, 0, 0, 30)
    box.BackgroundColor3 = THEME.panel2; box.BorderSizePixel = 0
    box.Font = Enum.Font.Code; box.TextSize = 13
    box.TextColor3 = locked and THEME.locked or THEME.text
    box.PlaceholderText = placeholder; box.PlaceholderColor3 = THEME.textDim
    box.Text = initial or ""; box.ClearTextOnFocus = false
    box.TextEditable = not locked
    corner(box, 4)
    local pad = Instance.new("UIPadding", box)
    pad.PaddingLeft = UDim.new(0, 8); pad.PaddingRight = UDim.new(0, 8)
    box.FocusLost:Connect(function()
        if locked then return end
        if onChange then onChange(box.Text) end
    end)
    return box
end

local function sectionHeader(parent, text)
    local h = Instance.new("TextLabel", parent)
    h.Size = UDim2.new(1, 0, 0, 22); h.BackgroundTransparency = 1
    h.Font = Enum.Font.GothamBold; h.TextSize = 13
    h.TextColor3 = THEME.accent
    h.TextXAlignment = Enum.TextXAlignment.Left
    h.Text = text:upper()
    return h
end

-- --------------- Build ---------------
function UI:Build(Ctx, cfg)
    if CoreGui:FindFirstChild("NXS_SAE") then CoreGui.NXS_SAE:Destroy() end
    local gui = Instance.new("ScreenGui")
    gui.Name = "NXS_SAE"
    gui.ResetOnSpawn = false
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    gui.Parent = CoreGui

    local main = Instance.new("Frame", gui)
    main.Size = UDim2.new(0, 640, 0, 420)
    main.Position = UDim2.new(0.5, -320, 0.5, -210)
    main.BackgroundColor3 = THEME.bg
    main.BorderSizePixel = 0
    main.Active = true
    main.Draggable = true
    corner(main, 8)
    stroke(main, THEME.border, 1)

    -- Title bar
    local title = Instance.new("Frame", main)
    title.Size = UDim2.new(1, 0, 0, 32); title.BackgroundColor3 = THEME.panel
    title.BorderSizePixel = 0
    corner(title, 8)
    local titleFix = Instance.new("Frame", title)
    titleFix.Size = UDim2.new(1, 0, 0.5, 0); titleFix.Position = UDim2.new(0, 0, 0.5, 0)
    titleFix.BackgroundColor3 = THEME.panel; titleFix.BorderSizePixel = 0

    local titleTxt = Instance.new("TextLabel", title)
    titleTxt.Size = UDim2.new(1, -70, 1, 0); titleTxt.Position = UDim2.new(0, 12, 0, 0)
    titleTxt.BackgroundTransparency = 1
    titleTxt.Font = Enum.Font.GothamBold; titleTxt.TextSize = 13
    titleTxt.TextColor3 = THEME.text
    titleTxt.TextXAlignment = Enum.TextXAlignment.Left
    titleTxt.Text = "NXS Scripts  ::  Steal An Egg  "
        .. (Ctx.IsPremium and "[PREMIUM]" or "[FREE]")

    local closeBtn = Instance.new("TextButton", title)
    closeBtn.Size = UDim2.new(0, 28, 0, 24); closeBtn.Position = UDim2.new(1, -34, 0, 4)
    closeBtn.BackgroundTransparency = 1
    closeBtn.Font = Enum.Font.GothamBold; closeBtn.TextSize = 16
    closeBtn.TextColor3 = THEME.danger; closeBtn.Text = "X"
    closeBtn.MouseButton1Click:Connect(function() gui:Destroy() end)

    local minBtn = Instance.new("TextButton", title)
    minBtn.Size = UDim2.new(0, 28, 0, 24); minBtn.Position = UDim2.new(1, -64, 0, 4)
    minBtn.BackgroundTransparency = 1
    minBtn.Font = Enum.Font.GothamBold; minBtn.TextSize = 16
    minBtn.TextColor3 = THEME.text; minBtn.Text = "-"
    local minimized = false
    minBtn.MouseButton1Click:Connect(function()
        minimized = not minimized
        main.Size = minimized and UDim2.new(0, 640, 0, 32) or UDim2.new(0, 640, 0, 420)
    end)

    -- Sidebar
    local side = Instance.new("Frame", main)
    side.Size = UDim2.new(0, 130, 1, -40); side.Position = UDim2.new(0, 6, 0, 36)
    side.BackgroundColor3 = THEME.panel; side.BorderSizePixel = 0
    corner(side, 6)

    local sideLayout = Instance.new("UIListLayout", side)
    sideLayout.Padding = UDim.new(0, 4); sideLayout.SortOrder = Enum.SortOrder.LayoutOrder
    padding(side, 6)

    -- Content area
    local content = Instance.new("Frame", main)
    content.Size = UDim2.new(1, -150, 1, -40); content.Position = UDim2.new(0, 142, 0, 36)
    content.BackgroundColor3 = THEME.panel; content.BorderSizePixel = 0
    corner(content, 6)

    local tabs = {}
    local activeTab = nil

    local function makeTabPanel()
        local p = Instance.new("ScrollingFrame", content)
        p.Size = UDim2.new(1, 0, 1, 0); p.BackgroundTransparency = 1
        p.BorderSizePixel = 0; p.ScrollBarThickness = 4
        p.CanvasSize = UDim2.new(0, 0, 0, 0); p.Visible = false
        local lay = Instance.new("UIListLayout", p)
        lay.Padding = UDim.new(0, 6); lay.SortOrder = Enum.SortOrder.LayoutOrder
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
        b.BackgroundColor3 = THEME.panel2
        b.BorderSizePixel = 0
        b.Font = Enum.Font.GothamSemibold; b.TextSize = 12
        b.TextColor3 = THEME.text
        b.TextXAlignment = Enum.TextXAlignment.Left
        b.Text = "  " .. name
        corner(b, 4)
        return b
    end

    local function selectTab(name)
        for n, t in pairs(tabs) do
            t.panel.Visible = (n == name)
            t.button.BackgroundColor3 = (n == name) and THEME.accentD or THEME.panel2
        end
        activeTab = name
    end

    -- ---- Tab: Home ----
    do
        local p = makeTabPanel()
        local b = makeTabBtn("Home", 1)
        b.MouseButton1Click:Connect(function() selectTab("Home") end)
        tabs.Home = { panel = p, button = b }

        sectionHeader(p, "NXS Steal An Egg")
        local info = Instance.new("TextLabel", p)
        info.Size = UDim2.new(1, 0, 0, 90); info.BackgroundTransparency = 1
        info.Font = Enum.Font.Gotham; info.TextSize = 12
        info.TextColor3 = THEME.textDim
        info.TextXAlignment = Enum.TextXAlignment.Left
        info.TextYAlignment = Enum.TextYAlignment.Top
        info.TextWrapped = true
        info.Text = string.format(
            "Status: %s\nAccount: %s\nExpiry: %s\n\n%s",
            Ctx.IsPremium and "PREMIUM ACTIVE" or "FREE VERSION",
            LP.Name,
            Ctx.Expiry > 0 and os.date("%Y-%m-%d %H:%M", Ctx.Expiry) or "N/A",
            Ctx.IsPremium
                and "Todas as features liberadas. Config auto-salva."
                or "Features Premium bloqueadas. Vai na aba Premium pra ativar."
        )

        sectionHeader(p, "Quick Actions")
        createButton(p, "Recarregar Script", false, function()
            gui:Destroy()
            loadstring(game:HttpGet(getgenv().NXS_BASE .. "/loader.lua"))()
        end)
        createButton(p, "Fechar Menu (" .. cfg.menu_hotkey .. ")", false, function()
            main.Visible = false
            UIS.InputBegan:Connect(function(i, gp)
                if gp then return end
                if i.KeyCode == Enum.KeyCode[cfg.menu_hotkey] then
                    main.Visible = not main.Visible
                end
            end)
        end)
    end

    -- ---- Tab: Farm ----
    do
        local p = makeTabPanel()
        local b = makeTabBtn("Farm", 2)
        b.MouseButton1Click:Connect(function() selectTab("Farm") end)
        tabs.Farm = { panel = p, button = b }

        sectionHeader(p, "Free Features")
        createToggle(p, "Auto Collect Eggs", false, cfg.auto_collect, function(v)
            cfg.auto_collect = v; Ctx.Eggs:SetAutoCollect(v)
            if Ctx.IsPremium then Ctx.Config:Save(cfg) end
        end)
        createToggle(p, "Auto Pickup Nearby", false, cfg.auto_pickup, function(v)
            cfg.auto_pickup = v; Ctx.Eggs:SetAutoPickup(v)
            if Ctx.IsPremium then Ctx.Config:Save(cfg) end
        end)
        createSlider(p, "Collect Radius", false, 5, 50, cfg.collect_radius, function(v)
            cfg.collect_radius = v; Ctx.Eggs:SetRadius(v)
            if Ctx.IsPremium then Ctx.Config:Save(cfg) end
        end)

        sectionHeader(p, "Premium Features")
        local locked = not Ctx.IsPremium
        createToggle(p, "Auto Hatch Pets", locked, cfg.auto_hatch, function(v)
            cfg.auto_hatch = v; Ctx.AutoHatch:SetEnabled(v)
            Ctx.Config:Save(cfg)
        end)
        createToggle(p, "Auto Fuse Pets", locked, cfg.auto_fuse, function(v)
            cfg.auto_fuse = v; Ctx.AutoFuse:SetEnabled(v)
            Ctx.Config:Save(cfg)
        end)
        createToggle(p, "Auto Sell Common Pets", locked, cfg.auto_sell, function(v)
            cfg.auto_sell = v
            Ctx.Config:Save(cfg)
        end)
        createToggle(p, "ESP Ovos Raros", locked, cfg.esp_rare_eggs, function(v)
            cfg.esp_rare_eggs = v; Ctx.Eggs:SetESP(v)
            Ctx.Config:Save(cfg)
        end)
    end

    -- ---- Tab: Player ----
    do
        local p = makeTabPanel()
        local b = makeTabBtn("Player", 3)
        b.MouseButton1Click:Connect(function() selectTab("Player") end)
        tabs.Player = { panel = p, button = b }

        sectionHeader(p, "Movement")
        createToggle(p, "Flight (W/A/S/D + Space/Ctrl)", false, cfg.flight, function(v)
            cfg.flight = v; Ctx.Player:SetFlight(v)
            if Ctx.IsPremium then Ctx.Config:Save(cfg) end
        end)
        createSlider(p, "Flight Speed", false, 10, 200, cfg.flight_speed, function(v)
            cfg.flight_speed = v; Ctx.Player:SetFlightSpeed(v)
            if Ctx.IsPremium then Ctx.Config:Save(cfg) end
        end)
        createSlider(p, "Walk Speed", false, 8, 100, cfg.walkspeed, function(v)
            cfg.walkspeed = v; Ctx.Player:SetWalkSpeed(v)
            if Ctx.IsPremium then Ctx.Config:Save(cfg) end
        end)
        createSlider(p, "Jump Power", false, 20, 200, cfg.jumppower, function(v)
            cfg.jumppower = v; Ctx.Player:SetJumpPower(v)
            if Ctx.IsPremium then Ctx.Config:Save(cfg) end
        end)

        sectionHeader(p, "Anti-AFK")
        createToggle(p, "Anti-AFK (never kick)", false, true, function(v)
            Ctx.Player:SetAntiAFK(v)
        end)
    end

    -- ---- Tab: Teleport ----
    do
        local p = makeTabPanel()
        local b = makeTabBtn("Teleport", 4)
        b.MouseButton1Click:Connect(function() selectTab("Teleport") end)
        tabs.Teleport = { panel = p, button = b }

        sectionHeader(p, "Egg Teleports")
        local info = Instance.new("TextLabel", p)
        info.Size = UDim2.new(1, 0, 0, 36); info.BackgroundTransparency = 1
        info.Font = Enum.Font.Gotham; info.TextSize = 11
        info.TextColor3 = THEME.textDim; info.TextWrapped = true
        info.TextXAlignment = Enum.TextXAlignment.Left
        info.Text = "Clica em refresh pra listar ovos no mapa, depois clica no botão do ovo pra teleportar."

        createButton(p, "Refresh Egg List", false, function()
            Ctx.Teleport:Refresh()
        end)

        local list = Instance.new("Frame", p)
        list.Size = UDim2.new(1, 0, 0, 200); list.BackgroundColor3 = THEME.panel2
        list.BorderSizePixel = 0
        corner(list, 4)

        Ctx.Teleport:SetListFrame(list, THEME)
    end

    -- ---- Tab: Premium ----
    do
        local p = makeTabPanel()
        local b = makeTabBtn("Premium", 5)
        b.MouseButton1Click:Connect(function() selectTab("Premium") end)
        tabs.Premium = { panel = p, button = b }

        sectionHeader(p, "Status")
        local status = Instance.new("TextLabel", p)
        status.Size = UDim2.new(1, 0, 0, 48); status.BackgroundTransparency = 1
        status.Font = Enum.Font.GothamBold; status.TextSize = 14
        status.TextColor3 = Ctx.IsPremium and THEME.accent or THEME.danger
        status.TextXAlignment = Enum.TextXAlignment.Left
        status.TextWrapped = true
        status.Text = Ctx.IsPremium
            and ("ATIVO ate " .. os.date("%d/%m/%Y %H:%M", Ctx.Expiry))
            or "INATIVO — cole sua key abaixo"

        if not Ctx.IsPremium then
            sectionHeader(p, "Ativar Premium")
            local keyBox = createInput(p, "COLE SUA KEY AQUI", "", false, nil)
            local resultLbl = Instance.new("TextLabel", p)
            resultLbl.Size = UDim2.new(1, 0, 0, 20); resultLbl.BackgroundTransparency = 1
            resultLbl.Font = Enum.Font.Gotham; resultLbl.TextSize = 11
            resultLbl.TextColor3 = THEME.textDim; resultLbl.Text = ""
            resultLbl.TextXAlignment = Enum.TextXAlignment.Left

            createButton(p, "ATIVAR PREMIUM", false, function()
                local key = keyBox.Text:gsub("%s+", "")
                if #key < 8 then resultLbl.Text = "Key muito curta"; resultLbl.TextColor3 = THEME.danger; return end
                resultLbl.Text = "Validando..."; resultLbl.TextColor3 = THEME.textDim
                task.spawn(function()
                    local ok, info = Ctx.KeyAuth:Validate(key)
                    if ok then
                        Ctx.KeyAuth:SaveCache(key, info.expires_at)
                        resultLbl.Text = "SUCESSO! Expira: " .. os.date("%d/%m/%Y", info.expires_at)
                        resultLbl.TextColor3 = THEME.accent
                        task.wait(1.5)
                        gui:Destroy()
                        loadstring(game:HttpGet(getgenv().NXS_BASE .. "/loader.lua"))()
                    else
                        resultLbl.Text = "ERRO: " .. tostring(info)
                        resultLbl.TextColor3 = THEME.danger
                    end
                end)
            end)
        else
            createButton(p, "Desativar Premium (reset local)", false, function()
                Ctx.KeyAuth:ClearCache()
                gui:Destroy()
                loadstring(game:HttpGet(getgenv().NXS_BASE .. "/loader.lua"))()
            end)
        end

        sectionHeader(p, "Features Premium")
        local features = {
            "Auto Hatch — chocar ovos automaticamente",
            "Auto Fuse — fundir pets pra raridade maior",
            "Auto Sell — vender pets comuns automaticamente",
            "ESP Ovos Raros — highlight visual em ovos valiosos",
            "Webhook Discord — notifica drops raros",
            "Config save/load — settings persistem entre sessions",
            "Multi-instance support — rodar em várias contas",
        }
        for _, f in ipairs(features) do
            local l = Instance.new("TextLabel", p)
            l.Size = UDim2.new(1, 0, 0, 18); l.BackgroundTransparency = 1
            l.Font = Enum.Font.Gotham; l.TextSize = 12
            l.TextColor3 = THEME.textDim
            l.TextXAlignment = Enum.TextXAlignment.Left
            l.Text = (Ctx.IsPremium and "✓ " or "○ ") .. f
        end
    end

    -- ---- Tab: Settings ----
    do
        local p = makeTabPanel()
        local b = makeTabBtn("Settings", 6)
        b.MouseButton1Click:Connect(function() selectTab("Settings") end)
        tabs.Settings = { panel = p, button = b }

        sectionHeader(p, "Webhook Discord (Premium)")
        local wb = createInput(p, "https://discord.com/api/webhooks/...",
                               cfg.webhook_url, not Ctx.IsPremium, function(v)
            cfg.webhook_url = v
            Ctx.Webhook:SetUrl(v)
            if Ctx.IsPremium then Ctx.Config:Save(cfg) end
        end)
        createToggle(p, "Notificar ovos raros", not Ctx.IsPremium, cfg.webhook_notify_rare, function(v)
            cfg.webhook_notify_rare = v
            if Ctx.IsPremium then Ctx.Config:Save(cfg) end
        end)
        createButton(p, "Testar Webhook", not Ctx.IsPremium, function()
            Ctx.Webhook:Test()
        end)

        sectionHeader(p, "Interface")
        local info = Instance.new("TextLabel", p)
        info.Size = UDim2.new(1, 0, 0, 32); info.BackgroundTransparency = 1
        info.Font = Enum.Font.Gotham; info.TextSize = 11
        info.TextColor3 = THEME.textDim
        info.Text = "Hotkey menu: " .. cfg.menu_hotkey .. "   |   Drag na barra do título pra mover"
        info.TextXAlignment = Enum.TextXAlignment.Left
    end

    selectTab("Home")

    -- Global menu toggle hotkey
    UIS.InputBegan:Connect(function(i, gp)
        if gp then return end
        if i.KeyCode == Enum.KeyCode[cfg.menu_hotkey] then
            main.Visible = not main.Visible
        end
    end)

    return gui
end

return UI
