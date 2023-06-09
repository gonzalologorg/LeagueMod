if SERVER then
    util.AddNetworkString("League.CallOnClient")
end

local ent = FindMetaTable("Entity")

function ent:IsTarget()
    return self:IsNPC() or self:IsPlayer()
end

function ent:getFrameTime()
    local diff = CurTime() - (self._lastFrame or CurTime())
    self._lastFrame = CurTime()

    return diff
end

local timerMeta = {
    Name = "",
    Func = function() end,
    Remove = function(s)
        timer.Remove(s.Name)
    end,
    Remaining = function(s) return timer.TimeLeft(s.Name) end,
    Pause = function(s)
        timer.Pause(s.Name)
    end,
    Resume = function(s)
        timer.UnPause(s.Name)
    end,
    Do = function(s, substract)
        s.Func(s.Controller)

        if substract then
            timer.Adjust(s.Name, s.Delay, timer.RepsLeft(s.Name) - 1)

            if timer.RepsLeft(s.Name) <= 0 then
                s:Remove()
            end
        end
    end,
    __tostring = function(s) return "[Timer Object] ID: " .. s.Name end
}

timerMeta.__index = timerMeta
local waitingTimersEnt = {}

function ent:Wait(time, fun)
    self._timerIndex = (self._timerIndex or 0) + 1
    local timerName = self:EntIndex() .. "#_Simple_" .. self._timerIndex
    local timerObject = {}
    setmetatable(timerObject, timerMeta)
    timerObject.Delay = time
    timerObject.Name = timerName
    timerObject.Controller = self
    timerObject.Func = fun
    timerObject.__tostring = function() return timerName end

    timer.Create(timerName, time, 1, function()
        if not IsValid(self) then return end
        fun(self)
    end)

    return timerObject
end

function ent:LoopTimer(name, interval, fun)
    if not self._loopTimers then
        self._loopTimers = {}
    end

    self._loopTimers[name] = self:EntIndex() .. "#_Loop_" .. name
    local timerObject = {}
    setmetatable(timerObject, timerMeta)
    timerObject.Name = self._loopTimers[name]
    timerObject.Controller = self
    timerObject.Func = fun

    timer.Create(self._loopTimers[name], interval, 0, function()
        if not IsValid(self) then return end
        fun()
    end)

    return timerObject
end

hook.Add("EntityRemoved", "RemoveTimers", function(ent)
    if ent._timerIndex then
        for k = 1, ent._timerIndex do
            timer.Remove(ent:EntIndex() .. "#_ID" .. k)
        end
    end

    if ent._loopTimers then
        for k, v in pairs(ent._loopTimers) do
            timer.Remove(v)
        end
    end
end)

RPC_OWNER = 1
RPC_PVS = 2
RPC_PAS = 3
RPC_ALL = 4

function ent:callOnClient(target, method, args)
    net.Start("NRP.CallOnClient")
    net.WriteEntity(self)
    net.WriteString(method)
    net.WriteBool(args == nil)

    if args then
        net.WriteData(args)
    end

    if target == RPC_OWNER then
        net.Send(self:GetOwner())
    elseif target == RPC_PVS then
        net.SendPVS(self:GetPos())
    elseif target == RPC_PAS then
        net.SendPAS(self:GetPos())
    elseif target == RPC_ALL then
        net.Broadcast()
    elseif isentity(target) and target:IsPlayer() then
        net.Send(target)
    else
        net.Broadcast()
    end
end

local awaiting = {}

net.Receive("League.CallOnClient", function()
    local inc_ent = net.ReadUInt(16)

    if not IsValid(Entity(inc_ent)) then
        if not awaiting[inc_ent] then
            awaiting[inc_ent] = {}
            MsgC(Color(255, 100, 0), "[Core]", color_white, inc_ent, " is awaiting to be spawned.\n")
        end

        table.insert(awaiting[inc_ent], {net.ReadString(), net.ReadBool() and net.ReadData(net.BytesLeft()) or nil})

        return
    end

    inc_ent = Entity(inc_ent)
    local method = net.ReadString()
    local hasArg = net.ReadBool()

    if hasArg then
        local args = net.ReadData(net.BytesLeft())
        inc_ent[method](inc_ent, args)
    elseif inc_ent[method] then
        inc_ent[method](inc_ent)
    else
        MsgC(Color(255, 100, 0), "[Core]", color_white, inc_ent, " Missing method ", method, "!\n")
    end
end)

if SERVER then return end

hook.Add("OnEntityCreated", "League.CallOnClient", function(new_ent)
    if not awaiting[new_ent:EntIndex()] then return end

    for _, data in pairs(awaiting[new_ent:EntIndex()]) do
        local tries = 0
        local tag = FrameNumber() .. "_ent_await"

        timer.Create(tag, 0.1, 0, function()
            if IsValid(new_ent) and new_ent[data[1]] then
                new_ent[data[1]](new_ent, data[2])
                timer.Remove(tag)
            else
                tries = tries + 1

                if tries > 20 then
                    MsgC(Color(255, 100, 0), "[Core]", color_white, "Failed to call ", data[1], " on ", new_ent, "\n")
                    timer.Remove(tag)
                end
            end
        end)
    end

    awaiting[new_ent:EntIndex()] = nil
end)
