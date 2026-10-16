-- NXS Scripts — Universal Loader
-- Single-line executor usage:
--   loadstring(game:HttpGet("https://raw.githubusercontent.com/REPLACE_USER/nxs-scripts/main/loader.lua"))()

local BASE = "https://raw.githubusercontent.com/REPLACE_USER/nxs-scripts/main"

local function fetch(path)
    local url = BASE .. "/" .. path
    for i = 1, 3 do
        local ok, body = pcall(game.HttpGet, game, url)
        if ok and type(body) == "string" and #body > 0 then return body end
        task.wait(0.5)
    end
    error("[NXS Loader] Failed to fetch " .. path)
end

-- Route by PlaceId / GameId
local routes = {
    [107778070777162] = "steal-an-egg/main.lua",  -- Steal An Egg / Roube um Ovo
}

local target = routes[game.PlaceId] or routes[game.GameId]
if not target then
    warn("[NXS] Game not supported yet (PlaceId=" .. tostring(game.PlaceId) .. ")")
    return
end

-- Expose shared loader to game modules
getgenv().NXS_BASE = BASE
getgenv().NXS_FETCH = fetch

local source = fetch(target)
local chunk, err = loadstring(source)
if not chunk then error("[NXS Loader] Compile failed: " .. tostring(err)) end
chunk()
