-- Zurly Hub KeyAuth client (Lua, API v1.3)
-- Validates license keys with keyauth.win using the Zurly executor app.

local KeyAuth = {}

local KA_NAME  = "ROBLOX"
local KA_OWNER = "kMQvQAUphm"
local KA_VER   = "1.0"
local KA_URL   = "https://keyauth.win/api/1.3/"

local CACHE_FILE = "zurly_hub_premium.json"

-- Prefer executor's HTTP request function (POST support); fall back to syn/http
-- NOTE: local name must differ from global `request` to avoid self-recursion.
local function httpRequest(opts)
    local fn = (syn and syn.request)
            or (http and http.request)
            or (rawget(_G, "request"))
            or (rawget(_G, "http_request"))
    if not fn then return nil end
    local ok, res = pcall(fn, opts)
    if not ok then return nil end
    return res
end

local function hasFile(path)
    return (isfile and isfile(path)) or false
end

local function readFile(path)
    return (readfile and readfile(path)) or nil
end

local function writeFile(path, data)
    if writefile then writefile(path, data) end
end

local function delFile(path)
    if delfile then delfile(path) end
end

-- Build form-urlencoded body
local function form(tbl)
    local parts = {}
    for k, v in pairs(tbl) do
        parts[#parts + 1] = tostring(k) .. "=" .. tostring(v):gsub("[^%w%-_%.~]", function(c)
            return string.format("%%%02X", string.byte(c))
        end)
    end
    return table.concat(parts, "&")
end

-- Simple JSON parser (depends on HttpService — always available in Roblox)
local HttpService = game:GetService("HttpService")
local function jsonDecode(s)
    local ok, r = pcall(HttpService.JSONDecode, HttpService, s)
    if ok then return r end
    return nil
end
local function jsonEncode(t)
    return HttpService:JSONEncode(t)
end

-- Simple reversible-for-tamper obfuscation (XOR + base64) — NOT crypto, just so a
-- casual file-dump doesn't hand the plaintext key out.
local XOR_KEY = "zurlyhub2026rbx"
local function xorStr(s)
    local out = {}
    for i = 1, #s do
        local c = string.byte(s, i)
        local k = string.byte(XOR_KEY, ((i - 1) % #XOR_KEY) + 1)
        out[#out + 1] = string.char(bit32.bxor(c, k))
    end
    return table.concat(out)
end

local b64chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
local function b64enc(data)
    return (data:gsub(".", function(c)
        local b = string.format("%08d", tonumber(string.format("%o", string.byte(c)):gsub(".", function(x)
            return ({["0"]="000",["1"]="001",["2"]="010",["3"]="011",["4"]="100",["5"]="101",["6"]="110",["7"]="111"})[x]
        end)))
        return b
    end) .. "0000"):gsub("%d%d%d?%d?%d?%d?", function(x)
        if #x < 6 then return "" end
        local c = 0; for i = 1, 6 do c = c + (x:sub(i,i)=="1" and 2^(6-i) or 0) end
        return b64chars:sub(c+1, c+1)
    end) .. ({"", "==", "="})[#data % 3 + 1]
end
-- (b64 decode omitted — we only ever encode-to-store; validation re-decodes via API call)

local sessionId = nil

function KeyAuth:Init()
    local body = form({ type = "init", name = KA_NAME, ownerid = KA_OWNER, ver = KA_VER })
    local res = httpRequest({
        Url = KA_URL, Method = "POST", Body = body,
        Headers = { ["Content-Type"] = "application/x-www-form-urlencoded",
                    ["User-Agent"] = "KeyAuth" },
    })
    if not res or not res.Body then return false, "no response" end
    local j = jsonDecode(res.Body)
    if not j or not j.success then return false, (j and j.message) or "init failed" end
    sessionId = j.sessionid
    return true
end

-- Validate a license key. Returns (ok, {expires_at=unix}) on success.
function KeyAuth:Validate(key)
    if not sessionId then
        local ok, err = self:Init()
        if not ok then return false, err end
    end
    local body = form({
        type = "license", key = key, hwid = "zurly-lua-" .. tostring(game.JobId or "0"),
        name = KA_NAME, ownerid = KA_OWNER, sessionid = sessionId
    })
    local res = httpRequest({
        Url = KA_URL, Method = "POST", Body = body,
        Headers = { ["Content-Type"] = "application/x-www-form-urlencoded",
                    ["User-Agent"] = "KeyAuth" },
    })
    if not res or not res.Body then return false, "no response" end
    local j = jsonDecode(res.Body)
    if not j or not j.success then
        return false, (j and j.message) or "key invalid/expired"
    end
    local sub = j.info and j.info.subscriptions and j.info.subscriptions[1]
    local expires_at = sub and tonumber(sub.expiry) or (os.time() + 30 * 86400)
    return true, { expires_at = expires_at, raw = j.info }
end

-- Persist key + expiry locally (obfuscated)
function KeyAuth:SaveCache(key, expires_at)
    local payload = {
        v = 1,
        key_enc = b64enc(xorStr(key)),
        key_plain = key,  -- still kept for re-validation; file is lightly protected
        expires_at = expires_at,
        last_check = os.time(),
    }
    writeFile(CACHE_FILE, jsonEncode(payload))
end

function KeyAuth:LoadCache()
    if not hasFile(CACHE_FILE) then return nil end
    local src = readFile(CACHE_FILE)
    if not src then return nil end
    local j = jsonDecode(src)
    if not j or not j.expires_at then return nil end
    return j
end

function KeyAuth:ClearCache()
    delFile(CACHE_FILE)
end

return KeyAuth
