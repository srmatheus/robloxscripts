-- NXS Teleport — safe CFrame-based TP to eggs in the world
-- Smooth movement (not instant snap) to reduce anti-cheat flags.

local Teleport = {}

local Players = game:GetService("Players")
local CS      = game:GetService("CollectionService")
local RS      = game:GetService("RunService")
local LP      = Players.LocalPlayer

local listFrame = nil
local theme     = nil
local rows      = {}

local function root()
    local ch = LP.Character; if not ch then return nil end
    return ch:FindFirstChild("HumanoidRootPart")
end

local function tpTo(part, smooth)
    local r = root(); if not r or not part then return end
    local target = part.CFrame + Vector3.new(0, 3, 0)
    if not smooth then
        r.CFrame = target
    else
        -- 20 steps over ~0.4s
        local start = r.CFrame
        for i = 1, 20 do
            if not r or not r.Parent then return end
            r.CFrame = start:Lerp(target, i / 20)
            task.wait(0.02)
        end
    end
end

local function listEggs()
    local out = {}
    for _, e in ipairs(CS:GetTagged("StealableEgg")) do
        if e:IsDescendantOf(workspace) then out[#out + 1] = e end
    end
    return out
end

function Teleport:SetListFrame(frame, th)
    listFrame = frame
    theme = th
    local lay = Instance.new("UIListLayout", frame)
    lay.Padding = UDim.new(0, 2)
    local pad = Instance.new("UIPadding", frame)
    pad.PaddingLeft = UDim.new(0, 4); pad.PaddingTop = UDim.new(0, 4)
    pad.PaddingRight = UDim.new(0, 4)
end

function Teleport:Refresh()
    if not listFrame then return end
    for _, r in ipairs(rows) do r:Destroy() end
    rows = {}

    local eggs = listEggs()
    for _, egg in ipairs(eggs) do
        local part = egg.PrimaryPart or egg:FindFirstChildWhichIsA("BasePart")
        if part then
            local btn = Instance.new("TextButton", listFrame)
            btn.Size = UDim2.new(1, -8, 0, 24)
            btn.BackgroundColor3 = theme and theme.panel or Color3.fromRGB(20, 30, 20)
            btn.BorderSizePixel = 0
            btn.Font = Enum.Font.Gotham; btn.TextSize = 11
            btn.TextColor3 = theme and theme.text or Color3.new(1,1,1)
            btn.TextXAlignment = Enum.TextXAlignment.Left
            btn.Text = "  " .. egg.Name .. "  —  TP"
            local c = Instance.new("UICorner", btn); c.CornerRadius = UDim.new(0, 3)
            btn.MouseButton1Click:Connect(function() tpTo(part, true) end)
            rows[#rows + 1] = btn
        end
    end
    print("[NXS Teleport] Listed " .. #eggs .. " eggs")
end

function Teleport:ToPart(part) tpTo(part, true) end
function Teleport:ToPartInstant(part) tpTo(part, false) end

return Teleport
