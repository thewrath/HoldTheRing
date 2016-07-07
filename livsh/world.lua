local Path = (...):gsub("%p", "/"):sub(1, -6).."/"
local World = {}
local WorldMT = {__index = World}

local calculateShadows = love.light.calculateShadows

function love.light.newWorld()
	local self = {}

	self.lights = {}
	self.ambient = {0, 0, 0}
	self.body = {}
	self.refraction = {}
	self.rooms = {}
	self.translate = {
		x = 0,
		y = 0,
	}
	self.translateOld = {
		x = 0,
		y = 0,
	}
	self.shadow = love.graphics.newCanvas()
	self.shadow2 = love.graphics.newCanvas()
	self.shine = love.graphics.newCanvas()
	self.shine2 = love.graphics.newCanvas()
	self.normalMap = love.graphics.newCanvas()
	self.glowMap = love.graphics.newCanvas()
	self.glowMap2 = love.graphics.newCanvas()
	self.refractionMap = love.graphics.newCanvas()
	self.refractionMap2 = love.graphics.newCanvas()
	self.reflectionMap = love.graphics.newCanvas()
	self.reflectionMap2 = love.graphics.newCanvas()
	self.normalInvert = false
	self.glowBlur = 1.0
	self.glowTimer = 0.0
	self.glowDown = false
	self.refractionStrength = 8.0
	self.pixelShadow = love.graphics.newCanvas()
	self.pixelShadow2 = love.graphics.newCanvas()
	self.shader = love.graphics.newShader(Path.."shader/poly_shadow.glsl")
	self.glowShader = love.graphics.newShader(Path.."shader/glow.glsl")
	self.normalShader = love.graphics.newShader(Path.."shader/normal.glsl")
	self.normalInvertShader = love.graphics.newShader(Path.."shader/normal_invert.glsl")
	self.materialShader = love.graphics.newShader(Path.."shader/material.glsl")
	self.refractionShader = love.graphics.newShader(Path.."shader/refraction.glsl")
	self.refractionShader:send("screen", {love.graphics.getWidth(), love.graphics.getHeight()})
	self.reflectionShader = love.graphics.newShader(Path.."shader/reflection.glsl")
	self.reflectionShader:send("screen", {love.graphics.getWidth(), love.graphics.getHeight()})
	self.reflectionStrength = 16.0
	self.reflectionVisibility = 1.0
	self.changed = true
	self.blur = 2.0
	self.optionShadows = true
	self.optionPixelShadows = true
	self.optionGlow = true
	self.optionRefraction = true
	self.optionReflection = true
	self.isShadows = false
	self.isLight = false
	self.isPixelShadows = false
	self.isGlow = false
	self.isRefraction = false
	self.isReflection = false
	
	function self.ShadowStencil()
		for i, Shadow in pairs(self.ShadowGeometry) do
			if Shadow.alpha == 1.0 then
				love.graphics[Shadow.type]("fill", unpack(Shadow))
			end
		end
	end
	
	return setmetatable(self, WorldMT)
end

function World:update()
	self.LastBuffer = love.graphics.getCanvas()

	if self.translate.x ~= self.translateOld.x or self.translate.y ~= self.translateOld.y then
		self.translateOld.x = self.translate.x
		self.translateOld.y = self.translate.y
		self.changed = true
	end

	love.graphics.setColor(255, 255, 255)
	love.graphics.setBlendMode("alpha")

	if self.optionShadows and (self.isShadows or self.isLight) then
		love.graphics.setShader(self.shader)

		for i, Light in pairs(self.lights) do
			if Light.changed or self.changed then
				if Light.x + Light.range > self.translate.x and Light.x - Light.range < love.graphics.getWidth() + self.translate.x and Light.y + Light.range > self.translate.y and Light.y - Light.range < love.graphics.getHeight() + self.translate.y then
					self.shader:send("lightPosition", {Light.x - self.translate.x, Light.y - self.translate.y, Light.z})
					self.shader:send("lightRange", Light.range)
					self.shader:send("lightColor", {Light.red / 255.0, Light.green / 255.0, Light.blue / 255.0})
					self.shader:send("lightSmooth", Light.smooth)
					self.shader:send("lightGlow", {1.0 - Light.glowSize, Light.glowStrength})
					self.shader:send("lightAngle", math.pi - Light.angle / 2.0)
					self.shader:send("lightDirection", Light.direction)

					love.graphics.setCanvas(Light.shadow)
					love.graphics.clear()

					-- calculate shadows
					self.ShadowGeometry = calculateShadows(Light, self.body)

					-- draw shadow
					love.graphics.stencil(self.ShadowStencil)
					love.graphics.setStencilTest("equal", 0)
					love.graphics.rectangle("fill", self.translate.x, self.translate.y, love.graphics.getWidth(), love.graphics.getHeight())
					
					-- draw color shadows
					love.graphics.setBlendMode("alpha")
					love.graphics.setShader()
					for k, Shadow in pairs(self.ShadowGeometry) do
						if Shadow.alpha < 1.0 then
							love.graphics.setColor(
								Shadow.red * (1.0 - Shadow.alpha),
								Shadow.green * (1.0 - Shadow.alpha),
								Shadow.blue * (1.0 - Shadow.alpha)
							)
							love.graphics[Shadow.type]("fill", unpack(Shadow))
						end
					end

					love.graphics.setShader(self.shader)
					
					-- draw shine
					love.graphics.setCanvas(Light.shine)
					love.graphics.clear(255, 255, 255, 255)

					Light.visible = true
				else
					Light.visible = false
				end
				Light.changed = self.changed
			end
		end

		-- update shadow
		love.graphics.setShader()
		love.graphics.setCanvas(self.shadow)
		love.graphics.setStencilTest()
		love.graphics.setColor(unpack(self.ambient))
		love.graphics.setBlendMode("alpha")
		love.graphics.rectangle("fill", self.translate.x, self.translate.y, love.graphics.getWidth(), love.graphics.getHeight())
		
		love.graphics.setBlendMode("alpha")
		for k, Body in pairs(self.body) do
			love.graphics.setColor(Body.red, Body.green, Body.blue)
			
			if Body.shadowTypeObject then
				Body.shadowTypeObject.Paint(Body, Light)
			end
		end
		
		if self.Sun then
			love.graphics.setColor(255, 255, 255)
			love.graphics.setBlendMode("add")
			love.graphics.draw(self.Sun.shadow, self.translate.x, self.translate.y)
		end
		
		love.graphics.setBlendMode("alpha")
		for _, Room in pairs(self.rooms) do
			if Room.visible then
				love.graphics.setColor(Room.red, Room.green, Room.blue)
				love.graphics.rectangle("fill", Room.x - self.translate.x, Room.y - self.translate.y, Room.width, Room.height)
			end
		end
		
		love.graphics.setColor(255, 255, 255)
		love.graphics.setBlendMode("add")
		for i, Light in pairs(self.lights) do
			if Light.visible and self.Sun ~= Light then
				love.graphics.draw(Light.shadow, self.translate.x, self.translate.y)
			end
		end
		
		self.isShadowBlur = false

		-- update shine
		love.graphics.setCanvas(self.shine)
		love.graphics.setColor(unpack(self.ambient))
		love.graphics.setBlendMode("alpha")
		love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())

		for _, Room in pairs(self.rooms) do
			if Room.visible then
				love.graphics.setColor(Room.red, Room.green, Room.blue)
				love.graphics.rectangle("fill", Room.x - self.translate.x, Room.y - self.translate.y, Room.width, Room.height)
			end
		end

		love.graphics.setColor(255, 255, 255)
		love.graphics.setBlendMode("add")
		for i, Light in pairs(self.lights) do
			if Light.visible then
				love.graphics.draw(Light.shine, self.translate.x, self.translate.y)
			end
		end
	end

	if self.optionPixelShadows and self.isPixelShadows then
		-- update pixel shadow
		love.graphics.setBlendMode("alpha")
		
		-- create normal map
		love.graphics.setShader()
		love.graphics.setCanvas(self.normalMap)
		love.graphics.clear()
		love.graphics.setColor(255, 255, 255)
		love.graphics.setBlendMode("alpha")

		love.graphics.setCanvas(self.pixelShadow2)
		love.graphics.clear()
		love.graphics.setBlendMode("add")
		love.graphics.setShader(self.shader2)

		for i, Light in pairs(self.lights) do
			if Light.visible then
				if self.normalInvert then
					self.normalInvertShader:send('screenResolution', {love.graphics.getWidth(), love.graphics.getHeight()})
					self.normalInvertShader:send('lightColor', {Light.red / 255.0, Light.green / 255.0, Light.blue / 255.0})
					self.normalInvertShader:send('lightPosition',{Light.x, Light.y, Light.z / 255.0})
					self.normalInvertShader:send('lightRange',{Light.range})
					self.normalInvertShader:send("lightSmooth", Light.smooth)
					self.normalInvertShader:send("lightAngle", math.pi - Light.angle / 2.0)
					self.normalInvertShader:send("lightDirection", Light.direction)
					love.graphics.setShader(self.normalInvertShader)
				else
					self.normalShader:send('screenResolution', {love.graphics.getWidth(), love.graphics.getHeight()})
					self.normalShader:send('lightColor', {Light.red / 255.0, Light.green / 255.0, Light.blue / 255.0})
					self.normalShader:send('lightPosition',{Light.x, Light.y, Light.z / 255.0})
					self.normalShader:send('lightRange',{Light.range})
					self.normalShader:send("lightSmooth", Light.smooth)
					self.normalShader:send("lightAngle", math.pi - Light.angle / 2.0)
					self.normalShader:send("lightDirection", Light.direction)
					love.graphics.setShader(self.normalShader)
				end
				love.graphics.draw(self.normalMap, self.translate.x, self.translate.y)
			end
		end

		love.graphics.setShader()
		love.graphics.setCanvas(self.pixelShadow)
		love.graphics.clear(255, 255, 255)
		love.graphics.setBlendMode("alpha")
		love.graphics.draw(self.pixelShadow2, self.translate.x, self.translate.y)
		love.graphics.setBlendMode("add")
		love.graphics.setColor(unpack(self.ambient))
		love.graphics.rectangle("fill", self.translate.x, self.translate.y, love.graphics.getWidth(), love.graphics.getHeight())
		love.graphics.setBlendMode("alpha")
	end

	if self.optionGlow and self.isGlow then
		-- create glow map
		love.graphics.setCanvas(self.glowMap)
		love.graphics.clear(0, 0, 0)

		if self.glowDown then
			self.glowTimer = math.max(0.0, self.glowTimer - love.timer.getDelta())
			if self.glowTimer == 0.0 then
				self.glowDown = not self.glowDown
			end
		else
			self.glowTimer = math.min(self.glowTimer + love.timer.getDelta(), 1.0)
			if self.glowTimer == 1.0 then
				self.glowDown = not self.glowDown
			end
		end

		for i, Body in pairs(self.body) do
			if Body.glowStrength > 0.0 then
				love.graphics.setColor(Body.glowRed * Body.glowStrength, Body.glowGreen * Body.glowStrength, Body.glowBlue * Body.glowStrength)
			else
				love.graphics.setColor(0, 0, 0)
			end
			
			if Body.type == "circle" then
				love.graphics.circle("fill", Body.x, Body.y, Body.radius)
			elseif Body.type == "rectangle" then
				love.graphics.rectangle("fill", Body.x, Body.y, Body.width, Body.height)
			elseif Body.type == "polygon" then
				love.graphics.polygon("fill", unpack(Body.data))
			end
		end
	end

	if self.optionRefraction and self.isRefraction then
		love.graphics.setShader()

		-- create refraction map
		love.graphics.setCanvas(self.refractionMap)
		love.graphics.clear()
		for i, Body in pairs(self.body) do
			if Body.refraction and Body.normal then
				love.graphics.setColor(255, 255, 255)
				if Body.tileX == 0.0 and Body.tileY == 0.0 then
					love.graphics.draw(normal, Body.x - Body.nx + self.translate.x, Body.y - Body.ny + self.translate.y)
				else
					Body.normalMesh:setVertices(Body.normalVert)
					love.graphics.draw(Body.normalMesh, Body.x - Body.nx + self.translate.x, Body.y - Body.ny + self.translate.y)
				end
			end
		end

		love.graphics.setColor(0, 0, 0)
		for i, Body in pairs(self.body) do
			if not Body.refractive then
				if Body.type == "circle" then
					love.graphics.circle("fill", Body.x, Body.y, Body.radius)
				elseif Body.type == "rectangle" then
					love.graphics.rectangle("fill", Body.x, Body.y, Body.width, Body.height)
				elseif Body.type == "polygon" then
					love.graphics.polygon("fill", unpack(Body.data))
				end
			end
		end
	end

	if self.optionReflection and self.isReflection then
		
		-- create reflection map
		if self.changed then
			self.reflectionMap:clear(0, 0, 0)
			love.graphics.setCanvas(self.reflectionMap)
			
			for i, Body in pairs(self.body) do
				if Body.reflection and Body.normal then
					love.graphics.setColor(255, 0, 0)
					Body.normalMesh:setVertices(Body.normalVert)
					love.graphics.draw(Body.normalMesh, Body.x - Body.nx + self.translate.x, Body.y - Body.ny + self.translate.y)
				end
			end
		end
	end

	love.graphics.setShader()
	love.graphics.setBlendMode("alpha")
	love.graphics.setStencilTest()
	love.graphics.setCanvas(self.LastBuffer)

	self.changed = false
end

function World:refreshScreenSize()
	self.shadow = love.graphics.newCanvas()
	self.shadow2 = love.graphics.newCanvas()
	self.shine = love.graphics.newCanvas()
	self.shine2 = love.graphics.newCanvas()
	self.normalMap = love.graphics.newCanvas()
	self.glowMap = love.graphics.newCanvas()
	self.glowMap2 = love.graphics.newCanvas()
	self.refractionMap = love.graphics.newCanvas()
	self.refractionMap2 = love.graphics.newCanvas()
	self.reflectionMap = love.graphics.newCanvas()
	self.reflectionMap2 = love.graphics.newCanvas()
	self.pixelShadow = love.graphics.newCanvas()
	self.pixelShadow2 = love.graphics.newCanvas()
end

function World:drawShine()
	if self.optionShadows and self.isShadows then
		love.graphics.setColor(255, 255, 255)
		if self.blur and false then
			self.LastBuffer = love.graphics.getCanvas()
			LOVE_LIGHT_BLURV:send("steps", self.blur)
			LOVE_LIGHT_BLURH:send("steps", self.blur)
			love.graphics.setBlendMode("alpha")
			love.graphics.setCanvas(self.shine2)
			love.graphics.setShader(LOVE_LIGHT_BLURV)
			love.graphics.draw(self.shine, self.translate.x, self.translate.y)
			love.graphics.setCanvas(self.shine)
			love.graphics.setShader(LOVE_LIGHT_BLURH)
			love.graphics.draw(self.shine2, self.translate.x, self.translate.y)
			love.graphics.setCanvas(self.LastBuffer)
			love.graphics.setBlendMode("multiply")
			love.graphics.setShader()
			love.graphics.draw(self.shine, self.translate.x, self.translate.y)
			love.graphics.setBlendMode("alpha")
		else
			love.graphics.setBlendMode("multiply")
			love.graphics.setShader()
			love.graphics.draw(self.shine, self.translate.x, self.translate.y)
			love.graphics.setBlendMode("alpha")
		end
	end
end

function World:drawShadow()
	if self.optionShadows and (self.isShadows or self.isLight) then
		love.graphics.setColor(255, 255, 255)
		if self.blur then
			self.LastBuffer = love.graphics.getCanvas()
			LOVE_LIGHT_BLURV:send("steps", self.blur)
			LOVE_LIGHT_BLURH:send("steps", self.blur)
			love.graphics.setBlendMode("alpha")
			love.graphics.setCanvas(self.shadow2)
			love.graphics.setShader(LOVE_LIGHT_BLURV)
			love.graphics.draw(self.shadow, self.translate.x, self.translate.y)
			love.graphics.setCanvas(self.shadow)
			love.graphics.setShader(LOVE_LIGHT_BLURH)
			love.graphics.draw(self.shadow2, self.translate.x, self.translate.y)
			love.graphics.setCanvas(self.LastBuffer)
			love.graphics.setBlendMode("multiply")
			love.graphics.setShader()
			love.graphics.draw(self.shadow, self.translate.x, self.translate.y)
			love.graphics.setBlendMode("alpha")
		else
			love.graphics.setBlendMode("multiply")
			love.graphics.setShader()
			love.graphics.draw(self.shadow, self.translate.x, self.translate.y)
			love.graphics.setBlendMode("alpha")
		end
	end
end

function World:drawPixelShadow()
	if self.optionPixelShadows and self.isPixelShadows then
		love.graphics.setColor(255, 255, 255)
		love.graphics.setBlendMode("multiply")
		love.graphics.setShader()
		love.graphics.draw(self.pixelShadow, self.translate.x, self.translate.y)
		love.graphics.setBlendMode("alpha")
	end
end

function World:drawMaterial()
	love.graphics.setShader(self.materialShader)
	for i, Body in pairs(self.body) do
		if Body.material and Body.normal then
			love.graphics.setColor(255, 255, 255)
			self.materialShader:send("material", Body.material)
			love.graphics.draw(Body.normal, Body.x - Body.nx + self.translate.x, Body.y - Body.ny + self.translate.y)
		end
	end
	love.graphics.setShader()
end

function World:drawGlow()
	if self.optionGlow and self.isGlow then
		love.graphics.setColor(255, 255, 255)
		if self.glowBlur == 0.0 then
			love.graphics.setBlendMode("add")
			love.graphics.setShader()
			love.graphics.draw(self.glowMap, self.translate.x, self.translate.y)
			love.graphics.setBlendMode("alpha")
		else
			LOVE_LIGHT_BLURV:send("steps", self.glowBlur)
			LOVE_LIGHT_BLURH:send("steps", self.glowBlur)
			self.LastBuffer = love.graphics.getCanvas()
			love.graphics.setBlendMode("add")
			love.graphics.setCanvas(self.glowMap2)
			love.graphics.clear()
			love.graphics.setShader(LOVE_LIGHT_BLURV)
			love.graphics.draw(self.glowMap, self.translate.x, self.translate.y)
			love.graphics.setCanvas(self.glowMap)
			love.graphics.setShader(LOVE_LIGHT_BLURH)
			love.graphics.draw(self.glowMap2, self.translate.x, self.translate.y)
			love.graphics.setCanvas(self.LastBuffer)
			love.graphics.setShader()
			love.graphics.draw(self.glowMap, self.translate.x, self.translate.y)
			love.graphics.setBlendMode("alpha")
		end
	end
end

function World:drawRefraction()
	if self.optionRefraction and self.isRefraction then
		self.LastBuffer = love.graphics.getCanvas()
		if self.LastBuffer then
			love.graphics.setColor(255, 255, 255)
			love.graphics.setBlendMode("alpha")
			love.graphics.setCanvas(self.refractionMap2)
			love.graphics.draw(self.LastBuffer, self.translate.x, self.translate.y)
			love.graphics.setCanvas(self.LastBuffer)
			self.refractionShader:send("backBuffer", self.refractionMap2)
			self.refractionShader:send("refractionStrength", self.refractionStrength)
			love.graphics.setShader(self.refractionShader)
			love.graphics.draw(self.refractionMap, self.translate.x, self.translate.y)
			love.graphics.setShader()
		end
	end
end

function World:drawReflection()
	if self.optionReflection and self.isReflection then
		self.LastBuffer = love.graphics.getCanvas()
		if self.LastBuffer then
			love.graphics.setColor(255, 255, 255)
			love.graphics.setBlendMode("alpha")
			love.graphics.setCanvas(self.reflectionMap2)
			love.graphics.draw(self.LastBuffer, self.translate.x, self.translate.y)
			love.graphics.setCanvas(self.LastBuffer)
			self.reflectionShader:send("backBuffer", self.reflectionMap2)
			self.reflectionShader:send("reflectionStrength", self.reflectionStrength)
			self.reflectionShader:send("reflectionVisibility", self.reflectionVisibility)
			love.graphics.setShader(self.reflectionShader)
			love.graphics.draw(self.reflectionMap, self.translate.x, self.translate.y)
			love.graphics.setShader()
		end
	end
end

function World:newLight(x, y, red, green, blue, range)
	return love.light.newLight(self, x, y, red, green, blue, range)
end

function World:newRoom(x, y, width, height, red, green, blue)
	return love.light.newRoom(self, x, y, width, height, red, green, blue)
end

function World:clearLights()
	self.lights = {}
	self.isLight = false
	self.changed = true
end

function World:clearBodies()
	self.body = {}
	self.changed = true
	self.isShadows = false
	self.isPixelShadows = false
	self.isGlow = false
	self.isRefraction = false
	self.isReflection = false
end

function World:setTranslation(translateX, translateY)
	self.translate.x = translateX
	self.translate.y = translateY
end

function World:setAmbientColor(red, green, blue)
	self.ambient = {red, green, blue}
end

function World:setAmbientRed(red)
	self.ambient[1] = red
end

function World:setAmbientGreen(green)
	self.ambient[2] = green
end

function World:setAmbientBlue(blue)
	self.ambient[3] = blue
end

function World:setNormalInvert(invert)
	self.normalInvert = invert
end

function World:setBlur(blur)
	self.blur = blur
	self.changed = true
end

function World:setShadowBlur(blur)
	self.blur = blur
	self.changed = true
end

function World:setBuffer(buffer)
	if buffer == "render" then
		love.graphics.setCanvas(self.LastBuffer)
	else
		self.LastBuffer = love.graphics.getCanvas()
	end

	if buffer == "glow" then
		love.graphics.setCanvas(self.glowMap)
	end
end

function World:setGlowStrength(strength)
	self.glowBlur = strength
	self.changed = true
end

function World:setRefractionStrength(strength)
	self.refractionStrength = strength
end

function World:setReflectionStrength(strength)
	self.reflectionStrength = strength
end

function World:setReflectionVisibility(visibility)
	self.reflectionVisibility = visibility
end

function World:newRectangle(x, y, w, h)
	return love.light.newRectangle(self, x, y, w, h)
end

function World:newCircle(x, y, r)
	return love.light.newCircle(self, x, y, r)
end

function World:newPolygon(...)
	return love.light.newPolygon(self, ...)
end

function World:newRefraction(normal, x, y)
	return love.light.newRefraction(self, normal, x, y)
end
 
 function World:newRefractionHeightMap(heightMap, x, y, strength)
	return love.light.newRefractionHeightMap(self, heightMap, x, y, strength)
end

function World:newReflection(normal, x, y)
	return love.light.newReflection(self, normal, x, y)
end

function World:newReflectionHeightMap(heightMap, x, y, strength)
	return love.light.newReflectionHeightMap(self, heightMap, x, y, strength)
end

function World:newBody(type, ...)
	return love.light.newBody(self, type, ...)
end

function World:setPoints(n, ...)
	local Body = self.body[n]
	if Body then
		Body.data = {...}
	end
end

function World:getBodyCount()
	return #self.body
end

function World:getPoints(n)
	local Body = self.body[n]
	if Body.data then
		return unpack(Body.data)
	end
end

function World:setLightPosition(n, x, y, z)
	local Light = self.lights[n]
	if Light then
		Light:setPosition(x, y, z)
	end
end

function World:setLightX(n, x)
	local Light = self.lights[n]
	if Light then
		Light:setX(x)
	end
end

function World:setLightY(n, y)
	local Light = self.lights[n]
	if Light then
		Light:setY(y)
	end
end

function World:setLightAngle(n, angle)
	local Light = self.lights[n]
	if Light then
		Light:setAngle(angle)
	end
end

function World:setLightDirection(n, direction)
	local Light = self.lights[n]
	if Light then
		Light:setDirection(direction)
	end
end

function World:getLightCount()
	return #self.lights
end

function World:getLightX(n)
	local Light = self.lights[n]
	if Light then
		return Light:getX()
	end
end

function World:getLightY(n)
	local Light = self.lights[n]
	if Light then
		return Light:getY()
	end
end

function World:getType()
	return "world"
end