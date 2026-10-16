-- Zurly Hub — per-game JSON config (Premium persistence)
-- Caller supplies the game slug so configs don't collide.

local HttpService = game:GetService("HttpService")

local M = {}

function M.New(gameSlug, defaults)
    local file = "zurly_" .. gameSlug .. "_config.json"
    local obj = {}

    function obj:Defaults()
        local copy = {}
        for k, v in pairs(defaults) do copy[k] = v end
        return copy
    end

    function obj:Load()
        if not isfile or not isfile(file) then return self:Defaults() end
        local raw = readfile(file)
        local ok, j = pcall(HttpService.JSONDecode, HttpService, raw)
        if not ok or type(j) ~= "table" then return self:Defaults() end
        local merged = self:Defaults()
        for k, v in pairs(j) do merged[k] = v end
        return merged
    end

    function obj:Save(tbl)
        if not writefile then return false end
        local ok, enc = pcall(HttpService.JSONEncode, HttpService, tbl)
        if not ok then return false end
        writefile(file, enc)
        return true
    end

    return obj
end

return M
