local Light = {}
local LightMT = {__index = Light}

function love.light.newLight(World, x, y, red, green, blue, range)
	local self = {}
	
	self.World = World
	self.direction = 0
	self.angle = math.pi * 2.0
	self.range = 0
	self.shadow = love.graphics.newCanvas()
	self.shine = love.graphics.newCanvas()
	self.x = x or 0
	self.y = y or 0
	self.z = 15
	self.red = red or 255
	self.green = green or 255
	self.blue = blue or 255
	self.range = range or 300
	self.smooth = 1.0
	self.glowSize = 0.1
	self.glowStrength = 0.0
	self.changed = true
	self.visible = true
	self.Sun = false
	World.isLight = true
	
	local Index = #World.lights + 1
	World.lights[Index] = self

	return setmetatable(self, LightMT)
end

function Light:setPosition(x, y, z)
	if x ~= self.x or y ~= self.y or (z and z ~= self.z) then
		self.x = x
		self.y = y
		if z then
			self.z = z
		end
		self.changed = true
	end
end

function Light:setSun()
	self.World.Sun = self
end

function Light:isSun()
	return self.World.Sun == self
end

function Light:getX()
	return self.x
end

function Light:getY()
	return self.y
end

function Light:setX(x)
	if x ~= self.x then
		self.x = x
		self.changed = true
	end
end

function Light:setY(y)
	if y ~= self.y then
		self.y = y
		self.changed = true
	end
end

function Light:setColor(red, green, blue)
	self.red = red
	self.green = green
	self.blue = blue
	--self.World.changed = true
end

function Light:setRange(range)
	if range ~= self.range then
		self.range = range
		self.changed = true
	end
end

function Light:setDirection(direction)
	if direction ~= self.direction then
		if direction > math.pi * 2 then
			self.direction = math.mod(direction, math.pi * 2)
		elseif direction < 0.0 then
			self.direction = math.pi * 2 - math.mod(math.abs(direction), math.pi * 2)
		else
			self.direction = direction
		end
		self.changed = true
	end
end

function Light:setAngle(angle)
	if angle ~= self.angle then
		if angle > math.pi then
			self.angle = math.mod(angle, math.pi)
		elseif angle < 0.0 then
			self.angle = math.pi - math.mod(math.abs(angle), math.pi)
		else
			self.angle = angle
		end
		self.changed = true
	end
end

function Light:setSmooth(smooth)
	self.smooth = smooth
	self.changed = true
end

function Light:setGlowSize(size)
	self.glowSize = size
	self.changed = true
end

function Light:setGlowStrength(strength)
	self.glowStrength = strength
	self.changed = true
end

function Light:getType()
	return "light"
end

function Light:clear()
	local World = self.World
	for i = 1, #World.lights do
		if World.lights[i] == self then
			for k = i, #World.lights - 1 do
				World.lights[k] = World.lights[k + 1]
			end
			World.lights[#World.lights] = nil
			break
		end
	end
end