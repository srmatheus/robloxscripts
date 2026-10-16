-- Zurly Hub — Grow a Garden: Pets (auto equip best, auto fuse by mutation, ESP rare)

local Pets = {}

local Players = game:GetService("Players")
local RS      = game:GetService("ReplicatedStorage")
local LP      = Players.LocalPlayer

local state = {
    auto_fuse = false,
    auto_equip_best = false,
    target_mutations = { Rainbow = true, Golden = true, Rot = true, Warped = true },
    esp_rare = false,
}

local function findRemote(names)
    for _, fn in ipairs({ "GameEvents", "PetEvents", "Remotes", "RemoteEvents" }) do
        local f = RS:FindFirstChild(fn)
        if f then
            for _, nm in ipairs(names) do
                local r = f:FindFirstChild(nm, true)
                if r and (r:IsA("RemoteEvent") or r:IsA("RemoteFunction")) then return r end
            end
        end
    end
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
    pcall(function()
        if rem:IsA("RemoteEvent") then rem:FireServer(...)
        else rem:InvokeServer(...) end
    end)
end

local function getInventory()
    -- Pets usually live under PlayerData / Inventory / Pets
    local pd = LP:FindFirstChild("PlayerData") or LP:FindFirstChild("leaderstats")
    if pd then
        local inv = pd:FindFirstChild("Inventory") or pd:FindFirstChild("Pets")
        if inv then return inv end
    end
    return nil
end

function Pets:SetTargetMutations(tbl) state.target_mutations = tbl end

function Pets:SetAutoFuse(enabled)
    state.auto_fuse = enabled
    if not enabled then return end
    task.spawn(function()
        local rem = findRemote({ "FusePets", "Fuse", "CombinePets", "FusePet" })
        if not rem then warn("[Zurly Pets] No fuse remote found"); state.auto_fuse = false; return end
        print("[Zurly Pets] Using fuse remote:", rem:GetFullName())
        while state.auto_fuse do
            fire(rem)
            task.wait(2.5)
        end
    end)
end

function Pets:SetAutoEquipBest(enabled)
    state.auto_equip_best = enabled
    if not enabled then return end
    task.spawn(function()
        local rem = findRemote({ "EquipPet", "EquipBest", "AutoEquip" })
        if not rem then return end
        while state.auto_equip_best do
            fire(rem)
            task.wait(10)
        end
    end)
end

-- ESP: highlight pets with target mutations in your garden
local HL = "ZurlyPetESP"
function Pets:SetESP(enabled)
    state.esp_rare = enabled
    if not enabled then
        for _, h in ipairs(workspace:GetDescendants()) do
            if h:IsA("Highlight") and h.Name == HL then h:Destroy() end
        end
        return
    end
    task.spawn(function()
        while state.esp_rare do
            for _, inst in ipairs(workspace:GetDescendants()) do
                if inst:IsA("Model") then
                    local mut = inst:GetAttribute("Mutation") or inst:GetAttribute("MutationType")
                    if mut and state.target_mutations[mut] and not inst:FindFirstChild(HL) then
                        local h = Instance.new("Highlight", inst)
                        h.Name = HL
                        h.FillColor = Color3.fromRGB(255, 50, 50)
                        h.OutlineColor = Color3.fromRGB(255, 255, 255)
                        h.FillTransparency = 0.5
                    end
                end
            end
            task.wait(3)
        end
    end)
end

return Pets
