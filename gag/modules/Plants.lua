-- Zurly Hub — Grow a Garden: Plants (auto plant, auto harvest, auto water)
-- Fires GameEvents remotes with discovered naming patterns.

local Plants = {}

local Players = game:GetService("Players")
local RS      = game:GetService("ReplicatedStorage")
local Workspace = workspace
local LP      = Players.LocalPlayer

local state = {
    auto_plant   = false,
    auto_harvest = false,
    auto_water   = false,
    seed_name    = "Carrot",
    plant_delay  = 0.3,
}

local function findRemote(names, folderNames)
    folderNames = folderNames or { "GameEvents", "Remotes", "RemoteEvents", "Events" }
    for _, fn in ipairs(folderNames) do
        local f = RS:FindFirstChild(fn)
        if f then
            for _, nm in ipairs(names) do
                local r = f:FindFirstChild(nm, true)
                if r and (r:IsA("RemoteEvent") or r:IsA("RemoteFunction")) then return r end
            end
        end
    end
    -- Deep fallback
    for _, nm in ipairs(names) do
        local pat = nm:lower()
        for _, inst in ipairs(RS:GetDescendants()) do
            if (inst:IsA("RemoteEvent") or inst:IsA("RemoteFunction"))
               and inst.Name:lower():find(pat) then return inst end
        end
    end
    return nil
end

local function fire(rem, ...)
    local args = table.pack(...)
    pcall(function()
        if rem:IsA("RemoteEvent") then rem:FireServer(table.unpack(args, 1, args.n))
        else rem:InvokeServer(table.unpack(args, 1, args.n)) end
    end)
end

local function root()
    local c = LP.Character
    return c and c:FindFirstChild("HumanoidRootPart")
end

local function getMyGarden()
    local farms = Workspace:FindFirstChild("Farm")
                or Workspace:FindFirstChild("Farms")
                or Workspace:FindFirstChild("Plots")
    if not farms then return nil end
    for _, plot in ipairs(farms:GetChildren()) do
        local owner = plot:GetAttribute("Owner") or plot:GetAttribute("owner")
        if owner == LP.Name or owner == LP.UserId then return plot end
        -- Try children named "Important" with Data
        local important = plot:FindFirstChild("Important")
        if important then
            local data = important:FindFirstChild("Data")
                      or important:FindFirstChild("Owner_Tag")
            if data then
                local ownerVal = data:FindFirstChild("Owner") or data:FindFirstChild("Name")
                if ownerVal and ownerVal.Value == LP.Name then return plot end
            end
        end
    end
    return farms:GetChildren()[1]  -- fallback
end

function Plants:SetSeed(name)  state.seed_name = name end
function Plants:SetDelay(d)    state.plant_delay = math.max(0.1, d) end

function Plants:SetAutoPlant(enabled)
    state.auto_plant = enabled
    if not enabled then return end
    task.spawn(function()
        local rem = findRemote({ "Plant_RE", "PlantSeed", "Plant", "PlaceSeed" })
        if not rem then warn("[Zurly Plants] No plant remote found"); state.auto_plant = false; return end
        print("[Zurly Plants] Using plant remote:", rem:GetFullName())
        while state.auto_plant do
            local r = root()
            if r then
                -- Fire with position + seed name (common signature)
                fire(rem, r.Position, state.seed_name)
            end
            task.wait(state.plant_delay)
        end
    end)
end

function Plants:SetAutoHarvest(enabled)
    state.auto_harvest = enabled
    if not enabled then return end
    task.spawn(function()
        local rem = findRemote({ "CollectPlant", "Harvest", "CollectFruit", "Collect" })
        if not rem then warn("[Zurly Plants] No harvest remote found"); state.auto_harvest = false; return end
        print("[Zurly Plants] Using harvest remote:", rem:GetFullName())

        local function collectIn(folder)
            if not folder then return end
            for _, child in ipairs(folder:GetDescendants()) do
                if not state.auto_harvest then return end
                if child:IsA("Model") or child:IsA("BasePart") then
                    local n = child.Name:lower()
                    if (n:find("fruit") or n:find("crop") or n:find("plant")
                        or child:GetAttribute("Harvestable"))
                       and child.Parent then
                        fire(rem, child)
                        task.wait(0.08)
                    end
                end
            end
        end

        while state.auto_harvest do
            local plot = getMyGarden()
            if plot then collectIn(plot) end
            task.wait(1.2)
        end
    end)
end

function Plants:SetAutoWater(enabled)
    state.auto_water = enabled
    if not enabled then return end
    task.spawn(function()
        local rem = findRemote({ "Water", "WaterCan", "SprinklerUse" })
        if not rem then return end
        while state.auto_water do
            fire(rem)
            task.wait(2.0)
        end
    end)
end

return Plants
