-- NXS Auto Fuse (Premium) — fuses lower-rarity pets to level up
-- Scans Backpack / Inventory for pets and fires Fuse remote periodically.

local AutoFuse = {}

local Players = game:GetService("Players")
local RS      = game:GetService("ReplicatedStorage")
local LP      = Players.LocalPlayer

local enabled = false

local function findRemote()
    local candidates = { "FusePets", "Fuse", "FuseEgg", "FusePet", "CombinePets" }
    for _, folderName in ipairs({ "EggRemotes", "Remotes", "RemoteEvents", "PetRemotes" }) do
        local f = RS:FindFirstChild(folderName)
        if f then
            for _, name in ipairs(candidates) do
                local r = f:FindFirstChild(name, true)
                if r and (r:IsA("RemoteEvent") or r:IsA("RemoteFunction")) then return r end
            end
        end
    end
    for _, inst in ipairs(RS:GetDescendants()) do
        if (inst:IsA("RemoteEvent") or inst:IsA("RemoteFunction"))
           and inst.Name:lower():find("fuse") then return inst end
    end
    return nil
end

function AutoFuse:SetEnabled(v)
    enabled = v
    if not v then return end
    task.spawn(function()
        local rem = findRemote()
        if not rem then
            warn("[NXS AutoFuse] No fuse remote found")
            enabled = false
            return
        end
        print("[NXS AutoFuse] Using remote:", rem:GetFullName())
        while enabled do
            pcall(function()
                if rem:IsA("RemoteEvent") then rem:FireServer()
                else rem:InvokeServer() end
            end)
            task.wait(2.5)
        end
    end)
end

function AutoFuse:IsEnabled() return enabled end

return AutoFuse
