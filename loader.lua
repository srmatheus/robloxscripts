-- Zurly Hub — Universal Loader
-- Single-line executor usage:
--   loadstring(game:HttpGet("https://raw.githubusercontent.com/srmatheus/robloxscripts/main/loader.lua"))()

local BASE = "https://raw.githubusercontent.com/srmatheus/robloxscripts/main"

local function fetch(path)
    local url = BASE .. "/" .. path
    for i = 1, 3 do
        local ok, body = pcall(game.HttpGet, game, url)
        if ok and type(body) == "string" and #body > 0 then return body end
        task.wait(0.5)
    end
    error("[Zurly Loader] Failed to fetch " .. path)
end

-- Route by PlaceId / GameId
local routes = {
    [107778070777162] = "steal-an-egg/main.lua",   -- Roube um Ovo
    [124977557560410] = "grow-a-garden/main.lua",  -- Grow a Garden (main)
    [126884695634066] = "grow-a-garden/main.lua",  -- Grow a Garden (alt)
    [95206881326333]  = "grow-a-garden/main.lua",  -- Grow a Garden (alt)
}

local target = routes[game.PlaceId] or routes[game.GameId]
if not target then
    warn("[Zurly Hub] Jogo não suportado ainda (PlaceId=" .. tostring(game.PlaceId) .. ")")
    return
end

getgenv().NXS_BASE   = BASE   -- back-compat
getgenv().NXS_FETCH  = fetch
getgenv().ZURLY_BASE = BASE
getgenv().ZURLY_FETCH = fetch

local source = fetch(target)
local chunk, err = loadstring(source)
if not chunk then error("[Zurly Loader] Compile failed: " .. tostring(err)) end
chunk()
