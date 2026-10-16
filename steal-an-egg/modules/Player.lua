-- NXS Player — flight, walkspeed, jumppower, anti-AFK
-- Fixed bugs from original fork (missing comma in Config).

local Player = {}

local Players = game:GetService("Players")
local UIS     = game:GetService("UserInputService")
local RS      = game:GetService("RunService")
local VI      = game:GetService("VirtualInputManager")
local LP      = Players.LocalPlayer

local cfg = {
    flight_speed = 55,
    up_down_speed = 45,
}

local flightEnabled = false
local flightConn    = nil

local function getChar()
    return LP.Character or LP.CharacterAdded:Wait()
end

local function stopFlight()
    flightEnabled = false
    if flightConn then flightConn:Disconnect(); flightConn = nil end
    local ch = LP.Character
    if not ch then return end
    local hum = ch:FindFirstChildOfClass("Humanoid")
    local hrp = ch:FindFirstChild("HumanoidRootPart")
    if hum then hum.PlatformStand = false end
    if hrp then hrp.AssemblyLinearVelocity = Vector3.zero end
end

local function startFlight()
    if flightEnabled then return end
    local ch = getChar()
    local hum = ch:FindFirstChildOfClass("Humanoid")
    local hrp = ch:FindFirstChild("HumanoidRootPart")
    if not hum or not hrp then return end

    flightEnabled = true
    hum.PlatformStand = true

    flightConn = RS.Heartbeat:Connect(function()
        if not flightEnabled or not hrp.Parent then return end
        local cam = workspace.CurrentCamera
        if not cam then return end
        local dir = Vector3.zero
        if UIS:IsKeyDown(Enum.KeyCode.W) then dir += cam.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.S) then dir -= cam.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.A) then dir -= cam.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.D) then dir += cam.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.Space) then dir += Vector3.yAxis end
        if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then dir -= Vector3.yAxis end

        if dir.Magnitude > 0 then dir = dir.Unit end
        local vel = dir * cfg.flight_speed
        if dir.Y ~= 0 then
            vel = Vector3.new(vel.X, dir.Y * cfg.up_down_speed, vel.Z)
        end
        hrp.AssemblyLinearVelocity = vel
    end)
end

function Player:SetFlight(enabled)
    if enabled then startFlight() else stopFlight() end
end

function Player:SetFlightSpeed(v)
    cfg.flight_speed = v
    cfg.up_down_speed = math.max(10, v - 10)
end

function Player:SetWalkSpeed(v)
    local ch = LP.Character; if not ch then return end
    local hum = ch:FindFirstChildOfClass("Humanoid"); if hum then hum.WalkSpeed = v end
end

function Player:SetJumpPower(v)
    local ch = LP.Character; if not ch then return end
    local hum = ch:FindFirstChildOfClass("Humanoid")
    if hum then
        hum.UseJumpPower = true
        hum.JumpPower = v
    end
end

-- Anti-AFK: block the 20-minute kick by simulating input
local afkConn = nil
function Player:SetAntiAFK(enabled)
    if afkConn then afkConn:Disconnect(); afkConn = nil end
    if not enabled then return end
    afkConn = LP.Idled:Connect(function()
        pcall(function()
            VI:SendKeyEvent(true, "Space", false, game)
            task.wait(0.1)
            VI:SendKeyEvent(false, "Space", false, game)
        end)
    end)
end

LP.CharacterAdded:Connect(function()
    stopFlight()
end)

return Player
