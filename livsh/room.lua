local Room = {}
local RoomMT = {__index = Room}

function love.light.newRoom(World, x, y, width, height, red, green, blue, alpha)
	local self = {}
	
	self.World = World
	self.x = x or 0
	self.y = y or 0
	self.width = width or 0
	self.height = height or 0
	self.red = red or 0
	self.green = green or 0
	self.blue = blue or 0
	self.alpha = alpha or 255
	self.visible = true
	
	local Index = #World.rooms + 1
	World.rooms[Index] = self

	return setmetatable(self, RoomMT)
end

function Room:setPosition(x, y)
	if x ~= self.x or y ~= self.y then
		self.x = x
		self.y = y
	end
end

function Room:getX()
	return self.x
end

function Room:getY()
	return self.y
end

function Room:setX(x)
	if x ~= self.x then
		self.x = x
		self.changed = true
	end
end

function Room:setY(y)
	if y ~= self.y then
		self.y = y
		self.changed = true
	end
end

function Room:setColor(red, green, blue)
	self.red = red or 0
	self.green = green or 0
	self.blue = blue or 0
end

function Room:setVisible(visible)
	self.visible = visible
end

function Room:getType()
	return "room"
end

function Room:clear()
	local World = self.World
	for i = 1, #World.rooms do
		if World.rooms[i] == self then
			for k = i, #World.rooms - 1 do
				World.rooms[k] = World.rooms[k + 1]
			end
			World.rooms[#World.rooms] = nil
			break
		end
	end
end