local Circle = {}

function Circle:setShadowType(radius, ox, oy)
	self.radius = radius or 16
	self.ox = ox or 0
	self.oy = oy or 0
end

function Circle:Paint()
	love.graphics.circle("fill", self.x - self.ox, self.y - self.oy, self.radius)
end

return Circle