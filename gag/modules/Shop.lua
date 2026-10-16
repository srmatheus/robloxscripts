-- Zurly Hub — Grow a Garden: Shop (auto buy seeds, auto sell crops, auto buy pet eggs)

local Shop = {}

local Players = game:GetService("Players")
local RS      = game:GetService("ReplicatedStorage")
local LP      = Players.LocalPlayer

local state = {
    auto_sell = false,
    auto_buy_seeds = false,
    buy_list = {}, -- {["Carrot"]=true, ["Strawberry"]=true, ...}
    sell_delay = 20,
    buy_delay = 15,
}

local function findRemote(names)
    for _, fn in ipairs({ "GameEvents", "Remotes", "RemoteEvents", "Events" }) do
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
    local args = table.pack(...)
    pcall(function()
        if rem:IsA("RemoteEvent") then rem:FireServer(table.unpack(args, 1, args.n))
        else rem:InvokeServer(table.unpack(args, 1, args.n)) end
    end)
end

function Shop:SetAutoSell(enabled)
    state.auto_sell = enabled
    if not enabled then return end
    task.spawn(function()
        local rem = findRemote({ "Sell_Inventory", "SellInventory", "Sell", "SellAll" })
        if not rem then warn("[Zurly Shop] No sell remote found"); state.auto_sell = false; return end
        print("[Zurly Shop] Using sell remote:", rem:GetFullName())
        while state.auto_sell do
            fire(rem)
            task.wait(state.sell_delay)
        end
    end)
end

function Shop:SetBuyList(list)
    state.buy_list = list or {}
end

function Shop:SetAutoBuySeeds(enabled)
    state.auto_buy_seeds = enabled
    if not enabled then return end
    task.spawn(function()
        local rem = findRemote({ "BuySeedStock", "BuySeed", "PurchaseSeed", "BuyItem" })
        if not rem then warn("[Zurly Shop] No buy remote found"); state.auto_buy_seeds = false; return end
        print("[Zurly Shop] Using buy remote:", rem:GetFullName())
        while state.auto_buy_seeds do
            for name, enabled in pairs(state.buy_list) do
                if not state.auto_buy_seeds then break end
                if enabled then
                    fire(rem, name)
                    task.wait(0.15)
                end
            end
            task.wait(state.buy_delay)
        end
    end)
end

function Shop:SellOnce()
    local rem = findRemote({ "Sell_Inventory", "SellInventory", "Sell", "SellAll" })
    if rem then fire(rem) end
end

return Shop
