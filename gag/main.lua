-- Zurly Hub — Grow a Garden bootstrap

local BASE = getgenv().NXS_BASE or getgenv().ZURLY_BASE
    or "https://raw.githubusercontent.com/srmatheus/robloxscripts/main"
local FETCH = getgenv().NXS_FETCH or getgenv().ZURLY_FETCH or function(p)
    return game:HttpGet(BASE .. "/" .. p)
end

local function requireRemote(path)
    local src = FETCH(path)
    local chunk, err = loadstring(src)
    if not chunk then error("compile " .. path .. ": " .. tostring(err)) end
    return chunk()
end

if getgenv().ZURLY_GG_LOADED then
    pcall(function()
        if getgenv().ZURLY_GG_LOADED.Destroy then getgenv().ZURLY_GG_LOADED:Destroy() end
    end)
end

-- Shared
local Theme     = requireRemote("shared/Theme.lua")
local UIWidgets = requireRemote("shared/UIWidgets.lua")
local KeyAuth   = requireRemote("shared/KeyAuth.lua")
local ConfigLib = requireRemote("shared/Config.lua")
local Webhook   = requireRemote("shared/Webhook.lua")
local Player    = requireRemote("shared/Player.lua")

-- Game-specific
local Plants   = requireRemote("gag/modules/Plants.lua")
local Shop     = requireRemote("gag/modules/Shop.lua")
local Pets     = requireRemote("gag/modules/Pets.lua")
local Teleport = requireRemote("gag/modules/Teleport.lua")

local Config = ConfigLib.New("grow_a_garden", {
    -- Free
    auto_harvest = false,
    auto_sell = false,
    auto_sell_delay = 20,
    auto_plant = false,
    plant_seed = "Carrot",
    plant_delay = 0.3,
    flight = false,
    flight_speed = 55,
    walkspeed = 16,
    jumppower = 50,
    -- Premium
    auto_fuse = false,
    auto_equip_best = false,
    auto_buy_seeds = false,
    buy_list_rare = false,
    esp_rare_pets = false,
    target_mutations = { Rainbow = true, Golden = true, Rot = true, Warped = true },
    webhook_url = "",
    webhook_notify_rare = true,
    -- UI
    menu_hotkey = "RightShift",
})

local Ctx = {
    Theme = Theme, UIWidgets = UIWidgets, KeyAuth = KeyAuth, Config = Config,
    Webhook = Webhook, Player = Player,
    Plants = Plants, Shop = Shop, Pets = Pets, Teleport = Teleport,
    IsPremium = false, Expiry = 0,
}

local cached = KeyAuth:LoadCache()
if cached and cached.expires_at and cached.expires_at > os.time() then
    Ctx.IsPremium = true
    Ctx.Expiry = cached.expires_at
end

local userCfg = Config:Load()

-- Load UI builder for this game
local UI = requireRemote("gag/modules/UI.lua")
local gui = UI:Build(Ctx, userCfg)
getgenv().ZURLY_GG_LOADED = gui

warn(string.format("[Zurly Hub] Grow a Garden v1.0 loaded — Premium: %s", tostring(Ctx.IsPremium)))
