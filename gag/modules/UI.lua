-- Zurly Hub — Grow a Garden UI (Fluent library — modern, polished)
-- Fluent: https://github.com/dawid-scripts/Fluent

local UI = {}

local Players = game:GetService("Players")
local RS      = game:GetService("ReplicatedStorage")
local LP      = Players.LocalPlayer

function UI:Build(Ctx, cfg)
    local T = Ctx.Theme

    -- Load Fluent + addons (cached by executor)
    local Fluent = loadstring(game:HttpGet(
        "https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
    local SaveManager = loadstring(game:HttpGet(
        "https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
    local InterfaceManager = loadstring(game:HttpGet(
        "https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

    local Window = Fluent:CreateWindow({
        Title = "Zurly Hub",
        SubTitle = "Grow a Garden  " .. (Ctx.IsPremium and "/ PREMIUM" or "/ FREE"),
        TabWidth = 160,
        Size = UDim2.fromOffset(560, 420),
        Acrylic = true,
        Theme = "Darker",
        MinimizeKey = Enum.KeyCode.RightShift,
    })

    local Tabs = {
        Home     = Window:AddTab({ Title = "Home",     Icon = "home" }),
        Farm     = Window:AddTab({ Title = "Farm",     Icon = "sprout" }),
        Pets     = Window:AddTab({ Title = "Pets",     Icon = "paw-print" }),
        Shop     = Window:AddTab({ Title = "Shop",     Icon = "store" }),
        Player   = Window:AddTab({ Title = "Player",   Icon = "user" }),
        Teleport = Window:AddTab({ Title = "Teleport", Icon = "map-pin" }),
        Debug    = Window:AddTab({ Title = "Debug",    Icon = "bug" }),
        Premium  = Window:AddTab({ Title = "Premium",  Icon = "crown" }),
        Settings = Window:AddTab({ Title = "Settings", Icon = "settings" }),
    }

    local Options = Fluent.Options
    local locked = not Ctx.IsPremium

    -- ============ HOME ============
    Tabs.Home:AddParagraph({
        Title = "Zurly Hub — Grow a Garden",
        Content = string.format(
            "Status  %s\nPlayer  %s\nExpiry  %s",
            Ctx.IsPremium and "PREMIUM ACTIVE" or "FREE VERSION",
            LP.Name,
            Ctx.Expiry > 0 and os.date("%d/%m/%Y %H:%M", Ctx.Expiry) or "N/A"
        )
    })
    Tabs.Home:AddButton({ Title = "Vender Tudo Agora", Callback = function() Ctx.Shop:SellOnce() end })
    Tabs.Home:AddButton({ Title = "TP Shop",   Callback = function() Ctx.Teleport:ToShop() end })
    Tabs.Home:AddButton({ Title = "TP Garden", Callback = function() Ctx.Teleport:ToGarden() end })
    Tabs.Home:AddButton({ Title = "TP Sell",   Callback = function() Ctx.Teleport:ToSelling() end })

    -- ============ FARM ============
    Tabs.Farm:AddToggle("AutoHarvest", {
        Title = "Auto Harvest",
        Description = "Colhe frutas maduras via ProximityPrompt",
        Default = cfg.auto_harvest or false,
        Callback = function(v) cfg.auto_harvest = v; Ctx.Plants:SetAutoHarvest(v); if Ctx.IsPremium then Ctx.Config:Save(cfg) end end,
    })
    Tabs.Farm:AddToggle("AutoSell", {
        Title = "Auto Sell Inventory",
        Description = "Vende todo seu inventário a cada X segundos",
        Default = cfg.auto_sell or false,
        Callback = function(v) cfg.auto_sell = v; Ctx.Shop:SetAutoSell(v); if Ctx.IsPremium then Ctx.Config:Save(cfg) end end,
    })
    Tabs.Farm:AddToggle("AutoPlant", {
        Title = "Auto Plant",
        Description = "Planta a semente escolhida continuamente",
        Default = cfg.auto_plant or false,
        Callback = function(v) cfg.auto_plant = v; Ctx.Plants:SetAutoPlant(v); if Ctx.IsPremium then Ctx.Config:Save(cfg) end end,
    })
    Tabs.Farm:AddInput("SeedName", {
        Title = "Seed Name",
        Default = cfg.plant_seed or "Carrot",
        Placeholder = "Carrot, Strawberry, Pumpkin...",
        Callback = function(v) cfg.plant_seed = v; Ctx.Plants:SetSeed(v); if Ctx.IsPremium then Ctx.Config:Save(cfg) end end,
    })
    Tabs.Farm:AddSlider("PlantDelay", {
        Title = "Plant Delay (×0.1s)",
        Default = math.floor((cfg.plant_delay or 0.3) * 10), Min = 1, Max = 30, Rounding = 0,
        Callback = function(v) cfg.plant_delay = v / 10; Ctx.Plants:SetDelay(v / 10); if Ctx.IsPremium then Ctx.Config:Save(cfg) end end,
    })
    Tabs.Farm:AddSlider("SellDelay", {
        Title = "Sell Interval (s)",
        Default = cfg.auto_sell_delay or 20, Min = 5, Max = 120, Rounding = 0,
        Callback = function(v) cfg.auto_sell_delay = v; if Ctx.IsPremium then Ctx.Config:Save(cfg) end end,
    })

    -- ============ PETS (Premium) ============
    if locked then
        Tabs.Pets:AddParagraph({ Title = "Premium Only", Content = "Ative Premium pra desbloquear essas features." })
    else
        Tabs.Pets:AddToggle("AutoFuse", {
            Title = "Auto Fuse Pets",
            Default = cfg.auto_fuse or false,
            Callback = function(v) cfg.auto_fuse = v; Ctx.Pets:SetAutoFuse(v); Ctx.Config:Save(cfg) end,
        })
        Tabs.Pets:AddToggle("AutoEquipBest", {
            Title = "Auto Equip Best Pet",
            Default = cfg.auto_equip_best or false,
            Callback = function(v) cfg.auto_equip_best = v; Ctx.Pets:SetAutoEquipBest(v); Ctx.Config:Save(cfg) end,
        })
        Tabs.Pets:AddToggle("ESPRarePets", {
            Title = "ESP Pets com Mutation Rara",
            Description = "Highlight Rainbow / Golden / Rot / Warped",
            Default = cfg.esp_rare_pets or false,
            Callback = function(v) cfg.esp_rare_pets = v; Ctx.Pets:SetESP(v); Ctx.Config:Save(cfg) end,
        })
    end

    -- ============ SHOP (Premium) ============
    if locked then
        Tabs.Shop:AddParagraph({ Title = "Premium Only", Content = "Ative Premium pra desbloquear auto-buy." })
    else
        Tabs.Shop:AddToggle("AutoBuySeeds", {
            Title = "Auto Buy Rare Seeds",
            Description = "Compra Dragon Fruit, Pumpkin, Mushroom, Pepper, Cactus",
            Default = cfg.auto_buy_seeds or false,
            Callback = function(v)
                cfg.auto_buy_seeds = v
                Ctx.Shop:SetBuyList({
                    ["Dragon Fruit"] = true, ["Watermelon"] = true, ["Pumpkin"] = true,
                    ["Mushroom"] = true, ["Pepper"] = true, ["Cactus"] = true,
                })
                Ctx.Shop:SetAutoBuySeeds(v); Ctx.Config:Save(cfg)
            end,
        })
    end

    -- ============ PLAYER ============
    Tabs.Player:AddToggle("Flight", {
        Title = "Flight",
        Description = "WASD + Space (sobe) + Ctrl (desce)",
        Default = cfg.flight or false,
        Callback = function(v) cfg.flight = v; Ctx.Player:SetFlight(v); if Ctx.IsPremium then Ctx.Config:Save(cfg) end end,
    })
    Tabs.Player:AddSlider("FlightSpeed", {
        Title = "Flight Speed",
        Default = cfg.flight_speed or 55, Min = 10, Max = 200, Rounding = 0,
        Callback = function(v) cfg.flight_speed = v; Ctx.Player:SetFlightSpeed(v); if Ctx.IsPremium then Ctx.Config:Save(cfg) end end,
    })
    Tabs.Player:AddSlider("WalkSpeed", {
        Title = "Walk Speed",
        Default = cfg.walkspeed or 16, Min = 8, Max = 100, Rounding = 0,
        Callback = function(v) cfg.walkspeed = v; Ctx.Player:SetWalkSpeed(v); if Ctx.IsPremium then Ctx.Config:Save(cfg) end end,
    })
    Tabs.Player:AddSlider("JumpPower", {
        Title = "Jump Power",
        Default = cfg.jumppower or 50, Min = 20, Max = 200, Rounding = 0,
        Callback = function(v) cfg.jumppower = v; Ctx.Player:SetJumpPower(v); if Ctx.IsPremium then Ctx.Config:Save(cfg) end end,
    })
    Tabs.Player:AddToggle("AntiAFK", {
        Title = "Anti-AFK",
        Description = "Nunca ser kickado por 20min idle",
        Default = true,
        Callback = function(v) Ctx.Player:SetAntiAFK(v) end,
    })

    -- ============ TELEPORT ============
    Tabs.Teleport:AddButton({ Title = "TP para Shop",   Callback = function() Ctx.Teleport:ToShop() end })
    Tabs.Teleport:AddButton({ Title = "TP para Garden", Callback = function() Ctx.Teleport:ToGarden() end })
    Tabs.Teleport:AddButton({ Title = "TP para Sell",   Callback = function() Ctx.Teleport:ToSelling() end })

    -- ============ DEBUG ============
    Tabs.Debug:AddParagraph({ Title = "Remote Discovery", Content = "Scan + filtro pra achar remotes do jogo." })
    local filterVal = ""
    Tabs.Debug:AddInput("DebugFilter", {
        Title = "Filtro", Default = "", Placeholder = "plant, sell, harvest, fuse, buy...",
        Callback = function(v) filterVal = v end,
    })
    local allRemotes = {}
    Tabs.Debug:AddButton({
        Title = "Scan Remotes do Jogo",
        Callback = function()
            allRemotes = {}
            for _, inst in ipairs(RS:GetDescendants()) do
                if inst:IsA("RemoteEvent") or inst:IsA("RemoteFunction") then
                    table.insert(allRemotes, inst)
                end
            end
            table.sort(allRemotes, function(a, b) return a.Name < b.Name end)
            local filter = (filterVal or ""):lower()
            local shown, msg = 0, ""
            for _, r in ipairs(allRemotes) do
                if filter == "" or r:GetFullName():lower():find(filter, 1, true) then
                    shown = shown + 1
                    if shown <= 20 then
                        msg = msg .. "[" .. (r:IsA("RemoteEvent") and "RE" or "RF") .. "] " .. r:GetFullName() .. "\n"
                    end
                end
            end
            Fluent:Notify({
                Title = string.format("Scan: %d remotes (filter: %s)", shown, filter == "" and "none" or filter),
                Content = msg == "" and "nenhum encontrado" or msg,
                Duration = 30,
            })
            print("[Zurly Debug]", shown, "remotes matched filter '" .. filter .. "'")
        end,
    })

    -- ============ PREMIUM ============
    Tabs.Premium:AddParagraph({
        Title = Ctx.IsPremium and "PREMIUM ATIVO" or "SEM PREMIUM",
        Content = Ctx.IsPremium
            and ("Expira em " .. os.date("%d/%m/%Y %H:%M", Ctx.Expiry))
            or "Cole sua key abaixo pra ativar.",
    })

    if not Ctx.IsPremium then
        local pendingKey = ""
        Tabs.Premium:AddInput("KeyBox", {
            Title = "License Key",
            Default = "", Placeholder = "COLE SUA KEY AQUI",
            Callback = function(v) pendingKey = v end,
        })
        Tabs.Premium:AddButton({
            Title = "ATIVAR PREMIUM",
            Callback = function()
                local key = (pendingKey or ""):gsub("%s+", "")
                if #key < 8 then
                    Fluent:Notify({ Title = "Erro", Content = "Key muito curta", Duration = 4 })
                    return
                end
                Fluent:Notify({ Title = "Validando...", Content = "Aguarde", Duration = 2 })
                task.spawn(function()
                    local ok, info = Ctx.KeyAuth:Validate(key)
                    if ok then
                        Ctx.KeyAuth:SaveCache(key, info.expires_at)
                        Fluent:Notify({
                            Title = "SUCESSO",
                            Content = "Expira " .. os.date("%d/%m/%Y", info.expires_at) .. ". Recarregando...",
                            Duration = 3,
                        })
                        task.wait(2)
                        Window:Destroy()
                        loadstring(game:HttpGet((getgenv().ZURLY_BASE or getgenv().NXS_BASE) .. "/loader.lua"))()
                    else
                        Fluent:Notify({ Title = "ERRO", Content = tostring(info), Duration = 6 })
                    end
                end)
            end,
        })
    else
        Tabs.Premium:AddButton({
            Title = "Desativar Premium (reset local)",
            Callback = function()
                Ctx.KeyAuth:ClearCache()
                Window:Destroy()
                loadstring(game:HttpGet((getgenv().ZURLY_BASE or getgenv().NXS_BASE) .. "/loader.lua"))()
            end,
        })
    end

    -- ============ SETTINGS ============
    Tabs.Settings:AddInput("WebhookUrl", {
        Title = "Webhook Discord URL",
        Default = cfg.webhook_url or "", Placeholder = "https://discord.com/api/webhooks/...",
        Callback = function(v) cfg.webhook_url = v; Ctx.Webhook:SetUrl(v); if Ctx.IsPremium then Ctx.Config:Save(cfg) end end,
    })
    Tabs.Settings:AddButton({
        Title = "Testar Webhook",
        Callback = function() Ctx.Webhook:Test() end,
    })

    InterfaceManager:SetLibrary(Fluent)
    InterfaceManager:SetFolder("ZurlyHub")
    InterfaceManager:BuildInterfaceSection(Tabs.Settings)

    Window:SelectTab(1)

    Fluent:Notify({
        Title = "Zurly Hub",
        Content = "Carregado — Grow a Garden " .. (Ctx.IsPremium and "PREMIUM" or "FREE"),
        Duration = 4,
    })

    Ctx.Webhook:SetUrl(cfg.webhook_url or "")
    return Window
end

return UI
