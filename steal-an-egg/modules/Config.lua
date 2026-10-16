-- NXS Config — JSON persistence for user settings (Premium feature)

local Config = {}
local HttpService = game:GetService("HttpService")

local FILE = "nxs_sae_config.json"

local defaults = {
    -- Farm
    auto_collect = false,
    auto_pickup  = false,
    collect_radius = 10,
    -- Combat/Player
    flight = false,
    flight_speed = 55,
    walkspeed = 16,
    jumppower = 50,
    -- Premium
    auto_hatch = false,
    auto_fuse = false,
    fuse_min_rarity = "Rare",
    auto_sell = false,
    sell_below = "Common",
    esp_rare_eggs = false,
    webhook_url = "",
    webhook_notify_rare = true,
    -- Appearance
    menu_hotkey = "RightShift",
    show_menu = true,
}

function Config:Defaults()
    local copy = {}
    for k, v in pairs(defaults) do copy[k] = v end
    return copy
end

function Config:Load()
    if not isfile or not isfile(FILE) then
        return self:Defaults()
    end
    local raw = readfile(FILE)
    local ok, j = pcall(HttpService.JSONDecode, HttpService, raw)
    if not ok or type(j) ~= "table" then return self:Defaults() end
    -- Merge with defaults (handles added keys over time)
    local merged = self:Defaults()
    for k, v in pairs(j) do merged[k] = v end
    return merged
end

function Config:Save(tbl)
    if not writefile then return false end
    local ok, encoded = pcall(HttpService.JSONEncode, HttpService, tbl)
    if not ok then return false end
    writefile(FILE, encoded)
    return true
end

return Config
