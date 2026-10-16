-- Zurly Hub — Grow a Garden: Teleport (shop, selling, garden)

local Teleport = {}

local Players = game:GetService("Players")
local Workspace = workspace
local LP = Players.LocalPlayer

local function root()
    local c = LP.Character
    return c and c:FindFirstChild("HumanoidRootPart")
end

local function tpTo(pos, smooth)
    local r = root(); if not r or not pos then return end
    local target = CFrame.new(pos) + Vector3.new(0, 3, 0)
    if not smooth then r.CFrame = target return end
    local start = r.CFrame
    for i = 1, 20 do
        if not r or not r.Parent then return end
        r.CFrame = start:Lerp(target, i / 20)
        task.wait(0.02)
    end
end

local function findObject(names)
    for _, inst in ipairs(Workspace:GetDescendants()) do
        for _, n in ipairs(names) do
            if inst.Name == n and (inst:IsA("BasePart") or inst:IsA("Model")) then
                return inst
            end
        end
    end
end

function Teleport:ToShop()
    local target = findObject({ "SeedShop", "Shop", "SeedStock", "ShopNPC" })
    if target then
        local p = target:IsA("Model") and (target.PrimaryPart or target:FindFirstChildWhichIsA("BasePart"))
                     or target
        if p then tpTo(p.Position, true) end
    end
end

function Teleport:ToSelling()
    local target = findObject({ "SellStand", "SellingNPC", "Selling", "SellArea" })
    if target then
        local p = target:IsA("Model") and (target.PrimaryPart or target:FindFirstChildWhichIsA("BasePart"))
                     or target
        if p then tpTo(p.Position, true) end
    end
end

function Teleport:ToGarden()
    local farms = Workspace:FindFirstChild("Farm") or Workspace:FindFirstChild("Farms")
    if not farms then return end
    for _, plot in ipairs(farms:GetChildren()) do
        local owner = plot:GetAttribute("Owner")
        if owner == LP.Name or owner == LP.UserId then
            local p = plot.PrimaryPart or plot:FindFirstChildWhichIsA("BasePart", true)
            if p then tpTo(p.Position, true); return end
        end
    end
end

function Teleport:ToPos(pos) tpTo(pos, true) end

return Teleport
