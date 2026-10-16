-- Zurly Hub — reusable UI widgets (toggle, slider, button, input, section)
-- Takes a Theme table and provides widget constructors.

local UIS = game:GetService("UserInputService")
local TS  = game:GetService("TweenService")

local M = {}

local function corner(p, r)
    local c = Instance.new("UICorner", p); c.CornerRadius = UDim.new(0, r or 4); return c
end
local function stroke(p, color, t)
    local s = Instance.new("UIStroke", p); s.Color = color; s.Thickness = t or 1
    s.Transparency = 0.4; return s
end
local function padding(p, n)
    local u = Instance.new("UIPadding", p)
    u.PaddingLeft = UDim.new(0, n); u.PaddingRight = UDim.new(0, n)
    u.PaddingTop = UDim.new(0, n); u.PaddingBottom = UDim.new(0, n)
    return u
end

M.corner = corner
M.stroke = stroke
M.padding = padding

function M.New(theme)
    local T = theme
    local W = {}

    function W.Section(parent, text)
        local h = Instance.new("TextLabel", parent)
        h.Size = UDim2.new(1, 0, 0, 22); h.BackgroundTransparency = 1
        h.Font = Enum.Font.GothamBold; h.TextSize = 13
        h.TextColor3 = T.accent; h.TextXAlignment = Enum.TextXAlignment.Left
        h.Text = string.upper(text)
        return h
    end

    function W.Toggle(parent, label, locked, initial, onChange)
        local row = Instance.new("Frame", parent)
        row.Size = UDim2.new(1, 0, 0, 28); row.BackgroundTransparency = 1
        local btn = Instance.new("TextButton", row)
        btn.Size = UDim2.new(0, 40, 0, 20); btn.Position = UDim2.new(0, 0, 0, 4)
        btn.BackgroundColor3 = initial and T.accent or T.panel2
        btn.Text = ""; btn.AutoButtonColor = false
        corner(btn, 10)
        local knob = Instance.new("Frame", btn)
        knob.Size = UDim2.new(0, 16, 0, 16)
        knob.Position = UDim2.new(0, initial and 22 or 2, 0.5, -8)
        knob.BackgroundColor3 = Color3.new(1,1,1); knob.BorderSizePixel = 0
        corner(knob, 8)
        local lbl = Instance.new("TextLabel", row)
        lbl.Size = UDim2.new(1, -50, 1, 0); lbl.Position = UDim2.new(0, 50, 0, 0)
        lbl.BackgroundTransparency = 1
        lbl.Font = Enum.Font.Gotham; lbl.TextSize = 13
        lbl.TextColor3 = locked and T.locked or T.text
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.Text = label .. (locked and "  [PREMIUM]" or "")
        local state = initial or false
        btn.MouseButton1Click:Connect(function()
            if locked then return end
            state = not state
            TS:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = state and T.accent or T.panel2}):Play()
            TS:Create(knob, TweenInfo.new(0.15), {Position = UDim2.new(0, state and 22 or 2, 0.5, -8)}):Play()
            if onChange then onChange(state) end
        end)
        return btn
    end

    function W.Slider(parent, label, locked, mn, mx, initial, onChange)
        local row = Instance.new("Frame", parent)
        row.Size = UDim2.new(1, 0, 0, 44); row.BackgroundTransparency = 1
        local lbl = Instance.new("TextLabel", row)
        lbl.Size = UDim2.new(1, 0, 0, 18); lbl.BackgroundTransparency = 1
        lbl.Font = Enum.Font.Gotham; lbl.TextSize = 12
        lbl.TextColor3 = locked and T.locked or T.textDim
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.Text = string.format("%s: %d%s", label, initial, locked and "  [PREMIUM]" or "")
        local bar = Instance.new("Frame", row)
        bar.Size = UDim2.new(1, -8, 0, 6); bar.Position = UDim2.new(0, 0, 0, 24)
        bar.BackgroundColor3 = T.panel2; bar.BorderSizePixel = 0
        corner(bar, 3)
        local pct = (initial - mn) / math.max(1, (mx - mn))
        local fill = Instance.new("Frame", bar)
        fill.Size = UDim2.new(pct, 0, 1, 0)
        fill.BackgroundColor3 = locked and T.locked or T.accent
        fill.BorderSizePixel = 0
        corner(fill, 3)
        local handle = Instance.new("TextButton", bar)
        handle.Size = UDim2.new(0, 14, 0, 14); handle.Position = UDim2.new(pct, -7, 0.5, -7)
        handle.BackgroundColor3 = Color3.new(1,1,1); handle.Text = ""; handle.AutoButtonColor = false
        corner(handle, 7)
        local dragging = false
        handle.MouseButton1Down:Connect(function() if not locked then dragging = true end end)
        UIS.InputEnded:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
        end)
        UIS.InputChanged:Connect(function(i)
            if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
                local rel = (i.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X
                rel = math.clamp(rel, 0, 1)
                local v = math.floor(mn + (mx - mn) * rel + 0.5)
                fill.Size = UDim2.new(rel, 0, 1, 0)
                handle.Position = UDim2.new(rel, -7, 0.5, -7)
                lbl.Text = string.format("%s: %d%s", label, v, locked and "  [PREMIUM]" or "")
                if onChange then onChange(v) end
            end
        end)
        return row
    end

    function W.Button(parent, label, locked, onClick)
        local b = Instance.new("TextButton", parent)
        b.Size = UDim2.new(1, 0, 0, 30)
        b.BackgroundColor3 = locked and T.locked or T.accentD
        b.BorderSizePixel = 0
        b.Font = Enum.Font.GothamSemibold; b.TextSize = 13
        b.TextColor3 = T.text; b.Text = label .. (locked and "  [PREMIUM]" or "")
        b.AutoButtonColor = not locked
        corner(b, 4)
        b.MouseButton1Click:Connect(function()
            if locked or not onClick then return end
            onClick()
        end)
        return b
    end

    function W.Input(parent, placeholder, initial, locked, onChange)
        local box = Instance.new("TextBox", parent)
        box.Size = UDim2.new(1, 0, 0, 30)
        box.BackgroundColor3 = T.panel2; box.BorderSizePixel = 0
        box.Font = Enum.Font.Code; box.TextSize = 13
        box.TextColor3 = locked and T.locked or T.text
        box.PlaceholderText = placeholder; box.PlaceholderColor3 = T.textDim
        box.Text = initial or ""; box.ClearTextOnFocus = false
        box.TextEditable = not locked
        corner(box, 4)
        local pad = Instance.new("UIPadding", box)
        pad.PaddingLeft = UDim.new(0, 8); pad.PaddingRight = UDim.new(0, 8)
        box.FocusLost:Connect(function()
            if locked or not onChange then return end
            onChange(box.Text)
        end)
        return box
    end

    function W.TextLabel(parent, text, size)
        local l = Instance.new("TextLabel", parent)
        l.Size = UDim2.new(1, 0, 0, size or 18); l.BackgroundTransparency = 1
        l.Font = Enum.Font.Gotham; l.TextSize = 12
        l.TextColor3 = T.textDim; l.TextXAlignment = Enum.TextXAlignment.Left
        l.TextWrapped = true; l.Text = text
        return l
    end

    return W
end

return M
