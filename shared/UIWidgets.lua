-- Zurly Hub — Modern UI widgets (refined dark + crimson)
local UIS = game:GetService("UserInputService")
local TS  = game:GetService("TweenService")

local M = {}

local function corner(p, r)
    local c = Instance.new("UICorner", p); c.CornerRadius = UDim.new(0, r or 6); return c
end
local function stroke(p, color, t, trans)
    local s = Instance.new("UIStroke", p); s.Color = color; s.Thickness = t or 1
    s.Transparency = trans or 0.3; return s
end
local function padding(p, n)
    local u = Instance.new("UIPadding", p)
    u.PaddingLeft = UDim.new(0, n); u.PaddingRight = UDim.new(0, n)
    u.PaddingTop = UDim.new(0, n); u.PaddingBottom = UDim.new(0, n)
    return u
end
local function gradient(p, c1, c2, rotation)
    local g = Instance.new("UIGradient", p)
    g.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, c1),
        ColorSequenceKeypoint.new(1, c2),
    })
    g.Rotation = rotation or 90
    return g
end

M.corner = corner; M.stroke = stroke; M.padding = padding; M.gradient = gradient

function M.New(theme)
    local T = theme
    local W = {}

    function W.Section(parent, text)
        local wrap = Instance.new("Frame", parent)
        wrap.Size = UDim2.new(1, 0, 0, 28); wrap.BackgroundTransparency = 1
        local h = Instance.new("TextLabel", wrap)
        h.Size = UDim2.new(1, 0, 0, 20); h.BackgroundTransparency = 1
        h.Font = Enum.Font.GothamBold; h.TextSize = 11
        h.TextColor3 = T.accent; h.TextXAlignment = Enum.TextXAlignment.Left
        h.Text = string.upper(text)
        local line = Instance.new("Frame", wrap)
        line.Size = UDim2.new(1, 0, 0, 1); line.Position = UDim2.new(0, 0, 1, -4)
        line.BackgroundColor3 = T.panel3; line.BorderSizePixel = 0
        line.BackgroundTransparency = 0.3
        return wrap
    end

    function W.Toggle(parent, label, locked, initial, onChange)
        local row = Instance.new("Frame", parent)
        row.Size = UDim2.new(1, 0, 0, 32); row.BackgroundColor3 = T.panel2
        row.BorderSizePixel = 0
        corner(row, 6)
        local pad = Instance.new("UIPadding", row)
        pad.PaddingLeft = UDim.new(0, 10); pad.PaddingRight = UDim.new(0, 10)

        local lbl = Instance.new("TextLabel", row)
        lbl.Size = UDim2.new(1, -60, 1, 0); lbl.BackgroundTransparency = 1
        lbl.Font = Enum.Font.GothamMedium; lbl.TextSize = 12
        lbl.TextColor3 = locked and T.locked or T.text
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.Text = label .. (locked and "   premium" or "")

        local track = Instance.new("TextButton", row)
        track.Size = UDim2.new(0, 36, 0, 18); track.Position = UDim2.new(1, -46, 0.5, -9)
        track.BackgroundColor3 = initial and T.accent or T.panel3
        track.Text = ""; track.AutoButtonColor = false
        track.BorderSizePixel = 0
        corner(track, 9)

        local knob = Instance.new("Frame", track)
        knob.Size = UDim2.new(0, 14, 0, 14); knob.Position = UDim2.new(0, initial and 20 or 2, 0.5, -7)
        knob.BackgroundColor3 = Color3.new(1,1,1); knob.BorderSizePixel = 0
        corner(knob, 7)

        local state = initial or false
        track.MouseButton1Click:Connect(function()
            if locked then return end
            state = not state
            TS:Create(track, TweenInfo.new(0.18, Enum.EasingStyle.Quart), {BackgroundColor3 = state and T.accent or T.panel3}):Play()
            TS:Create(knob, TweenInfo.new(0.18, Enum.EasingStyle.Quart), {Position = UDim2.new(0, state and 20 or 2, 0.5, -7)}):Play()
            if onChange then onChange(state) end
        end)
        return track
    end

    function W.Slider(parent, label, locked, mn, mx, initial, onChange)
        local row = Instance.new("Frame", parent)
        row.Size = UDim2.new(1, 0, 0, 46); row.BackgroundColor3 = T.panel2
        row.BorderSizePixel = 0
        corner(row, 6)
        local pad = Instance.new("UIPadding", row)
        pad.PaddingLeft = UDim.new(0, 10); pad.PaddingRight = UDim.new(0, 10)
        pad.PaddingTop = UDim.new(0, 6)

        local lbl = Instance.new("TextLabel", row)
        lbl.Size = UDim2.new(1, 0, 0, 16); lbl.BackgroundTransparency = 1
        lbl.Font = Enum.Font.GothamMedium; lbl.TextSize = 12
        lbl.TextColor3 = locked and T.locked or T.textDim
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.Text = string.format("%s   %d", label, initial)

        local bar = Instance.new("Frame", row)
        bar.Size = UDim2.new(1, 0, 0, 4); bar.Position = UDim2.new(0, 0, 0, 24)
        bar.BackgroundColor3 = T.panel3; bar.BorderSizePixel = 0
        corner(bar, 2)
        local pct = (initial - mn) / math.max(1, (mx - mn))
        local fill = Instance.new("Frame", bar)
        fill.Size = UDim2.new(pct, 0, 1, 0)
        fill.BackgroundColor3 = locked and T.locked or T.accent
        fill.BorderSizePixel = 0
        corner(fill, 2)
        local handle = Instance.new("TextButton", bar)
        handle.Size = UDim2.new(0, 12, 0, 12); handle.Position = UDim2.new(pct, -6, 0.5, -6)
        handle.BackgroundColor3 = Color3.new(1,1,1); handle.Text = ""; handle.AutoButtonColor = false
        corner(handle, 6)
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
                handle.Position = UDim2.new(rel, -6, 0.5, -6)
                lbl.Text = string.format("%s   %d", label, v)
                if onChange then onChange(v) end
            end
        end)
        return row
    end

    function W.Button(parent, label, locked, onClick)
        local b = Instance.new("TextButton", parent)
        b.Size = UDim2.new(1, 0, 0, 32)
        b.BackgroundColor3 = locked and T.panel3 or T.accentD
        b.BorderSizePixel = 0
        b.Font = Enum.Font.GothamSemibold; b.TextSize = 12
        b.TextColor3 = T.text; b.Text = label
        b.AutoButtonColor = false
        corner(b, 6)
        if not locked then
            b.MouseEnter:Connect(function()
                TS:Create(b, TweenInfo.new(0.12), {BackgroundColor3 = T.accent}):Play()
            end)
            b.MouseLeave:Connect(function()
                TS:Create(b, TweenInfo.new(0.12), {BackgroundColor3 = T.accentD}):Play()
            end)
        end
        b.MouseButton1Click:Connect(function()
            if locked or not onClick then return end
            onClick()
        end)
        return b
    end

    function W.Input(parent, placeholder, initial, locked, onChange)
        local box = Instance.new("TextBox", parent)
        box.Size = UDim2.new(1, 0, 0, 32)
        box.BackgroundColor3 = T.panel2; box.BorderSizePixel = 0
        box.Font = Enum.Font.Code; box.TextSize = 12
        box.TextColor3 = locked and T.locked or T.text
        box.PlaceholderText = placeholder; box.PlaceholderColor3 = T.textFaint
        box.Text = initial or ""; box.ClearTextOnFocus = false
        box.TextEditable = not locked
        box.TextXAlignment = Enum.TextXAlignment.Left
        corner(box, 6)
        local pad = Instance.new("UIPadding", box)
        pad.PaddingLeft = UDim.new(0, 10); pad.PaddingRight = UDim.new(0, 10)
        box.FocusLost:Connect(function()
            if locked or not onChange then return end
            onChange(box.Text)
        end)
        return box
    end

    function W.TextLabel(parent, text, size, color)
        local l = Instance.new("TextLabel", parent)
        l.Size = UDim2.new(1, 0, 0, size or 18); l.BackgroundTransparency = 1
        l.Font = Enum.Font.Gotham; l.TextSize = 12
        l.TextColor3 = color or T.textDim
        l.TextXAlignment = Enum.TextXAlignment.Left
        l.TextYAlignment = Enum.TextYAlignment.Top
        l.TextWrapped = true; l.Text = text
        return l
    end

    function W.Divider(parent)
        local d = Instance.new("Frame", parent)
        d.Size = UDim2.new(1, 0, 0, 1); d.BackgroundColor3 = T.border
        d.BackgroundTransparency = 0.5; d.BorderSizePixel = 0
        return d
    end

    return W
end

return M
