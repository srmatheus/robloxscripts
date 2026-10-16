-- NXS Webhook (Premium) — sends Discord notifications

local Webhook = {}

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local LP = Players.LocalPlayer

local url = ""

local function request(opts)
    local fn = (syn and syn.request) or (http and http.request) or request or http_request
    if fn then return fn(opts) end
    return nil
end

function Webhook:SetUrl(u) url = u or "" end

function Webhook:Send(title, desc, color)
    if url == "" then return false, "no url" end
    local body = HttpService:JSONEncode({
        username = "NXS Steal An Egg",
        embeds = {{
            title = title or "NXS Notification",
            description = desc or "",
            color = color or 65280,  -- NXS green
            footer = { text = "Player: " .. LP.Name .. "  |  Game: " .. tostring(game.PlaceId) },
            timestamp = DateTime.now():ToIsoDate(),
        }},
    })
    return request({
        Url = url, Method = "POST", Body = body,
        Headers = { ["Content-Type"] = "application/json" },
    })
end

function Webhook:Test()
    local ok = self:Send("TEST", "Webhook configurado com sucesso. [" .. os.date("%H:%M:%S") .. "]")
    print("[NXS Webhook] Test sent:", tostring(ok))
end

-- Hook: notify when rare pet obtained (polled)
function Webhook:StartRareWatcher(cfg)
    task.spawn(function()
        local seen = {}
        while true do
            if cfg.webhook_notify_rare and url ~= "" then
                local inv = LP:FindFirstChild("PlayerGui")
                            and LP.PlayerGui:FindFirstChild("Inventory", true)
                if inv then
                    for _, item in ipairs(inv:GetDescendants()) do
                        local rarity = item:GetAttribute("Rarity")
                        if rarity and type(rarity) == "string"
                           and (rarity:lower():find("legend") or rarity:lower():find("myth")
                                or rarity:lower():find("secret"))
                           and not seen[item] then
                            seen[item] = true
                            self:Send("Pet Raro!", "Nome: " .. item.Name .. "  |  Rarity: " .. rarity)
                        end
                    end
                end
            end
            task.wait(10)
        end
    end)
end

return Webhook
