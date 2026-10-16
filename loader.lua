-- Zurly Hub — Universal Loader
-- Single-line executor usage:
--   loadstring(game:HttpGet("https://raw.githubusercontent.com/srmatheus/robloxscripts/main/loader.lua"))()

local BASE = "https://raw.githubusercontent.com/srmatheus/robloxscripts/main"

-- Cache-buster: unique query string per session kills Volt's HttpGet cache
local CBUST = "?v=" .. tostring(os.time()) .. "_" .. tostring(math.random(1, 999999))

local function fetch(path)
    local url = BASE .. "/" .. path .. CBUST
    -- Prefer executor's request() — supports headers (no-cache)
    local reqfn = (syn and syn.request) or (http and http.request) or request or http_request
    if reqfn then
        for i = 1, 3 do
            local ok, res = pcall(reqfn, {
                Url = url, Method = "GET",
                Headers = {
                    ["Cache-Control"] = "no-cache, no-store, must-revalidate",
                    ["Pragma"] = "no-cache",
                },
            })
            if ok and res and res.Body and #res.Body > 0 then return res.Body end
            task.wait(0.3)
        end
    end
    -- Fallback: HttpGet (cached but works)
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
