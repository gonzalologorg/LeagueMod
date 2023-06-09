-- MIT License

-- Copyright (c) 2022 Jova1106

-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to deal
-- in the Software without restriction, including without limitation the rights
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
-- copies of the Software, and to permit persons to whom the Software is
-- furnished to do so, subject to the following conditions:

-- The above copyright notice and this permission notice shall be included in all
-- copies or substantial portions of the Software.

-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
-- SOFTWARE.

--------------------------------------------------------------------------------

-- EASING FUNCTIONS
local math_pi = math.pi
local math_pow = math.pow
local math_sqrt = math.sqrt
local math_sin = math.sin
local math_cos = math.cos

function TWEEN_EASE_LINEAR(n)
	return n
end

function TWEEN_EASE_IN_OUT(n)
	return n * n * (3 - 2 * n)
end

-- Credit: https://easings.net/
function TWEEN_EASE_SINE_IN(n)
	return 1 - math_cos(n * math_pi / 2)
end

function TWEEN_EASE_SINE_OUT(n)
	return math_sin(n * math_pi / 2)
end

function TWEEN_EASE_SINE_IN_OUT(n)
	return -(math_cos(math_pi * n) - 1) / 2
end

function TWEEN_EASE_QUAD_IN(n)
	return n * n
end

function TWEEN_EASE_QUAD_OUT(n)
	return 1 - (1 - n) * (1 - n)
end

function TWEEN_EASE_QUAD_IN_OUT(n)
	return n < 0.5 and 2 * n * n or 1 - math_pow(-2 * n + 2, 2) / 2
end

function TWEEN_EASE_CUBIC_IN(n)
	return n * n * n
end

function TWEEN_EASE_CUBIC_OUT(n)
	return 1 - math_pow(1 - n, 3)
end

function TWEEN_EASE_CUBIC_IN_OUT(n)
	return n < 0.5 and 4 * n * n * n or 1 - math_pow(-2 * n + 2, 3) / 2
end

function TWEEN_EASE_QUART_IN(n)
	return n * n * n * n
end

function TWEEN_EASE_QUART_OUT(n)
	return 1 - math_pow(1 - n, 4)
end

function TWEEN_EASE_QUART_IN_OUT(n)
	return n < 0.5 and 8 * n * n * n * n or 1 - math_pow(-2 * n + 2, 4) / 2
end

function TWEEN_EASE_QUINT_IN(n)
	return n * n * n * n * n
end

function TWEEN_EASE_QUINT_OUT(n)
	return 1 - math_pow(1 - n, 5)
end

function TWEEN_EASE_QUINT_IN_OUT(n)
	return n < 0.5 and 16 * n * n * n * n * n or 1 - math_pow(-2 * n + 2, 5) / 2
end

function TWEEN_EASE_EXPO_IN(n)
	return n == 0 and 0 or math_pow(2, 10 * n - 10)
end

function TWEEN_EASE_EXPO_OUT(n)
	return n == 1 and 1 or 1 - math_pow(2, -10 * n)
end

function TWEEN_EASE_EXPO_IN_OUT(n)
	return n == 0 and 0 or n == 1 and 1 or n < 0.5 and math_pow(2, 20 * n - 10) / 2 or (2 - math_pow(2, -20 * n + 10)) / 2
end

function TWEEN_EASE_CIRC_IN(n)
	return 1 - math_sqrt(1 - math_pow(n, 2))
end

function TWEEN_EASE_CIRC_OUT(n)
	return math_sqrt(1 - math_pow(n - 1, 2))
end

function TWEEN_EASE_CIRC_IN_OUT(n)
	return n < 0.5 and (1 - math_sqrt(1 - math_pow(2 * n, 2))) / 2 or (math_sqrt(1 - math_pow(-2 * n + 2, 2)) + 1) / 2
end

function TWEEN_EASE_BACK_IN(n)
	local c1 = 1.70158
	local c3 = c1 + 1

	return c3 * n * n * n - c1 * n * n
end

function TWEEN_EASE_BACK_OUT(n)
	local c1 = 1.70158
	local c3 = c1 + 1

	return 1 + c3 * math_pow(n - 1, 3) + c1 * math_pow(n - 1, 2)
end

function TWEEN_EASE_BACK_IN_OUT(n)
	local c1 = 1.70158
	local c2 = c1 * 1.525

	return n < 0.5 and (math_pow(2 * n, 2) * ((c2 + 1) * 2 * n - c2)) / 2 or (math_pow(2 * n - 2, 2) * ((c2 + 1) * (n * 2 - 2) + c2) + 2) / 2
end

function TWEEN_EASE_ELASTIC_IN(n)
	local c4 = (2 * math_pi) / 3

	return n == 0 and 0 or n == 1 and 1 or -math_pow(2, 10 * n - 10) * math_sin((n * 10 - 10.75) * c4)
end

function TWEEN_EASE_ELASTIC_OUT(n)
	local c4 = (2 * math_pi) / 3

	return n == 0 and 0 or n == 1 and 1 or math_pow(2, -10 * n) * math_sin((n * 10 - 0.75) * c4) + 1
end

function TWEEN_EASE_ELASTIC_IN_OUT(n)
	local c5 = (2 * math_pi) / 4.5

	return n == 0 and 0 or n == 1 and 1 or n < 0.5 and -(math_pow(2, 20 * n - 10) * math_sin((20 * n - 11.125) * c5)) / 2 or (math_pow(2, -20 * n + 10) * math_sin((20 * n - 11.125) * c5)) / 2 + 1
end

function TWEEN_EASE_BOUNCE_IN(n)
	return 1 - TWEEN_EASE_BOUNCE_OUT(1 - n)
end

function TWEEN_EASE_BOUNCE_OUT(n)
	local n1 = 7.5625
	local d1 = 2.75

	if n < 1 / d1 then
		return n1 * n * n
	elseif n < 2 / d1 then
		return n1 * (n - 1.5 / d1) * (n - 1.5 / d1) + 0.75
	elseif n < 2.5 / d1 then
		return n1 * (n - 2.25 / d1) * (n - 2.25 / d1) + 0.9375
	else
		return n1 * (n - 2.625 / d1) * (n - 2.625 / d1) + 0.984375
	end
end

function TWEEN_EASE_BOUNCE_IN_OUT(n)
	return n < 0.5 and (1 - TWEEN_EASE_BOUNCE_OUT(1 - 2 * n)) / 2 or (1 + TWEEN_EASE_BOUNCE_OUT(2 * n - 1)) / 2
end
--------------------------------------------------------------------------------

tween = {}

-- table.Inherit without the self.BaseClass table
local function table_Inherit(target, base)
	for k, v in next, base do
		if target[k] then continue end
		
		target[k] = v
	end
	
	return target
end

local metaTable_Vector2 = {
	__add = function(self, other)
		return Vector2(self.x + other.x, self.y + other.y)
	end,
	
	__sub = function(self, other)
		return Vector2(self.x - other.x, self.y - other.y)
	end,
	
	__mul = function(self, other)
		if isvector2(self) and isnumber(other) then
			return Vector2(self.x * other, self.y * other)
		elseif isnumber(self) and isvector2(other) then
			return Vector2(self * other.x, self * other.y)
		else
			return Vector2(self.x * other.x, self.y * other.y)
		end
	end,
	
	__div = function(self, other)
		if isvector2(self) and isnumber(other) then
			return Vector2(self.x / other, self.y / other)
		elseif isnumber(self) and isvector2(other) then
			return Vector2(self / other.x, self / other.y)
		else
			return Vector2(self.x / other.x, self.y / other.y)
		end
	end,
	
	__tostring = function(self)
		return string.format("%.6f %.6f", self.x, self.y)
	end,
	
	SetUnpacked = function(self, x, y)
		self.x = x
		self.y = y
	end,
	
	GetPos = function(self)
		return Vector2(self.x, self.y)
	end
}

metaTable_Vector2.__index = metaTable_Vector2

function isvector2(v)
	return getmetatable(v) == metaTable_Vector2
end

function Vector2(x, y)
	local Vector2 = {
		x = x,
		y = y
	}
	
	return setmetatable(Vector2, metaTable_Vector2)
end

-- Lerp Functions
function tween.Lerp(from, to, t)
	return (1 - t) * from + t * to
end

local Lerp = tween.Lerp

local function LerpAng(from, to, t)
	local d = to - from

	if d > 180 then
		to = to - 360
	elseif d < -180 then
		to = to + 360
	end

	return Lerp(from, to, t)
end

function tween.LerpAngle(from, to, t)
	return Angle(
		LerpAng(from.p, to.p, t),
		LerpAng(from.y, to.y, t),
		LerpAng(from.r, to.r, t)
	)
end

local LerpAngle = tween.LerpAngle

local function LerpVector2Unpacked(vector2, from, to, t)
	local lerped_vector2 = Lerp(from, to, t)
	
	vector2:SetUnpacked(lerped_vector2.x, lerped_vector2.y)
end

local function LerpVectorUnpacked(vector, from, to, t)
	local lerped_vector = Lerp(from, to, t)
	
	vector:SetUnpacked(lerped_vector.x, lerped_vector.y, lerped_vector.z)
end

local function LerpColor(from, to, t)
	return Color(
		Lerp(from.r, to.r, t),
		Lerp(from.g, to.g, t),
		Lerp(from.b, to.b, t),
		Lerp(from.a, to.a, t)
	)
end

local function LerpColorUnpacked(color, from, to, t)
	color:SetUnpacked(
		Lerp(from.r, to.r, t),
		Lerp(from.g, to.g, t),
		Lerp(from.b, to.b, t),
		Lerp(from.a, to.a, t)
	)
end

local function LerpAngleUnpacked(angle, from, to, t)
	angle:SetUnpacked(
		LerpAng(from.p, to.p, t),
		LerpAng(from.y, to.y, t),
		LerpAng(from.r, to.r, t)
	)
end

-- Credit: WLKRE (https://github.com/JWalkerMailly)
function tween.BSpline(points, t, --[[internal]] i, --[[internal]] c)
	if i == nil then
		i, c = 1, #points
	end
	
	if c == 1 then return points[i] end
	
	local p1 = tween.BSpline(points, t, i, c - 1)
	local p2 = tween.BSpline(points, t, i + 1, c - 1)
	
	return Lerp(p1, p2, t)
end

local BSpline = tween.BSpline
--

-- Tween Object(s)
local all_tweens = {}
local running_tweens = {}
local paused_tweens = {}
local stopped_tweens = {}

local type_to_function = {
	["number"] = Lerp,
	["vector2"] = Lerp,
	["vector"] = Lerp,
	["color"] = LerpColor,
	["angle"] = LerpAngle
}

local type_to_function_unpacked = {
	["number"] = Lerp,
	["vector2"] = LerpVector2Unpacked,
	["vector"] = LerpVectorUnpacked,
	["color"] = LerpColorUnpacked,
	["angle"] = LerpAngleUnpacked
}

local function tween_type(object)
	return isvector2(object) and "vector2"
		or IsColor(object) and "color"
		or type(object):lower()
end

local metaTable_Tween = {
	__newindex = function(self, key, value)
		rawset(self, key, value)
	end,
	
	Start = function(self)
		self.running = true
		self.start_time = SysTime()
		self.end_time = self.start_time + self.duration
		self.time_left = self.duration
		self.tween_type = tween_type(self.from)
		self.lerp_type = type_to_function[self.tween_type]
		
		all_tweens[self] = true
		running_tweens[self] = true
	end,
	
	SetPermanent = function(self, bool)
		self.permanent = bool
	end,
	
	SetFrom = function(self, from)
		self.from = from
	end,
	
	SetTo = function(self, to)
		self.to = to
	end,
	
	SetWaypoints = function(self, from, to)
		self.from = from
		self.to = to
	end,
	
	SetDuration = function(self, duration)
		self.duration = duration
	end,
	
	SetEaseType = function(self, ease_type)
		self.ease_type = ease_type
	end,
	
	Restart = function(self)
		if !all_tweens[self] then
			self:Start()
			
			return
		end
		
		self.running = true
		self.start_time = SysTime()
		self.end_time = self.start_time + self.duration
		self.time_left = self.duration
		
		if !running_tweens[self] then
			running_tweens[self] = true
		end
		
		if paused_tweens[self] then
			paused_tweens[self] = nil
		elseif stopped_tweens[self] then
			stopped_tweens[self] = nil
		end
	end,
	
	Pause = function(self)
		if stopped_tweens[self] then return end
		
		self.running = false
		
		if running_tweens[self] then
			running_tweens[self] = nil
			paused_tweens[self] = true
		end
	end,
	
	Resume = function(self)
		if stopped_tweens[self] then
			self:Restart()
			
			return
		end
		
		self.start_time = SysTime() - (self.duration - self.time_left)
		self.end_time = self.start_time + self.duration
		self.running = true
		
		if paused_tweens[self] then
			paused_tweens[self] = nil
			running_tweens[self] = true
		end
	end,
	
	Stop = function(self)
		self.running = false
		
		if running_tweens[self] then
			running_tweens[self] = nil
		elseif paused_tweens[self] then
			paused_tweens[self] = nil
		end
		
		stopped_tweens[self] = true
	end,
	
	Update = function(self)
		if self.running then
			local time = SysTime()
			self.time_left = self.end_time - time
			
			if time >= self.end_time then
				self.running = false
				self.value = self.to
				
				if !self.permanent then
					all_tweens[self] = nil
					running_tweens[self] = nil
				end
				
				if self.callback != nil then
					self.callback(self)
				end
				
				return
			end
			
			local alpha = (time - self.start_time) / self.duration
			
			self.value = self.lerp_type(self.from, self.to, self.ease_type(alpha))
		end
	end,
	
	TimeLeft = function(self)
		return self.time_left
	end,
	
	GetValue = function(self)
		return self.value
	end,
	
	Destroy = function(self)
		all_tweens[self] = nil
		
		if running_tweens[self] then
			running_tweens[self] = nil
		elseif paused_tweens[self] then
			paused_tweens[self] = nil
		elseif stopped_tweens[self] then
			stopped_tweens[self] = nil
		end
	end,
	
	SetCallback = function(self, callback)
		self.callback = callback
	end
}

metaTable_Tween.__index = metaTable_Tween

function Tween(from, to, duration, ease_type, callback)
	local Tween = {
		from = from,
		to = to,
		duration = duration,
		ease_type = ease_type,
		callback = callback,
		value = from,
		time_left = duration,
		permanent = false,
		running = false
	}
	
	return setmetatable(Tween, metaTable_Tween)
end

local metaTable_TweenUnpacked = {
	Start = function(self)
		self.running = true
		self.start_time = SysTime()
		self.end_time = self.start_time + self.duration
		self.time_left = self.duration
		self.tween_type = tween_type(self.base_object)
		self.lerp_type_unpacked = type_to_function_unpacked[self.tween_type]
		
		all_tweens[self] = true
		running_tweens[self] = true
	end,
	
	Update = function(self)
		if self.running then
			local to = self.to
			local time = SysTime()
			self.time_left = self.end_time - time
			
			if time >= self.end_time then
				self.running = false
				self.value = to
				self.base_object = to
				
				if !self.permanent then
					all_tweens[self] = nil
					running_tweens[self] = nil
				end
				
				if self.callback != nil then
					self.callback()
				end
				
				return
			end
			
			local alpha = (time - self.start_time) / self.duration
			
			if self.tween_type == "number" then
				self.value = Lerp(self.from, to, self.ease_type(alpha))
			else
				local base_object = self.base_object
				self.lerp_type_unpacked(base_object, self.from, to, self.ease_type(alpha))
				self.value = base_object
			end
		end
	end
}

table_Inherit(metaTable_TweenUnpacked, metaTable_Tween)

metaTable_TweenUnpacked.__index = metaTable_TweenUnpacked

function TweenUnpacked(base_object, from, to, duration, ease_type, callback)
	local Tween = {
		base_object = base_object,
		from = from,
		to = to,
		duration = duration,
		ease_type = ease_type,
		callback = callback,
		value = from,
		time_left = duration,
		permanent = false,
		running = false
	}
	
	return setmetatable(Tween, metaTable_TweenUnpacked)
end

local metaTable_BezierTween = {
	Start = function(self)
		self.running = true
		self.start_time = SysTime()
		self.end_time = self.start_time + self.duration
		self.time_left = self.duration
		self.value = self.points[1]
		
		all_tweens[self] = true
		running_tweens[self] = true
	end,
	
	Update = function(self)
		if self.running then
			local points = self.points
			local time = SysTime()
			self.time_left = self.end_time - time
			
			if time >= self.end_time then
				self.running = false
				self.value = points[#points]
				
				if !self.permanent then
					all_tweens[self] = nil
					running_tweens[self] = nil
				end
				
				if self.callback != nil then
					self.callback(self)
				end
				
				return
			end
			
			local alpha = (time - self.start_time) / self.duration
			
			self.value = BSpline(points, self.ease_type(alpha))
		end
	end,
}

table_Inherit(metaTable_BezierTween, metaTable_Tween)

metaTable_BezierTween.__index = metaTable_BezierTween

function BezierTween(points, duration, ease_type, callback)
	local Tween = {
		points = points,
		duration = duration,
		ease_type = ease_type,
		callback = callback,
		value = points[1],
		time_left = duration,
		permanent = false,
		running = false,
	}
	
	return setmetatable(Tween, metaTable_BezierTween)
end

-- Tween Handler
hook.Add("Think", "process_tweens", function()
	if table.IsEmpty(running_tweens) then return end
	
	for tween in next, running_tweens do
		if tween == nil then continue end
		
		tween:Update()
	end
end)