local Rectangle = {}

function Rectangle:setShadowType(width, height, ox, oy)
	self.width = width or 64
	self.height = height or 64
	self.ox = ox or self.width * 0.5
	self.oy = oy or self.height * 0.5
	self.data = {
		self.x - self.ox,
		self.y - self.oy,
		self.x - self.ox + self.width,
		self.y - self.oy,
		self.x - self.ox + self.width,
		self.y - self.oy + self.height,
		self.x - self.ox,
		self.y - self.oy + self.height
	}
end

function Rectangle:Paint()
	love.graphics.polygon("fill", self:getVertices())
end

return Rectangle