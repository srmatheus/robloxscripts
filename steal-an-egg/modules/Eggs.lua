-- NXS Eggs — auto-collect, auto-pickup, ESP for Steal An Egg
-- No metamethod hooks; pure RemoteEvent fires + CollectionService queries.

local Eggs = {}

local Players = game:GetService("Players")
local RS      = game:GetService("ReplicatedStorage")
local CS      = game:GetService("CollectionService")
local Workspace = workspace

local LP = Players.LocalPlayer

local state = {
    auto_collect = false,
    auto_pickup  = false,
    radius       = 10,
    esp          = false,
}

local function getRemotes()
    local folder = RS:FindFirstChild("EggRemotes") or RS:FindFirstChild("Remotes")
    if not folder then return nil end
    return {
        StealEgg = folder:FindFirstChild("StealEgg"),
        DropEgg  = folder:FindFirstChild("DropEgg"),
    }
end

local function listEggs()
    local out = {}
    for _, e in ipairs(CS:GetTagged("StealableEgg")) do
        if e:IsDescendantOf(Workspace) then out[#out + 1] = e end
    end
    if #out == 0 then
        -- Fallback: scan workspace for Models tagged as eggs by common naming
        for _, m in ipairs(Workspace:GetDescendants()) do
            if m:IsA("Model") and (m.Name:lower():find("egg") or m:FindFirstChild("EggStatus")) then
                out[#out + 1] = m
            end
        end
    end
    return out
end

local function root()
    local c = LP.Character
    return c and c:FindFirstChild("HumanoidRootPart")
end

function Eggs:SetRadius(r)      state.radius = r end
function Eggs:IsAutoCollect()   return state.auto_collect end
function Eggs:IsAutoPickup()    return state.auto_pickup end

function Eggs:Refresh()
    local l = listEggs()
    print("[NXS Eggs] Found:", #l)
    return l
end

function Eggs:SetAutoCollect(enabled)
    state.auto_collect = enabled
    if not enabled then return end
    task.spawn(function()
        while state.auto_collect do
            local r = root()
            local rem = getRemotes()
            if r and rem and rem.StealEgg then
                for _, egg in ipairs(listEggs()) do
                    if not state.auto_collect then break end
                    local part = egg.PrimaryPart or egg:FindFirstChildWhichIsA("BasePart")
                    if part then
                        local d = (r.Position - part.Position).Magnitude
                        if d <= state.radius and not egg:GetAttribute("Carrier") then
                            pcall(function() rem.StealEgg:FireServer(egg) end)
                            task.wait(0.25)
                        end
                    end
                end
            end
            task.wait(0.6)
        end
    end)
end

function Eggs:SetAutoPickup(enabled)
    state.auto_pickup = enabled
end

-- ESP: Highlight rare/legendary eggs with a glow
local HIGHLIGHT_TAG = "NXS_EggESP"
local function clearESP()
    for _, h in ipairs(Workspace:GetDescendants()) do
        if h:IsA("Highlight") and h.Name == HIGHLIGHT_TAG then h:Destroy() end
    end
end

function Eggs:SetESP(enabled)
    state.esp = enabled
    if not enabled then clearESP(); return end
    task.spawn(function()
        while state.esp do
            local seen = {}
            for _, egg in ipairs(listEggs()) do
                local rarity = egg:GetAttribute("Rarity") or egg:GetAttribute("Tier") or ""
                local isRare = (type(rarity) == "string"
                                and (rarity:lower():find("rare")
                                  or rarity:lower():find("legend")
                                  or rarity:lower():find("myth")
                                  or rarity:lower():find("secret")))
                if isRare then
                    seen[egg] = true
                    if not egg:FindFirstChild(HIGHLIGHT_TAG) then
                        local h = Instance.new("Highlight", egg)
                        h.Name = HIGHLIGHT_TAG
                        h.FillColor = Color3.fromRGB(0, 255, 100)
                        h.OutlineColor = Color3.fromRGB(255, 255, 255)
                        h.FillTransparency = 0.5
                    end
                end
            end
            -- Cleanup stale highlights
            for _, egg in ipairs(CS:GetTagged("StealableEgg")) do
                if not seen[egg] then
                    local h = egg:FindFirstChild(HIGHLIGHT_TAG)
                    if h then h:Destroy() end
                end
            end
            task.wait(2)
        end
    end)
end

return Eggs
