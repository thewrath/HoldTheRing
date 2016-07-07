local Body = {}
local BodyMT = {__index = Body}

local HeightMapToNormalMap = love.light.HeightMapToNormalMap

function love.light.newBody(World, type, ...)
	local args = {...}
	local Index = #World.body + 1
	local self = setmetatable({}, BodyMT)
	
	World.body[Index] = self
	World.changed = true
	
	self.World = World
	self.id = Index
	self.type = type
	self.normal = nil
	self.material = nil
	self.glow = nil
	
	if self.type == "circle" then
		self.x = args[1] or 0
		self.y = args[2] or 0
		self.radius = args[3] or 16
		self.ox = args[4] or 0
		self.oy = args[5] or 0
		self.reflection = false
		self.reflective = false
		self.refraction = false
		self.refractive = false
		World.isShadows = true
		
		self:setShadowType("circle", self.radius, self.ox, self.oy)
	elseif self.type == "rectangle" then
		self.x = args[1] or 0
		self.y = args[2] or 0
		self.width = args[3] or 64
		self.height = args[4] or 64
		self.ox = self.width * 0.5
		self.oy = self.height * 0.5
		self.reflection = false
		self.reflective = false
		self.refraction = false
		self.refractive = false
		World.isShadows = true
		
		self:setShadowType("rectangle", self.width, self.height, self.ox, self.oy)
	elseif self.type == "polygon" then
		self.reflection = false
		self.reflective = false
		self.refraction = false
		self.refractive = false
		World.isShadows = true
		
		self:setShadowType("polygon", args)
	elseif self.type == "image" then
		self.img = args[1]
		self.x = args[2] or 0
		self.y = args[3] or 0
		if self.img then
			self.imgWidth = self.img:getWidth()
			self.imgHeight = self.img:getHeight()
			self.width = args[4] or self.imgWidth
			self.height = args[5] or self.imgHeight
			self.ix = self.imgWidth * 0.5
			self.iy = self.imgHeight * 0.5
			self.vert = {
				{ 0.0, 0.0, 0.0, 0.0},
				{ self.width, 0.0, 1.0, 0.0},
				{ self.width, self.height, 1.0, 1.0},
				{ 0.0, self.height, 0.0, 1.0},
			}
			self.msh = love.graphics.newMesh(self.vert, "fan")
			self.msh:setVertices(self.vert)
			--self.msh:setTexture(self.img)
		else
			self.width = args[4] or 64
			self.height = args[5] or 64
		end
		self.ox = args[6] or self.width * 0.5
		self.oy = args[7] or self.height * 0.5
		self.reflection = false
		self.reflective = true
		self.refraction = false
		self.refractive = false
		World.isShadows = true
		
		self:setShadowType("rectangle", self.width, self.height, self.ox, self.oy)
	elseif self.type == "refraction" then
		self.normal = args[1]
		self.x = args[2] or 0
		self.y = args[3] or 0
		if self.normal then
			self.normalWidth = self.normal:getWidth()
			self.normalHeight = self.normal:getHeight()
			self.width = args[4] or self.normalWidth
			self.height = args[5] or self.normalHeight
			self.nx = self.normalWidth * 0.5
			self.ny = self.normalHeight * 0.5
			self.normal:setWrap("repeat", "repeat")
			self.normalVert = {
				{0.0, 0.0, 0.0, 0.0},
				{self.width, 0.0, 1.0, 0.0},
				{self.width, self.height, 1.0, 1.0},
				{0.0, self.height, 0.0, 1.0}
			}
			self.normalMesh = love.graphics.newMesh(self.normalVert, "fan")
			self.normalMesh:setTexture(self.normal)
		else
			self.width = args[4] or 64
			self.height = args[5] or 64
		end
		self.ox = self.width * 0.5
		self.oy = self.height * 0.5
		self.reflection = false
		self.reflective = false
		self.refraction = true
		self.refractive = false
		World.isRefraction = true
	elseif self.type == "reflection" then
		self.normal = args[1]
		self.x = args[2] or 0
		self.y = args[3] or 0
		if self.normal then
			self.normalWidth = self.normal:getWidth()
			self.normalHeight = self.normal:getHeight()
			self.width = args[4] or self.normalWidth
			self.height = args[5] or self.normalHeight
			self.nx = self.normalWidth * 0.5
			self.ny = self.normalHeight * 0.5
			self.normal:setWrap("repeat", "repeat")
			self.normalVert = {
				{0.0, 0.0, 0.0, 0.0},
				{self.width, 0.0, 1.0, 0.0},
				{self.width, self.height, 1.0, 1.0},
				{0.0, self.height, 0.0, 1.0}
			}
			self.normalMesh = love.graphics.newMesh(self.normalVert, "fan")
			self.normalMesh:setTexture(self.normal)
		else
			self.width = args[4] or 64
			self.height = args[5] or 64
		end
		self.ox = self.width * 0.5
		self.oy = self.height * 0.5
		self.reflection = true
		self.reflective = false
		self.refraction = false
		self.refractive = false
		World.isReflection = true
	end
	
	self.shine = true
	self.red = 0
	self.green = 0
	self.blue = 0
	self.alpha = 1.0
	self.angle = 0
	self.glowRed = 255
	self.glowGreen = 255
	self.glowBlue = 255
	self.glowStrength = 0.0
	self.tileX = 0
	self.tileY = 0

	return self
end

function Body:refresh()
	if self.data then
		self.data[1] = self.x - self.ox
		self.data[2] = self.y - self.oy
		self.data[3] = self.x - self.ox + self.width
		self.data[4] = self.y - self.oy
		self.data[5] = self.x - self.ox + self.width
		self.data[6] = self.y - self.oy + self.height
		self.data[7] = self.x - self.ox
		self.data[8] = self.y - self.oy + self.height
	end
end

function Body:getVertices()
	local Vertices = {}
	
	if self.type == "rectangle" then
		local ArcTangent = math.rad(self.angle) - math.atan2(self.height, self.width)
		local Length = math.sqrt(self.width^2 + self.height^2)/2
		
		table.insert(Vertices, self.x - math.cos(ArcTangent) * Length)
		table.insert(Vertices, self.y + math.sin(ArcTangent) * Length)
		
		table.insert(Vertices, self.x - math.sin(ArcTangent) * Length)
		table.insert(Vertices, self.y - math.cos(ArcTangent) * Length)
		
		table.insert(Vertices, self.x + math.cos(ArcTangent) * Length)
		table.insert(Vertices, self.y - math.sin(ArcTangent) * Length)
		
		table.insert(Vertices, self.x + math.sin(ArcTangent) * Length)
		table.insert(Vertices, self.y + math.cos(ArcTangent) * Length)
	elseif self.type == "polygon" then
		local Data = self.data
		for i = 1, #Data, 2 do
			local Angle = math.atan2(Data[i +1], Data[i]) - math.pi/2
			local Length = math.sqrt(Data[i]^2 + Data[i + 1]^2)
			table.insert(Vertices, math.sin(Angle) * Length)
			table.insert(Vertices, -math.cos(Angle) * Length)
		end
	end
	
	return Vertices
end

function Body:setPosition(x, y, z)
	if x ~= self.x or y ~= self.y or z ~= self.z then
		self.x = x
		self.y = y
		self.z = z
		self:refresh()
		self.World.changed = true
	end
end

function Body:setX(x)
	if x ~= self.x then
		self.x = x
		self:refresh()
		self.World.changed = true
	end
end

function Body:setY(y)
	if y ~= self.y then
		self.y = y
		self:refresh()
		self.World.changed = true
	end
end

function Body:getX()
	return self.x
end

function Body:getY(y)
	return self.y
end

function Body:getWidth()
	return self.width
end

function Body:getHeight()
	return self.height
end

function Body:getImageWidth()
	return self.imgWidth
end

function Body:getImageHeight()
	return self.imgHeight
end

function Body:setDimension(width, height)
	self.width = width
	self.height = height
	self:refresh()
	self.World.changed = true
end

function Body:setOffset(ox, oy)
	if ox ~= self.ox or oy ~= self.oy then
		self.ox = ox
		self.oy = oy
		self:refresh()
		self.World.changed = true
	end
end

function Body:setImageOffset(ix, iy)
	if ix ~= self.ix or iy ~= self.iy then
		self.ix = ix
		self.iy = iy
		self:refresh()
		self.World.changed = true
	end
end

function Body:setNormalOffset(nx, ny)
	if nx ~= self.nx or ny ~= self.ny then
		self.nx = nx
		self.ny = ny
		self:refresh()
		self.World.changed = true
	end
end

function Body:setGlowColor(red, green, blue)
	self.glowRed = red
	self.glowGreen = green
	self.glowBlue = blue
	self.World.changed = true
end

function Body:setGlowStrength(strength)
	self.glowStrength = strength
	self.World.changed = true
end

function Body:getRadius()
	return self.radius
end

function Body:setRadius(radius)
	if radius ~= self.radius then
		self.radius = radius
		self.World.changed = true
	end
end
 
function Body:setPoints(...)
	self.data = {...}
	self.World.changed = true
end

function Body:getPoints()
	return unpack(self.data)
end

function Body:setShadow(b)
	self.castsNoShadow = not b
	self.World.changed = true
end

function Body:setShine(b)
	self.shine = b
	self.World.changed = true
end

function Body:setColor(red, green, blue)
	self.red = red
	self.green = green
	self.blue = blue
	self.World.changed = true
end

function Body:setAlpha(alpha)
	self.alpha = alpha
	self.World.changed = true
end

function Body:setReflection(reflection)
	self.reflection = reflection
end

function Body:setRefraction(refraction)
	self.refraction = refraction
end

function Body:setReflective(reflective)
	self.reflective = reflective
end

function Body:setRefractive(refractive)
	self.refractive = refractive
end

function Body:setImage(img)
	if img then
		self.img = img
		self.imgWidth = self.img:getWidth()
		self.imgHeight = self.img:getHeight()
		self.ix = self.imgWidth * 0.5
		self.iy = self.imgHeight * 0.5
	end
end

function Body:setNormalMap(normal, width, height, nx, ny)
	if normal then
		self.normal = normal
		self.normal:setWrap("repeat", "repeat")
		self.normalWidth = width or self.normal:getWidth()
		self.normalHeight = height or self.normal:getHeight()
		self.nx = nx or self.normalWidth * 0.5
		self.ny = ny or self.normalHeight * 0.5
		self.normalVert = {
			{0.0, 0.0, 0.0, 0.0},
			{self.normalWidth, 0.0, self.normalWidth / self.normal:getWidth(), 0.0},
			{self.normalWidth, self.normalHeight, self.normalWidth / self.normal:getWidth(), self.normalHeight / self.normal:getHeight()},
			{0.0, self.normalHeight, 0.0, self.normalHeight / self.normal:getHeight()}
		}
		self.normalMesh = love.graphics.newMesh(self.normalVert, "fan")
		self.normalMesh:setTexture(self.normal)

		self.World.isPixelShadows = true
	else
		self.normalMesh = nil
	end
end

function Body:setHeightMap(heightMap, strength)
	self:setNormalMap(HeightMapToNormalMap(heightMap, strength))
end

function Body:generateNormalMapFlat(mode)
	local imgData = self.img:getData()
	local imgNormalData = love.image.newImageData(self.imgWidth, self.imgHeight)
	local color

	if mode == "top" then
		color = {127, 127, 255}
	elseif mode == "front" then
		color = {127, 0, 127}
	elseif mode == "back" then
		color = {127, 255, 127}
	elseif mode == "left" then
		color = {31, 0, 223}
	elseif mode == "right" then
		color = {223, 0, 127}
	end

	for i = 0, self.imgHeight - 1 do
		for k = 0, self.imgWidth - 1 do
			local r, g, b, a = imgData:getPixel(k, i)
			if a > 0 then
				imgNormalData:setPixel(k, i, color[1], color[2], color[3], 255)
			end
		end
	end

	self:setNormalMap(love.graphics.newImage(imgNormalData))
end

function Body:generateNormalMapGradient(horizontalGradient, verticalGradient)
	local imgData = self.img:getData()
	local imgNormalData = love.image.newImageData(self.imgWidth, self.imgHeight)
	local dx = 255.0 / self.imgWidth
	local dy = 255.0 / self.imgHeight
	local nx
	local ny
	local nz

	for i = 0, self.imgWidth - 1 do
		for k = 0, self.imgHeight - 1 do
			local r, g, b, a = imgData:getPixel(i, k)
			if a > 0 then
				if horizontalGradient == "gradient" then
					nx = i * dx
				elseif horizontalGradient == "inverse" then
					nx = 255 - i * dx
				else
					nx = 127
				end

				if verticalGradient == "gradient" then
					ny = 127 - k * dy * 0.5
					nz = 255 - k * dy * 0.5
				elseif verticalGradient == "inverse" then
					ny = 127 + k * dy * 0.5
					nz = 127 - k * dy * 0.25
				else
					ny = 255
					nz = 127
				end

				imgNormalData:setPixel(i, k, nx, ny, nz, 255)
			end
		end
	end

	self:setNormalMap(love.graphics.newImage(imgNormalData))
end

function Body:generateNormalMap(strength)
	self:setNormalMap(HeightMapToNormalMap(self.img, strength))
end

function Body:setMaterial(material)
	if material then
		self.material = material
	end
end

function Body:setGlowMap(glow)
	self.glow = glow
	self.glowStrength = 1.0

	self.World.isGlow = true
end

function Body:setNormalTileOffset(tx, ty)
	self.tileX = tx / self.normalWidth
	self.tileY = ty / self.normalHeight
	self.normalVert = {
		{0.0, 0.0, self.tileX, self.tileY},
		{self.normalWidth, 0.0, self.tileX + 1.0, self.tileY},
		{self.normalWidth, self.normalHeight, self.tileX + 1.0, self.tileY + 1.0},
		{0.0, self.normalHeight, self.tileX, self.tileY + 1.0}
	}
	self.World.changed = true
end

function Body:getType()
	return self.type
end

function Body:setShadowType(Type, ...)
	self.shadowType = Type
	self.shadowTypeObject = love.light.ShadowTypes[Type]
	self.shadowTypeObject.setShadowType(self, ...)
	
	self.World.changed = true
end

function Body:clear()
	local World = self.World
	for i = 1, #World.body do
		if World.body[i] == o then
			for k = i, #World.body - 1 do
				World.body[k] = World.body[k + 1]
			end
			World.body[#World.body] = nil
			break
		end
	end
	World.changed = true
end