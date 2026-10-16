-- NXS Steal An Egg — bootstrap
-- Loads all modules, initializes KeyAuth, starts UI.

local BASE = getgenv().NXS_BASE or "https://raw.githubusercontent.com/srmatheus/robloxscripts/main"
local FETCH = getgenv().NXS_FETCH or function(p)
    return game:HttpGet(BASE .. "/" .. p)
end

local function requireRemote(path)
    local src = FETCH("steal-an-egg/modules/" .. path)
    local chunk, err = loadstring(src)
    if not chunk then error("compile " .. path .. ": " .. tostring(err)) end
    return chunk()
end

-- Prevent double-load
if getgenv().NXS_SAE_LOADED then
    getgenv().NXS_SAE_LOADED:Destroy()
end

local KeyAuth = requireRemote("KeyAuth.lua")
local Config  = requireRemote("Config.lua")
local UI      = requireRemote("UI.lua")
local Eggs    = requireRemote("Eggs.lua")
local Player  = requireRemote("Player.lua")
local Teleport= requireRemote("Teleport.lua")
local AutoHatch = requireRemote("AutoHatch.lua")
local AutoFuse  = requireRemote("AutoFuse.lua")
local Webhook   = requireRemote("Webhook.lua")

-- Build shared context
local Ctx = {
    KeyAuth = KeyAuth,
    Config  = Config,
    Eggs    = Eggs,
    Player  = Player,
    Teleport= Teleport,
    AutoHatch = AutoHatch,
    AutoFuse  = AutoFuse,
    Webhook   = Webhook,
    IsPremium = false,
    Expiry = 0,
}

-- Auto-reactivate premium from local cache (zero prompt on repeat injections)
local cached = KeyAuth:LoadCache()
if cached and cached.expires_at and cached.expires_at > os.time() then
    Ctx.IsPremium = true
    Ctx.Expiry = cached.expires_at
    -- Re-validate every 24h in background
    task.spawn(function()
        if cached.last_check and (os.time() - cached.last_check) > 86400 then
            local ok, info = KeyAuth:Validate(cached.key_plain)
            if ok then
                KeyAuth:SaveCache(cached.key_plain, info.expires_at)
            else
                KeyAuth:ClearCache()
                Ctx.IsPremium = false
            end
        end
    end)
end

-- Load user config (settings persist across sessions)
local userCfg = Config:Load()

-- Build and show UI
local gui = UI:Build(Ctx, userCfg)
getgenv().NXS_SAE_LOADED = gui

warn(string.format("[NXS] Steal An Egg v1.0 loaded — Premium: %s", tostring(Ctx.IsPremium)))
