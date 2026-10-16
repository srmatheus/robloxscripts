-- NXS Auto Hatch (Premium) — triggers egg hatching remotes periodically
-- Uses discovered remote patterns common to Steal An Egg clones.

local AutoHatch = {}

local Players = game:GetService("Players")
local RS      = game:GetService("ReplicatedStorage")
local LP      = Players.LocalPlayer

local enabled = false

local function findRemote()
    local candidates = { "HatchEgg", "Hatch", "OpenEgg", "ClaimEgg", "HatchPet" }
    for _, folderName in ipairs({ "EggRemotes", "Remotes", "RemoteEvents" }) do
        local f = RS:FindFirstChild(folderName)
        if f then
            for _, name in ipairs(candidates) do
                local r = f:FindFirstChild(name, true)
                if r and (r:IsA("RemoteEvent") or r:IsA("RemoteFunction")) then return r end
            end
        end
    end
    -- Deep scan fallback
    for _, inst in ipairs(RS:GetDescendants()) do
        if (inst:IsA("RemoteEvent") or inst:IsA("RemoteFunction")) then
            local n = inst.Name:lower()
            if n:find("hatch") or n:find("openegg") then return inst end
        end
    end
    return nil
end

local function fire(rem)
    pcall(function()
        if rem:IsA("RemoteEvent") then rem:FireServer()
        else rem:InvokeServer() end
    end)
end

function AutoHatch:SetEnabled(v)
    enabled = v
    if not v then return end
    task.spawn(function()
        local rem = findRemote()
        if not rem then
            warn("[NXS AutoHatch] No hatch remote found in this game")
            enabled = false
            return
        end
        print("[NXS AutoHatch] Using remote:", rem:GetFullName())
        while enabled do
            fire(rem)
            task.wait(1.5)
        end
    end)
end

function AutoHatch:IsEnabled() return enabled end

return AutoHatch
